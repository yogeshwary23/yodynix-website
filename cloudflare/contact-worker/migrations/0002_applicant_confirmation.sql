-- Columns for an applicant confirmation email, which was later removed (HR
-- notification only). Already applied in production, so kept for the
-- migration history; nothing reads or writes these columns.
ALTER TABLE applications ADD COLUMN confirm_status TEXT NOT NULL DEFAULT 'pending' CHECK (confirm_status IN ('pending', 'sent', 'failed'));
ALTER TABLE applications ADD COLUMN confirm_attempts INTEGER NOT NULL DEFAULT 0;
ALTER TABLE applications ADD COLUMN confirm_error TEXT;
ALTER TABLE applications ADD COLUMN confirmed_at TEXT;

CREATE INDEX IF NOT EXISTS applications_by_confirm ON applications (confirm_status, created_at);
