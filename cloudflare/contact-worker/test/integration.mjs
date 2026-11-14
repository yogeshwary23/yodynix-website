// End-to-end checks against a running Worker (default: wrangler dev on :8787)
// with test/fake-smtp.mjs as the SMTP server.
//   node test/integration.mjs <fakeSmtpOutDir>
import assert from 'node:assert/strict';
import { readdirSync, readFileSync, rmSync } from 'node:fs';
import { join } from 'node:path';

const BASE = process.env.WORKER_URL ?? 'http://127.0.0.1:8787';
const ORIGIN = 'http://localhost:8080';
const outDir = process.argv[2];
const valid = {
  fullName: 'Asha Patil',
  businessName: 'Patil <b>Traders</b>',
  email: 'asha.customer@example.com',
  mobile: '+91 98765 43210',
  service: 'Website Development',
  budget: 'Starter project (small scope)',
  description: 'We need a five-page website for our shop.\n.\nWith an enquiry form & a gallery <script>alert(1)</script>',
  preferredContactMethod: 'Email',
  website: '',
  elapsedMs: 45000,
};
const post = (body, { origin = ORIGIN, type = 'application/json', raw } = {}) =>
  fetch(`${BASE}/api/contact`, {
    method: 'POST',
    headers: { ...(origin ? { Origin: origin } : {}), 'Content-Type': type },
    body: raw ?? JSON.stringify(body),
  });
const messages = () => readdirSync(outDir).filter((f) => f.endsWith('.json'));

let n = 0;
async function check(name, fn) {
  await fn();
  console.log(`ok ${++n} - ${name}`);
}

rmSync(outDir, { recursive: true, force: true });
await import('node:fs').then((fs) => fs.mkdirSync(outDir, { recursive: true }));

await check('health endpoint', async () => {
  const r = await fetch(`${BASE}/api/health`);
  assert.equal(r.status, 200);
  assert.deepEqual(await r.json(), { ok: true, service: 'yodynix-contact', configured: true });
});
await check('preflight from allowed origin', async () => {
  const r = await fetch(`${BASE}/api/contact`, { method: 'OPTIONS', headers: { Origin: ORIGIN, 'Access-Control-Request-Method': 'POST' } });
  assert.equal(r.status, 204);
  assert.equal(r.headers.get('access-control-allow-origin'), ORIGIN);
});
await check('preflight from other origin is refused', async () => {
  const r = await fetch(`${BASE}/api/contact`, { method: 'OPTIONS', headers: { Origin: 'https://evil.example' } });
  assert.equal(r.status, 403);
  assert.equal(r.headers.get('access-control-allow-origin'), null);
});
await check('POST from other origin / no origin is refused', async () => {
  assert.equal((await post(valid, { origin: 'https://evil.example' })).status, 403);
  assert.equal((await post(valid, { origin: null })).status, 403);
});
await check('non-JSON body is refused', async () => {
  assert.equal((await post(null, { type: 'text/plain', raw: 'hi' })).status, 415);
});
await check('oversized body is refused', async () => {
  assert.equal((await post({ ...valid, description: 'x'.repeat(20000) })).status, 413);
});
await check('GET on /api/contact is refused', async () => {
  assert.equal((await fetch(`${BASE}/api/contact`, { headers: { Origin: ORIGIN } })).status, 405);
});

await check('valid enquiry is delivered via SMTP', async () => {
  const r = await post(valid);
  assert.equal(r.status, 200, await r.clone().text());
  assert.deepEqual(await r.json(), { ok: true });
  assert.equal(r.headers.get('access-control-allow-origin'), ORIGIN);
  const files = messages();
  assert.equal(files.length, 1);
  const m = JSON.parse(readFileSync(join(outDir, files[0]), 'utf8'));
  assert.equal(m.authed, true);
  assert.equal(m.user, 'hr@yodynix.it.com');
  assert.equal(m.from, '<hr@yodynix.it.com>');
  assert.deepEqual(m.to, ['<hr@yodynix.it.com>']);
  const [head, ...rest] = m.data.split('\r\n\r\n');
  assert.match(head, /^Reply-To: "Asha Patil" <asha\.customer@example\.com>$/m);
  assert.match(head, /^From: YODYNIX Website <hr@yodynix\.it\.com>$/m);
  const parts = rest.join('\r\n\r\n').split(/--yodynix-[0-9a-f-]+/);
  const decode = (p) => Buffer.from(p.split('\r\n\r\n')[1].replace(/\s/g, ''), 'base64').toString('utf8');
  const text = decode(parts[1]);
  const html = decode(parts[2]);
  assert.match(text, /Customer Name: Asha Patil/);
  assert.match(text, /Business Name: Patil <b>Traders<\/b>/);
  assert.ok(text.includes('\n.\n'), 'dot line survives dot-stuffing');
  assert.ok(html.includes('Patil &lt;b&gt;Traders&lt;/b&gt;'));
  assert.ok(html.includes('&lt;script&gt;alert(1)&lt;/script&gt;'));
  assert.ok(!html.includes('<script>'));
  for (const label of ['Customer Name', 'Business Name', 'Customer Email', 'Mobile Number', 'Required Service', 'Project Budget', 'Preferred Contact Method', 'Submitted', 'Project Description']) {
    assert.ok(html.includes(label), label);
  }
});
await check('invalid enquiry is rejected with field errors and not sent', async () => {
  const r = await post({ ...valid, email: 'not-an-email', description: 'short' });
  assert.equal(r.status, 400);
  const body = await r.json();
  assert.deepEqual(Object.keys(body.fields).sort(), ['description', 'email']);
  assert.equal(messages().length, 1);
});
await check('honeypot submission gets a quiet 200 and is not sent', async () => {
  const r = await post({ ...valid, website: 'http://spam.example' });
  assert.equal(r.status, 200);
  assert.equal(messages().length, 1);
});
await check('instant submission is rejected and not sent', async () => {
  assert.equal((await post({ ...valid, elapsedMs: 300 })).status, 400);
  assert.equal(messages().length, 1);
});
await check('rate limit: 6th request within a minute gets 429', async () => {
  assert.equal((await post({ ...valid, email: 'x' })).status, 400); // 5th
  const r = await post({ ...valid, email: 'x' }); // 6th
  assert.equal(r.status, 429);
  assert.equal(r.headers.get('retry-after'), '60');
});
console.log(`# ${n} checks passed`);
