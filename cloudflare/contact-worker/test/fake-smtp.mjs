// Local stand-in for an SMTP server (plain TCP on 127.0.0.1:2525) so the
// Worker's full SMTP dialogue can be tested with `wrangler dev` without
// touching the real mailbox. Accepted messages are written to OUT_DIR.
//   node test/fake-smtp.mjs <outDir> [password]
import { mkdirSync, writeFileSync } from 'node:fs';
import net from 'node:net';
import { join } from 'node:path';

const outDir = process.argv[2] ?? '.fake-smtp';
const password = process.argv[3] ?? 'local-test-password';
mkdirSync(outDir, { recursive: true });
let count = 0;

net
  .createServer((sock) => {
    let buf = '';
    let inData = false;
    let data = '';
    const env = { authed: false, from: null, to: [] };
    const send = (l) => sock.write(`${l}\r\n`);
    send('220 fake.smtp ready');
    sock.on('data', (chunk) => {
      buf += chunk.toString('utf8');
      for (;;) {
        if (inData) {
          const end = buf.indexOf('\r\n.\r\n');
          if (end === -1) return;
          data = buf.slice(0, end).replace(/\r\n\.\./g, '\r\n.');
          buf = buf.slice(end + 5);
          inData = false;
          const file = join(outDir, `message-${++count}.json`);
          writeFileSync(file, JSON.stringify({ ...env, data }, null, 2));
          send('250 2.0.0 queued');
          continue;
        }
        const i = buf.indexOf('\r\n');
        if (i === -1) return;
        const line = buf.slice(0, i);
        buf = buf.slice(i + 2);
        const cmd = line.toUpperCase();
        if (cmd.startsWith('EHLO')) send('250-fake.smtp\r\n250-AUTH PLAIN LOGIN\r\n250 8BITMIME');
        else if (cmd.startsWith('AUTH PLAIN ')) {
          const [, user, pass] = Buffer.from(line.slice(11), 'base64').toString('utf8').split('\0');
          env.authed = pass === password;
          env.user = user;
          send(env.authed ? '235 2.7.0 ok' : '535 5.7.8 Authentication failed');
        } else if (cmd.startsWith('MAIL FROM:')) env.authed ? ((env.from = line.slice(10)), send('250 ok')) : send('530 auth required');
        else if (cmd.startsWith('RCPT TO:')) (env.to.push(line.slice(8)), send('250 ok'));
        else if (cmd === 'DATA') ((inData = true), send('354 go ahead'));
        else if (cmd === 'QUIT') (send('221 bye'), sock.end());
        else send('502 unknown');
      }
    });
    sock.on('error', () => {});
  })
  .listen(2525, '127.0.0.1', () => console.log('fake smtp listening on 127.0.0.1:2525'));
