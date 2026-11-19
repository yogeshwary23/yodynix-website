import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { test } from 'node:test';

import { validateApplication, validateResume } from '../src/application.js';
import {
  DUPLICATE_WINDOW_MS,
  loadApplication,
  MAX_NOTIFY_ATTEMPTS,
  pendingNotifications,
  recordNotification,
  saveApplication,
  submissionIdFrom,
} from '../src/store.js';

// D1's prepare/bind/first/run/all over an in-memory SQLite database that
// runs the real migration, so the queries themselves are exercised.
function d1() {
  const db = new DatabaseSync(':memory:');
  for (const m of ['0001_applications.sql', '0002_applicant_confirmation.sql']) {
    db.exec(readFileSync(new URL(`../migrations/${m}`, import.meta.url), 'utf8'));
  }
  return {
    sqlite: db,
    prepare(sql) {
      const stmt = db.prepare(sql);
      let args = [];
      return {
        bind(...a) {
          args = a;
          return this;
        },
        first: async () => stmt.get(...args) ?? null,
        run: async () => stmt.run(...args),
        all: async () => ({ results: stmt.all(...args) }),
      };
    },
  };
}

function kv() {
  const map = new Map();
  return {
    map,
    put: async (k, v, opts) => void map.set(k, { v: new Uint8Array(v), opts }),
    get: async (k) => (map.has(k) ? map.get(k).v.buffer : null),
    delete: async (k) => void map.delete(k),
  };
}

const env = () => ({ APPLICATIONS_DB: d1(), RESUMES: kv() });
const application = (over = {}) =>
  validateApplication({
    kind: 'internship',
    position: 'UI/UX Design Intern',
    fullName: 'Asha Patil',
    email: 'Asha@Example.com',
    mobile: '+91 98765 43210',
    education: 'B.Des. 2026',
    skills: 'Figma',
    message: '',
    ...over,
  }).data;
const pdf = () => {
  const b = new Uint8Array(2048);
  b.set([0x25, 0x50, 0x44, 0x46, 0x2d]);
  return validateResume('cv.pdf', b).file;
};

test('saves the record and the résumé, identified as job or internship', async () => {
  const e = env();
  const r = await saveApplication(e, application(), pdf(), 'sub-00000001');
  assert.equal(r.status, 'created');
  const row = e.APPLICATIONS_DB.sqlite.prepare('SELECT * FROM applications WHERE id = ?').get(r.id);
  assert.equal(row.kind, 'internship');
  assert.equal(row.position, 'UI/UX Design Intern');
  assert.equal(row.notify_status, 'pending');
  assert.equal(row.resume_size, 2048);
  assert.equal(e.RESUMES.map.get(row.resume_key).v.byteLength, 2048);

  const job = await saveApplication(e, application({ kind: 'job', position: 'Web Developer' }), pdf(), 'sub-00000002');
  assert.equal(e.APPLICATIONS_DB.sqlite.prepare('SELECT kind FROM applications WHERE id = ?').get(job.id).kind, 'job');
});

test('the same submission sent twice is stored once', async () => {
  const e = env();
  const first = await saveApplication(e, application(), pdf(), 'sub-00000001');
  const again = await saveApplication(e, application(), pdf(), 'sub-00000001');
  assert.deepEqual(again, { status: 'resubmitted', id: first.id });
  assert.equal(e.APPLICATIONS_DB.sqlite.prepare('SELECT COUNT(*) AS n FROM applications').get().n, 1);
  assert.equal(e.RESUMES.map.size, 1);
});

test('a second application for the same position within 24 hours is refused', async () => {
  const e = env();
  const now = new Date('2026-11-19T10:00:00Z');
  await saveApplication(e, application(), pdf(), 'sub-00000001', now);
  const again = await saveApplication(e, application({ email: 'asha@example.com' }), pdf(), 'sub-00000002', now);
  assert.deepEqual(again, { status: 'duplicate' });
  // A different position is fine, and so is the same one a day later.
  const other = await saveApplication(e, application({ position: 'Web Development Intern' }), pdf(), 'sub-00000003', now);
  assert.equal(other.status, 'created');
  const later = new Date(now.getTime() + DUPLICATE_WINDOW_MS + 1000);
  assert.equal((await saveApplication(e, application(), pdf(), 'sub-00000004', later)).status, 'created');
});

test('a failed insert removes the résumé and reports the error', async () => {
  const e = env();
  e.APPLICATIONS_DB.sqlite.exec('DROP TABLE applications; CREATE TABLE applications (id TEXT, submission_id TEXT, email TEXT, position TEXT, created_at TEXT)');
  await assert.rejects(saveApplication(e, application(), pdf(), 'sub-00000001'));
  assert.equal(e.RESUMES.map.size, 0);
});

test('failed HR emails are kept and offered for retry until they succeed', async () => {
  const e = env();
  const created = new Date('2026-11-19T10:00:00Z');
  const { id } = await saveApplication(e, application(), pdf(), 'sub-00000001', created);
  const later = new Date(created.getTime() + 5 * 60 * 1000);

  await recordNotification(e, id, 'AUTH 535 bad credentials');
  let pending = await pendingNotifications(e, 5, later);
  assert.equal(pending.length, 1);
  assert.equal(pending[0].notify_status, 'failed');
  assert.equal(pending[0].notify_error, 'AUTH 535 bad credentials');

  const { application: a, file } = await loadApplication(e, pending[0]);
  assert.equal(a.fullName, 'Asha Patil');
  assert.equal(file.bytes.byteLength, 2048);

  await recordNotification(e, id, null);
  pending = await pendingNotifications(e, 5, later);
  assert.equal(pending.length, 0);
  const row = e.APPLICATIONS_DB.sqlite.prepare('SELECT * FROM applications WHERE id = ?').get(id);
  assert.equal(row.notify_status, 'sent');
  assert.equal(row.notify_attempts, 2);
});

test('the applicant confirmation is tracked and retried separately from the HR email', async () => {
  const e = env();
  const created = new Date('2026-11-19T10:00:00Z');
  const { id } = await saveApplication(e, application(), pdf(), 'sub-00000001', created);
  const later = new Date(created.getTime() + 5 * 60 * 1000);

  await recordNotification(e, id, null);
  await recordNotification(e, id, 'rcpt 550 mailbox unavailable', later, 'applicant');
  assert.equal((await pendingNotifications(e, 5, later)).length, 0);
  const pending = await pendingNotifications(e, 5, later, 'applicant');
  assert.equal(pending.length, 1);
  assert.equal(pending[0].confirm_status, 'failed');
  assert.equal(pending[0].confirm_error, 'rcpt 550 mailbox unavailable');

  await recordNotification(e, id, null, later, 'applicant');
  assert.equal((await pendingNotifications(e, 5, later, 'applicant')).length, 0);
  const row = e.APPLICATIONS_DB.sqlite.prepare('SELECT * FROM applications WHERE id = ?').get(id);
  assert.equal(row.notify_status, 'sent');
  assert.equal(row.confirm_status, 'sent');
  assert.equal(row.confirm_attempts, 2);
  assert.equal(row.confirmed_at, later.toISOString());
});

test('retries stop after the maximum number of attempts', async () => {
  const e = env();
  const created = new Date('2026-11-19T10:00:00Z');
  const { id } = await saveApplication(e, application(), pdf(), 'sub-00000001', created);
  for (let i = 0; i < MAX_NOTIFY_ATTEMPTS; i++) await recordNotification(e, id, 'timeout');
  assert.equal((await pendingNotifications(e, 5, new Date(created.getTime() + 600000))).length, 0);
});

test('just-saved applications are left to the request that saved them', async () => {
  const e = env();
  const created = new Date('2026-11-19T10:00:00Z');
  await saveApplication(e, application(), pdf(), 'sub-00000001', created);
  assert.equal((await pendingNotifications(e, 5, new Date(created.getTime() + 30000))).length, 0);
});

test('submission ids from the site are used only when well-formed', () => {
  assert.equal(submissionIdFrom('3f2a9c1e-1b2c-4d5e-8f90-123456789abc'), '3f2a9c1e-1b2c-4d5e-8f90-123456789abc');
  assert.notEqual(submissionIdFrom("x'; DROP TABLE"), "x'; DROP TABLE");
  assert.match(submissionIdFrom(''), /^[0-9a-f-]{36}$/);
});
