-- Job and internship applications from the Careers page. The résumé file
-- itself lives in the RESUMES KV namespace under `resume_key`.
CREATE TABLE IF NOT EXISTS applications (
  id TEXT PRIMARY KEY,
  -- One per form submission, sent by the site, so a retried request is
  -- recognised instead of stored twice.
  submission_id TEXT NOT NULL UNIQUE,
  kind TEXT NOT NULL CHECK (kind IN ('job', 'internship')),
  position TEXT NOT NULL,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  mobile TEXT NOT NULL,
  education TEXT NOT NULL,
  skills TEXT NOT NULL,
  message TEXT NOT NULL DEFAULT '',
  resume_key TEXT NOT NULL,
  resume_name TEXT NOT NULL,
  resume_mime TEXT NOT NULL,
  resume_size INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  -- HR email: pending until sent; failed sends are retried by the cron.
  notify_status TEXT NOT NULL DEFAULT 'pending' CHECK (notify_status IN ('pending', 'sent', 'failed')),
  notify_attempts INTEGER NOT NULL DEFAULT 0,
  notify_error TEXT,
  notified_at TEXT
);

CREATE INDEX IF NOT EXISTS applications_by_applicant ON applications (email, position, created_at);
CREATE INDEX IF NOT EXISTS applications_by_notify ON applications (notify_status, created_at);
