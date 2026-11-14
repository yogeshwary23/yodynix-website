// YODYNIX contact Worker.
//
//   GET  /api/health   liveness + whether the SMTP secrets are configured
//   POST /api/contact  validate an enquiry and deliver it by SMTP
//
// A success response is returned only after the SMTP server has accepted
// the message (250 reply to DATA).

import { buildMessage } from './email.js';
import { SmtpError, sendMail } from './smtp.js';
import { validateEnquiry } from './validate.js';

const MAX_BODY_BYTES = 16 * 1024;
const MIN_FILL_MS = 3000;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const origin = request.headers.get('Origin');
    const allowed = allowedOrigins(env);
    const cors = origin && allowed.has(origin) ? corsHeaders(origin) : {};

    if (!url.pathname.startsWith('/api/')) return json({ ok: false, error: 'not_found' }, 404, cors);

    if (request.method === 'OPTIONS') {
      return origin && allowed.has(origin)
        ? new Response(null, { status: 204, headers: { ...cors, 'Access-Control-Max-Age': '86400' } })
        : new Response(null, { status: 403 });
    }

    if (url.pathname === '/api/health' && request.method === 'GET') {
      return json({ ok: true, service: 'yodynix-contact', configured: isConfigured(env) }, 200, cors);
    }

    if (url.pathname === '/api/contact') {
      if (request.method !== 'POST') return json({ ok: false, error: 'method_not_allowed' }, 405, { ...cors, Allow: 'POST, OPTIONS' });
      return handleContact(request, env, origin, allowed, cors);
    }

    return json({ ok: false, error: 'not_found' }, 404, cors);
  },
};

async function handleContact(request, env, origin, allowed, cors) {
  // Browsers always send Origin on this cross-site POST; anything else is not our form.
  if (!origin || !allowed.has(origin)) return json({ ok: false, error: 'origin_not_allowed' }, 403);

  if (!(request.headers.get('Content-Type') ?? '').toLowerCase().startsWith('application/json')) {
    return json({ ok: false, error: 'unsupported_media_type' }, 415, cors);
  }
  const declared = Number(request.headers.get('Content-Length') ?? 0);
  if (declared > MAX_BODY_BYTES) return json({ ok: false, error: 'payload_too_large' }, 413, cors);

  const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
  if (!(await withinRateLimit(env, ip))) return json({ ok: false, error: 'rate_limited' }, 429, { ...cors, 'Retry-After': '60' });

  let body;
  try {
    const raw = await readLimited(request, MAX_BODY_BYTES);
    if (raw === null) return json({ ok: false, error: 'payload_too_large' }, 413, cors);
    body = JSON.parse(raw);
  } catch {
    return json({ ok: false, error: 'invalid_json' }, 400, cors);
  }

  // Honeypot: the form always sends `website` empty. A filled value means a
  // bot; it gets a normal-looking reply and nothing is sent.
  if (typeof body?.website === 'string' && body.website.trim() !== '') {
    log('spam_honeypot');
    return json({ ok: true }, 200, cors);
  }
  // Humans take more than a few seconds to fill the form. Rejected (not
  // faked) so a real visitor is told to try again rather than misled.
  if (typeof body?.elapsedMs === 'number' && body.elapsedMs < MIN_FILL_MS) {
    log('spam_too_fast');
    return json({ ok: false, error: 'too_fast' }, 400, cors);
  }

  const result = validateEnquiry(body);
  if (!result.ok) return json({ ok: false, error: 'validation_failed', fields: result.errors }, 400, cors);

  if (!isConfigured(env)) {
    log('not_configured');
    return json({ ok: false, error: 'not_configured' }, 503, cors);
  }

  const username = env.SMTP_USERNAME.trim();
  const receiver = env.CONTACT_RECEIVER_EMAIL.trim();
  try {
    await sendMail({
      host: env.SMTP_HOST.trim(),
      port: Number(env.SMTP_PORT),
      username,
      password: env.SMTP_PASSWORD,
      from: username,
      to: receiver,
      message: buildMessage(result.data, { from: username, to: receiver }),
    });
  } catch (err) {
    // Only the stage and SMTP code are logged — no credentials, no form data.
    log('smtp_failure', err instanceof SmtpError ? { stage: err.stage, code: err.code, detail: err.message } : { stage: 'unknown' });
    return json({ ok: false, error: 'delivery_failed' }, 502, cors);
  }

  log('enquiry_sent');
  return json({ ok: true }, 200, cors);
}

function isConfigured(env) {
  return Boolean(env.SMTP_HOST && env.SMTP_PORT && env.SMTP_USERNAME && env.SMTP_PASSWORD && env.CONTACT_RECEIVER_EMAIL);
}

function allowedOrigins(env) {
  return new Set(
    String(env.ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((o) => o.trim().replace(/\/$/, ''))
      .filter(Boolean),
  );
}

// Best-effort fallback when the rate-limit binding is unavailable (e.g. older
// local tooling): per-isolate, so it only slows a single client down.
const localHits = new Map();

async function withinRateLimit(env, ip) {
  if (env.CONTACT_RATE_LIMITER) {
    const { success } = await env.CONTACT_RATE_LIMITER.limit({ key: ip });
    return success;
  }
  const now = Date.now();
  const recent = (localHits.get(ip) ?? []).filter((t) => now - t < 60_000);
  recent.push(now);
  localHits.set(ip, recent);
  return recent.length <= 5;
}

/** Reads the body, giving up (null) past [limit] bytes even without Content-Length. */
async function readLimited(request, limit) {
  if (!request.body) return '';
  const reader = request.body.getReader();
  const chunks = [];
  let size = 0;
  for (;;) {
    const { value, done } = await reader.read();
    if (done) break;
    size += value.byteLength;
    if (size > limit) {
      await reader.cancel();
      return null;
    }
    chunks.push(value);
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const c of chunks) {
    bytes.set(c, offset);
    offset += c.byteLength;
  }
  return new TextDecoder().decode(bytes);
}

function corsHeaders(origin) {
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    Vary: 'Origin',
  };
}

function json(data, status, extra = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      'X-Content-Type-Options': 'nosniff',
      ...extra,
    },
  });
}

function log(event, fields = {}) {
  console.log(JSON.stringify({ event, ...fields }));
}
