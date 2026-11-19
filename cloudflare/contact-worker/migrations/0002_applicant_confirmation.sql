-- Confirmation email to the applicant, tracked like the HR email: pending
-- until sent; failed sends are retried by the cron.
ALTER TABLE applications ADD COLUMN confirm_status TEXT NOT NULL DEFAULT 'pending' CHECK (confirm_status IN ('pending', 'sent', 'failed'));
ALTER TABLE applications ADD COLUMN confirm_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE applications ADD COLUMN confirm_error TEXT;
ALTER TABLE applications ADD COLUMN confirmed_at TEXT;

CREATE INDEX IF NOT EXISTS applications_by_confirm ON applications (confirm_status, created_at);
