// Minimal SMTP submission client for Cloudflare Workers, built on the
// runtime's TCP sockets API (`cloudflare:sockets`). Supports implicit TLS
// (port 465) and AUTH PLAIN / LOGIN — exactly what Spacemail offers.
//
// Nodemailer is not used: it depends on Node's `net`/`tls` modules, which
// Workers do not provide as raw sockets.

import { connect } from 'cloudflare:sockets';

import { base64 } from './encoding.js';

const LOOPBACK = new Set(['127.0.0.1', 'localhost', '::1']);
const MAX_REPLY_BYTES = 64 * 1024;

/** A failed SMTP exchange. [stage] says where it failed; never contains secrets. */
export class SmtpError extends Error {
  constructor(stage, message, code) {
    super(message);
    this.name = 'SmtpError';
    this.stage = stage;
    this.code = code ?? null;
  }
}

/**
 * Sends one message and resolves only once the server has accepted it
 * (the 250 reply to the end of DATA).
 *
 * @param {object} o
 * @param {string} o.host
 * @param {number} o.port
 * @param {string} o.username
 * @param {string} o.password
 * @param {string} o.from      envelope sender
 * @param {string} o.to        envelope recipient
 * @param {string} o.message   full RFC 5322 message, CRLF line endings
 * @param {string} [o.heloName]
 * @param {number} [o.timeoutMs]
 */
export async function sendMail({ host, port, username, password, from, to, message, heloName = 'yodynix.it.com', timeoutMs = 25000 }) {
  if (port === 25) throw new SmtpError('config', 'Port 25 is not allowed');
  // Plain TCP only for a local test server; everything else uses implicit TLS.
  const secureTransport = LOOPBACK.has(host) ? 'off' : 'on';

  let socket;
  try {
    socket = connect({ hostname: host, port }, { secureTransport, allowHalfOpen: false });
  } catch (err) {
    throw new SmtpError('connect', `Could not open socket: ${errorText(err)}`);
  }

  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => reject(new SmtpError('timeout', `No response within ${timeoutMs} ms`)), timeoutMs);
  });

  const session = new SmtpSession(socket);
  try {
    await Promise.race([timeout, converse(session, { secureTransport, username, password, from, to, message, heloName })]);
  } finally {
    clearTimeout(timer);
    session.close();
  }
}

async function converse(s, { secureTransport, username, password, from, to, message, heloName }) {
  try {
    await s.socket.opened;
  } catch (err) {
    throw new SmtpError(secureTransport === 'on' ? 'tls' : 'connect', `Connection failed: ${errorText(err)}`);
  }

  await s.expect('greeting', [220]);
  const ehlo = await s.command('ehlo', `EHLO ${heloName}`, [250]);
  const authLine = ehlo.lines.find((l) => /^250[ -]AUTH[ =]/i.test(l)) ?? '';
  const mechanisms = authLine.slice(9).toUpperCase().split(/\s+/);

  if (mechanisms.includes('PLAIN')) {
    await s.command('auth', `AUTH PLAIN ${base64(`\u0000${username}\u0000${password}`)}`, [235]);
  } else if (mechanisms.includes('LOGIN')) {
    await s.command('auth', 'AUTH LOGIN', [334]);
    await s.command('auth', base64(username), [334]);
    await s.command('auth', base64(password), [235]);
  } else {
    throw new SmtpError('auth', 'Server offers neither AUTH PLAIN nor AUTH LOGIN');
  }

  await s.command('mail_from', `MAIL FROM:<${from}>`, [250]);
  await s.command('rcpt_to', `RCPT TO:<${to}>`, [250, 251]);
  await s.command('data', 'DATA', [354]);
  await s.write(`${dotStuff(message)}\r\n.\r\n`);
  await s.expect('data_end', [250]);

  // The message is accepted at this point; a failed QUIT changes nothing.
  try {
    await s.command('quit', 'QUIT', [221]);
  } catch {
    /* ignore */
  }
}

class SmtpSession {
  constructor(socket) {
    this.socket = socket;
    this.reader = socket.readable.getReader();
    this.writer = socket.writable.getWriter();
    this.decoder = new TextDecoder();
    this.encoder = new TextEncoder();
    this.buffer = '';
  }

  async write(text) {
    await this.writer.write(this.encoder.encode(text));
  }

  async command(stage, line, codes) {
    try {
      await this.write(`${line}\r\n`);
    } catch (err) {
      throw new SmtpError(stage, `Write failed: ${errorText(err)}`);
    }
    return this.expect(stage, codes);
  }

  async expect(stage, codes) {
    const reply = await this.readReply(stage);
    if (!codes.includes(reply.code)) {
      // The server's last line (e.g. "535 5.7.8 Authentication failed") never echoes credentials.
      throw new SmtpError(stage, `Unexpected reply: ${reply.lines.at(-1).slice(0, 200)}`, reply.code);
    }
    return reply;
  }

  async readReply(stage) {
    const lines = [];
    for (;;) {
      let end;
      while ((end = this.buffer.indexOf('\r\n')) === -1) {
        let chunk;
        try {
          chunk = await this.reader.read();
        } catch (err) {
          throw new SmtpError(stage === 'greeting' ? 'tls' : stage, `Read failed: ${errorText(err)}`);
        }
        if (chunk.done) throw new SmtpError(stage, 'Connection closed by server');
        this.buffer += this.decoder.decode(chunk.value, { stream: true });
        if (this.buffer.length > MAX_REPLY_BYTES) throw new SmtpError(stage, 'Reply too large');
      }
      const line = this.buffer.slice(0, end);
      this.buffer = this.buffer.slice(end + 2);
      lines.push(line);
      if (/^\d{3}(?: |$)/.test(line)) return { code: Number(line.slice(0, 3)), lines };
      if (!/^\d{3}-/.test(line)) throw new SmtpError(stage, 'Malformed reply');
    }
  }

  close() {
    try {
      this.reader.releaseLock();
      this.writer.releaseLock();
    } catch {
      /* ignore */
    }
    this.socket.close().catch(() => {});
  }
}

/** RFC 5321 §4.5.2: a line starting with "." gets an extra ".". */
export function dotStuff(message) {
  return message.replace(/\r\n\./g, '\r\n..').replace(/^\./, '..');
}

function errorText(err) {
  return String(err?.message ?? err).slice(0, 200);
}
