import assert from 'node:assert/strict';
import { test } from 'node:test';

import { buildHtml, buildMessage, escapeHtml, SUBJECT } from '../src/email.js';
import { validateEnquiry } from '../src/validate.js';

const valid = {
  fullName: 'Asha Patil',
  businessName: 'Patil Traders',
  email: 'asha@example.com',
  mobile: '+91 98765 43210',
  service: 'Website Development',
  budget: 'Starter project (small scope)',
  description: 'We need a five-page website for our shop with an enquiry form.',
  preferredContactMethod: 'Email',
};

test('accepts a complete enquiry', () => {
  const r = validateEnquiry(valid);
  assert.equal(r.ok, true);
  assert.equal(r.data.email, 'asha@example.com');
});

test('optional fields may be absent', () => {
  const { businessName, budget, ...rest } = valid;
  assert.equal(validateEnquiry(rest).ok, true);
});

test('rejects missing and malformed required fields', () => {
  const r = validateEnquiry({ ...valid, fullName: 'A', email: 'nope', mobile: '12', description: 'short', preferredContactMethod: 'Fax', service: '' });
  assert.equal(r.ok, false);
  assert.deepEqual(Object.keys(r.errors).sort(), ['description', 'email', 'fullName', 'mobile', 'preferredContactMethod', 'service']);
});

test('rejects non-object bodies', () => {
  for (const body of [null, [], 'x', 42]) assert.equal(validateEnquiry(body).ok, false);
});

test('header injection via line breaks is neutralised or rejected', () => {
  assert.equal(validateEnquiry({ ...valid, email: 'a@example.com\r\nBcc: x@evil.com' }).ok, false);
  const r = validateEnquiry({ ...valid, fullName: 'Asha\r\nBcc: x@evil.com' });
  assert.equal(r.ok, true);
  assert.ok(!/[\r\n]/.test(r.data.fullName));
});

test('description keeps line breaks but strips other control characters', () => {
  const r = validateEnquiry({ ...valid, description: 'Line one is long enough\r\nLine two\u0000\u0007 here' });
  assert.equal(r.data.description, 'Line one is long enough\nLine two here');
});

test('escapes HTML in user content', () => {
  assert.equal(escapeHtml('<script>"x"&\'y\''), '&lt;script&gt;&quot;x&quot;&amp;&#39;y&#39;');
  const html = buildHtml({ ...valid, description: '<img src=x onerror=alert(1)>\nNext' }, 'now');
  assert.ok(!html.includes('<img src=x'));
  assert.ok(html.includes('&lt;img src=x onerror=alert(1)&gt;<br>Next'));
});

test('builds a multipart message with the right headers', () => {
  const msg = buildMessage(validateEnquiry(valid).data, { from: 'hr@yodynix.it.com', to: 'hr@yodynix.it.com' });
  const [head] = msg.split('\r\n\r\n');
  assert.match(head, /^From: YODYNIX Website <hr@yodynix\.it\.com>$/m);
  assert.match(head, /^To: <hr@yodynix\.it\.com>$/m);
  assert.match(head, /^Reply-To: "Asha Patil" <asha@example\.com>$/m);
  const subject = head.match(/^Subject: =\?UTF-8\?B\?(.+)\?=$/m)[1];
  assert.equal(Buffer.from(subject, 'base64').toString('utf8'), SUBJECT);
  assert.match(head, /multipart\/alternative; boundary="yodynix-/);
  assert.ok(!/\n(?<!\r\n)/.test(msg.replace(/\r\n/g, '')), 'only CRLF line endings');
  assert.ok(msg.split('\r\n').every((l) => l.length <= 998), 'no over-long lines');
  const parts = msg.match(/Content-Type: text\/(plain|html)/g);
  assert.deepEqual(parts, ['Content-Type: text/plain', 'Content-Type: text/html']);
});

test('non-ASCII reply names are encoded, not quoted', () => {
  const msg = buildMessage({ ...validateEnquiry(valid).data, fullName: 'आशा पाटील' }, { from: 'a@b.co', to: 'a@b.co' });
  assert.match(msg, /^Reply-To: =\?UTF-8\?B\?[A-Za-z0-9+/=]+\?= <asha@example\.com>$/m);
});
