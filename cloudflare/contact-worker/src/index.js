// YODYNIX contact Worker.
//
//   GET  /api/health   liveness + whether the SMTP secrets are configured
//   POST /api/contact  validate an enquiry and deliver it by SMTP
//   POST /api/careers  validate a job or internship application (multipart
//                      form with a résumé), save it (D1 + résumé in KV), then
//                      email HR with the résumé attached
//   cron               retries HR emails that failed or never ran
//
// Careers: success means the application is saved. The HR email is sent
// straight away; if that fails the application stays saved, the failure is
// logged and recorded, and the cron retries it. `notified` in the response
// says whether the SMTP server accepted it.
// A success response is returned only after the SMTP server has accepted
// the message (250 reply to DATA).

import { buildApplicationMessage, MAX_RESUME_BYTES, validateApplication, validateResume } from './application.js';
import { buildMessage } from './email.js';
import {
  loadApplication,
  pendingNotifications,
  recordNotification,
  saveApplication,
  storageConfigured,
  submissionIdFrom,
} from './store.js';
import { SmtpError, sendMail } from './smtp.js';
import { validateEnquiry } from './validate.js';

const MAX_BODY_BYTES = 16 * 1024;
// The résumé plus the text fields and multipart framing.
const MAX_APPLICATION_BYTES = MAX_RESUME_BYTES + 64 * 1024;
const MIN_FILL_MS = 3000;

export default {
  async scheduled(_controller, env, ctx) {
    ctx.waitUntil(retryNotifications(env));
  },

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

    if (url.pathname === '/api/careers') {
      if (request.method !== 'POST') return json({ ok: false, error: 'method_not_allowed' }, 405, { ...cors, Allow: 'POST, OPTIONS' });
      return handleApplication(request, env, origin, allowed, cors);
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

async function handleApplication(request, env, origin, allowed, cors) {
  if (!origin || !allowed.has(origin)) return json({ ok: false, error: 'origin_not_allowed' }, 403);

  if (!(request.headers.get('Content-Type') ?? '').toLowerCase().startsWith('multipart/form-data')) {
    return json({ ok: false, error: 'unsupported_media_type' }, 415, cors);
  }
  // Browsers always send the length of a FormData body; refuse to buffer an
  // unknown or oversized upload.
  const declared = Number(request.headers.get('Content-Length') ?? NaN);
  if (!Number.isFinite(declared)) return json({ ok: false, error: 'length_required' }, 411, cors);
  if (declared > MAX_APPLICATION_BYTES) return json({ ok: false, error: 'payload_too_large' }, 413, cors);

  const ip = request.headers.get('CF-Connecting-IP') ?? 'unknown';
  if (!(await withinRateLimit(env, ip))) return json({ ok: false, error: 'rate_limited' }, 429, { ...cors, 'Retry-After': '60' });

  let form;
  try {
    form = await request.formData();
  } catch {
    return json({ ok: false, error: 'invalid_form' }, 400, cors);
  }
  const field = (name) => {
    const v = form.get(name);
    return typeof v === 'string' ? v : '';
  };

  if (field('website').trim() !== '') {
    log('spam_honeypot');
    return json({ ok: true }, 200, cors);
  }
  const elapsed = Number(field('elapsedMs'));
  if (Number.isFinite(elapsed) && elapsed < MIN_FILL_MS) {
    log('spam_too_fast');
    return json({ ok: false, error: 'too_fast' }, 400, cors);
  }

  const result = validateApplication({
    kind: field('kind'),
    position: field('position'),
    fullName: field('fullName'),
    email: field('email'),
    mobile: field('mobile'),
    education: field('education'),
    skills: field('skills'),
    message: field('message'),
  });
  const upload = form.get('resume');
  const resume = upload && typeof upload === 'object'
    ? validateResume(upload.name, new Uint8Array(await upload.arrayBuffer()))
    : { ok: false, error: 'A résumé is required' };
  if (!result.ok || !resume.ok) {
    const fields = { ...(result.ok ? {} : result.errors), ...(resume.ok ? {} : { resume: resume.error }) };
    return json({ ok: false, error: 'validation_failed', fields }, 400, cors);
  }

  if (!storageConfigured(env)) {
    log('storage_not_configured');
    return json({ ok: false, error: 'not_configured' }, 503, cors);
  }

  // 1. Save. Nothing is reported as submitted until this succeeds.
  let saved;
  try {
    saved = await saveApplication(env, result.data, resume.file, submissionIdFrom(field('submissionId')));
  } catch (err) {
    log('storage_failure', { detail: String(err?.message ?? err).slice(0, 200) });
    return json({ ok: false, error: 'storage_failed' }, 500, cors);
  }
  if (saved.status === 'duplicate') {
    log('application_duplicate', { kind: result.data.kind });
    return json({ ok: false, error: 'duplicate_application' }, 409, cors);
  }
  if (saved.status === 'resubmitted') {
    log('application_resubmitted', { id: saved.id });
    return json({ ok: true, id: saved.id }, 200, cors);
  }
  log('application_saved', { id: saved.id, kind: result.data.kind });

  // 2. Email HR. A failure keeps the application and is retried by the cron.
  const notified = await notifyHr(env, saved.id, { ...result.data, reference: saved.id }, resume.file, new Date());
  return json({ ok: true, id: saved.id, notified }, 200, cors);
}

/** Sends the HR email for a saved application and records the outcome.
 * Returns whether the SMTP server accepted it. */
async function notifyHr(env, id, application, file, submitted) {
  let error = null;
  if (!isConfigured(env)) {
    error = 'SMTP is not configured';
  } else {
    const username = env.SMTP_USERNAME.trim();
    const receiver = (env.CAREERS_RECEIVER_EMAIL || env.CONTACT_RECEIVER_EMAIL).trim();
    try {
      await sendMail({
        host: env.SMTP_HOST.trim(),
        port: Number(env.SMTP_PORT),
        username,
        password: env.SMTP_PASSWORD,
        from: username,
        to: receiver,
        message: buildApplicationMessage(application, file, { from: username, to: receiver, submitted }),
        // A few megabytes of attachment take longer to upload than an enquiry.
        timeoutMs: 60000,
      });
    } catch (err) {
      error = err instanceof SmtpError ? `${err.stage} ${err.code ?? ''} ${err.message}`.trim() : String(err?.message ?? err);
    }
  }
  try {
    await recordNotification(env, id, error);
  } catch (err) {
    log('notify_record_failure', { id, detail: String(err?.message ?? err).slice(0, 200) });
  }
  if (error) log('notify_failure', { id, detail: error.slice(0, 200) });
  else log('application_sent', { id, kind: application.kind });
  return !error;
}

/** Cron: resend HR emails that failed or never ran. */
async function retryNotifications(env) {
  if (!storageConfigured(env)) return;
  for (const row of await pendingNotifications(env)) {
    try {
      const { application, file } = await loadApplication(env, row);
      await notifyHr(env, row.id, { ...application, reference: row.id }, file, new Date(row.created_at));
    } catch (err) {
      const detail = String(err?.message ?? err);
      log('notify_retry_failure', { id: row.id, detail: detail.slice(0, 200) });
      await recordNotification(env, row.id, detail).catch(() => {});
    }
  }
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
