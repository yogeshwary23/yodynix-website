// Storage for careers applications: the record in D1 (APPLICATIONS_DB) and
// the résumé file in KV (RESUMES). Both are private to this Worker.

/** A second application for the same position from the same email within
 * this window is refused. */
export const DUPLICATE_WINDOW_MS = 24 * 60 * 60 * 1000;

/** The HR email is retried until it is sent or this many attempts fail. */
export const MAX_NOTIFY_ATTEMPTS = 6;

const SUBMISSION_ID = /^[A-Za-z0-9-]{8,64}$/;

export function storageConfigured(env) {
  return Boolean(env.APPLICATIONS_DB && env.RESUMES);
}

/** The site's per-submission key, or a fresh one if it sent none. */
export function submissionIdFrom(value) {
  const v = String(value ?? '').trim();
  return SUBMISSION_ID.test(v) ? v : crypto.randomUUID();
}

/**
 * Saves a validated application and its résumé.
 *
 * @returns {Promise<{ status: 'created' | 'resubmitted', id: string } | { status: 'duplicate' }>}
 *   `resubmitted`: this exact submission was already saved (a retried
 *   request); `duplicate`: the applicant already applied for this position
 *   recently. Throws if storage fails.
 */
export async function saveApplication(env, a, file, submissionId, now = new Date()) {
  const db = env.APPLICATIONS_DB;
  const previous = await db.prepare('SELECT id FROM applications WHERE submission_id = ?').bind(submissionId).first();
  if (previous) return { status: 'resubmitted', id: previous.id };

  const since = new Date(now.getTime() - DUPLICATE_WINDOW_MS).toISOString();
  const recent = await db
    .prepare('SELECT id FROM applications WHERE lower(email) = lower(?) AND position = ? AND created_at > ? LIMIT 1')
    .bind(a.email, a.position, since)
    .first();
  if (recent) return { status: 'duplicate' };

  const id = crypto.randomUUID();
  const resumeKey = `resume/${id}`;
  await env.RESUMES.put(resumeKey, file.bytes, {
    metadata: { filename: file.filename, mime: file.mime, applicationId: id },
  });
  try {
    await db
      .prepare(
        `INSERT INTO applications (id, submission_id, kind, position, full_name, email, mobile, education, skills,
           message, resume_key, resume_name, resume_mime, resume_size, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      )
      .bind(
        id,
        submissionId,
        a.kind,
        a.position,
        a.fullName,
        a.email,
        a.mobile,
        a.education,
        a.skills,
        a.message,
        resumeKey,
        file.filename,
        file.mime,
        file.bytes.byteLength,
        now.toISOString(),
      )
      .run();
  } catch (err) {
    // Never leave an orphaned file behind.
    await env.RESUMES.delete(resumeKey).catch(() => {});
    // Two copies of the same request raced: the other one was saved.
    const raced = await db.prepare('SELECT id FROM applications WHERE submission_id = ?').bind(submissionId).first();
    if (raced) return { status: 'resubmitted', id: raced.id };
    throw err;
  }
  return { status: 'created', id };
}

/** The two emails sent per application and the columns tracking each:
 * `hr` is the notification to HR, `applicant` the confirmation to the
 * applicant. Fixed strings only, never user input. */
const CHANNELS = {
  hr: { status: 'notify_status', attempts: 'notify_attempts', error: 'notify_error', at: 'notified_at' },
  applicant: { status: 'confirm_status', attempts: 'confirm_attempts', error: 'confirm_error', at: 'confirmed_at' },
};

/** Records the outcome of one email attempt on [channel]. */
export async function recordNotification(env, id, error, now = new Date(), channel = 'hr') {
  const c = CHANNELS[channel];
  const db = env.APPLICATIONS_DB;
  if (error) {
    await db
      .prepare(`UPDATE applications SET ${c.status} = 'failed', ${c.attempts} = ${c.attempts} + 1, ${c.error} = ? WHERE id = ?`)
      .bind(String(error).slice(0, 500), id)
      .run();
  } else {
    await db
      .prepare(`UPDATE applications SET ${c.status} = 'sent', ${c.attempts} = ${c.attempts} + 1, ${c.error} = NULL, ${c.at} = ? WHERE id = ?`)
      .bind(now.toISOString(), id)
      .run();
  }
}

/** Applications whose email on [channel] still needs sending, oldest
 * first. Skips very recent ones, which the request that saved them is
 * still handling. */
export async function pendingNotifications(env, limit = 5, now = new Date(), channel = 'hr') {
  const c = CHANNELS[channel];
  const before = new Date(now.getTime() - 2 * 60 * 1000).toISOString();
  const { results } = await env.APPLICATIONS_DB.prepare(
    `SELECT * FROM applications
     WHERE ${c.status} != 'sent' AND ${c.attempts} < ? AND created_at < ?
     ORDER BY created_at LIMIT ?`,
  )
    .bind(MAX_NOTIFY_ATTEMPTS, before, limit)
    .all();
  return results ?? [];
}

/** Rebuilds the validated application and résumé from a stored row. */
export async function loadApplication(env, row) {
  const bytes = await env.RESUMES.get(row.resume_key, 'arrayBuffer');
  if (!bytes) throw new Error(`résumé missing for ${row.id}`);
  return {
    application: {
      kind: row.kind,
      position: row.position,
      fullName: row.full_name,
      email: row.email,
      mobile: row.mobile,
      education: row.education,
      skills: row.skills,
      message: row.message,
    },
    file: { filename: row.resume_name, mime: row.resume_mime, bytes: new Uint8Array(bytes) },
  };
}
