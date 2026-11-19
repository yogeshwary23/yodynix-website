import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  applicationSubject,
  attachmentName,
  buildApplicationHtml,
  buildApplicationMessage,
  MAX_RESUME_BYTES,
  validateApplication,
  validateResume,
} from '../src/application.js';

const valid = {
  kind: 'job',
  position: 'Flutter Developer',
  fullName: 'Asha Patil',
  email: 'asha@example.com',
  mobile: '+91 98765 43210',
  education: 'B.E. Computer Engineering, 2025',
  skills: 'Flutter, Dart, Firebase',
  message: 'I have built two apps on the Play Store.',
};

const pdf = (size = 64) => {
  const bytes = new Uint8Array(size);
  bytes.set([0x25, 0x50, 0x44, 0x46, 0x2d]);
  return bytes;
};

test('accepts a complete job and internship application', () => {
  assert.equal(validateApplication(valid).ok, true);
  assert.equal(validateApplication({ ...valid, kind: 'internship', position: 'UI/UX Design Intern' }).ok, true);
});

test('the additional message is optional', () => {
  const { message, ...rest } = valid;
  assert.equal(validateApplication(rest).ok, true);
});

test('rejects missing and malformed required fields', () => {
  const r = validateApplication({ kind: 'contract', position: '', fullName: 'A', email: 'x@', mobile: '12345', education: '', skills: '' });
  assert.equal(r.ok, false);
  assert.deepEqual(Object.keys(r.errors).sort(), ['education', 'email', 'fullName', 'kind', 'mobile', 'position', 'skills']);
});

test('header injection through the email is rejected', () => {
  assert.equal(validateApplication({ ...valid, email: 'a@example.com\r\nBcc: x@evil.com' }).ok, false);
});

test('accepts PDF, DOC and DOCX résumés whose content matches', () => {
  assert.equal(validateResume('cv.pdf', pdf()).ok, true);
  const doc = new Uint8Array(64);
  doc.set([0xd0, 0xcf, 0x11, 0xe0, 0xa1, 0xb1, 0x1a, 0xe1]);
  assert.equal(validateResume('CV.DOC', doc).ok, true);
  const docx = new Uint8Array(64);
  docx.set([0x50, 0x4b, 0x03, 0x04]);
  assert.equal(validateResume('cv.docx', docx).file.mime, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
});

test('rejects other types, renamed files, empty and oversized résumés', () => {
  assert.equal(validateResume('cv.exe', pdf()).ok, false);
  assert.equal(validateResume('cv', pdf()).ok, false);
  assert.equal(validateResume('cv.docx', pdf()).ok, false, 'a PDF renamed to .docx');
  assert.equal(validateResume('cv.pdf', new Uint8Array(0)).ok, false);
  assert.equal(validateResume('cv.pdf', pdf(MAX_RESUME_BYTES + 1)).ok, false);
});

test('subjects name the type, position and applicant', () => {
  const a = validateApplication(valid).data;
  assert.equal(applicationSubject(a), 'New Job Application – Flutter Developer – Asha Patil');
  const i = validateApplication({ ...valid, kind: 'internship', position: 'Web Development Intern' }).data;
  assert.equal(applicationSubject(i), 'New Internship Application – Web Development Intern – Asha Patil');
});

test('attachment names are ASCII and safe', () => {
  const file = validateResume('my "cv".pdf', pdf()).file;
  assert.equal(attachmentName({ fullName: 'Asha Patil' }, file), 'Resume - Asha Patil.pdf');
  assert.equal(attachmentName({ fullName: 'Zoë / O"Neil' }, file), 'Resume - Zoe  ONeil.pdf');
  assert.equal(attachmentName({ fullName: 'अनिता' }, file), 'Resume - Applicant.pdf');
});

test('escapes HTML in applicant content', () => {
  const a = validateApplication({ ...valid, skills: '<script>alert(1)</script>' }).data;
  const html = buildApplicationHtml(a, validateResume('cv.pdf', pdf()).file, 'now');
  assert.ok(!html.includes('<script>'));
  assert.ok(html.includes('&lt;script&gt;'));
});

test('builds a multipart/mixed message with the résumé attached', () => {
  const a = validateApplication(valid).data;
  const bytes = pdf(5000);
  const msg = buildApplicationMessage(a, validateResume('cv.pdf', bytes).file, { from: 'hr@yodynix.it.com', to: 'hr@yodynix.it.com', now: new Date('2026-11-19T10:00:00Z') });
  assert.match(msg, /^From: YODYNIX Careers <hr@yodynix\.it\.com>\r\n/);
  assert.match(msg, /\r\nReply-To: "Asha Patil" <asha@example\.com>\r\n/);
  assert.match(msg, /\r\nSubject: =\?UTF-8\?B\?[A-Za-z0-9+/=]+\?=\r\n/);
  assert.match(msg, /Content-Type: multipart\/mixed; boundary="yodynix-mixed-/);
  assert.match(msg, /Content-Disposition: attachment; filename="Resume - Asha Patil\.pdf"/);
  assert.ok(!/\r\n[^\r\n]{999}/.test(msg), 'no line exceeds the SMTP limit');
  assert.ok(!/(?<!\r)\n/.test(msg), 'only CRLF line endings');

  // The attachment decodes back to the original bytes.
  const part = msg.split('Content-Disposition: attachment')[1];
  const b64 = part.split('\r\n\r\n')[1].split('\r\n--')[0].replace(/\r\n/g, '');
  assert.deepEqual(new Uint8Array(Buffer.from(b64, 'base64')), bytes);
});
