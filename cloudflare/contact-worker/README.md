# YODYNIX contact Worker

Cloudflare Worker that receives the website's Project Enquiry form and the
Careers job / internship applications, and emails them to `hr@yodynix.it.com` through Spacemail SMTP (`mail.spacemail.com:465`,
implicit TLS, AUTH PLAIN/LOGIN). It uses its own small SMTP client over
`cloudflare:sockets` (`src/smtp.js`); Nodemailer does not run on Workers.

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | `{ ok, service, configured }`; `configured` is false until all SMTP settings and the password secret exist |
| `POST /api/contact` | Validates, then sends. `200 {ok:true}` **only** after the mail server accepts the message |
| `POST /api/careers` | `multipart/form-data` application with a `resume` file (PDF/DOC/DOCX, ≤ 5 MB, content checked against the extension). **Saves** it (D1 + résumé in KV), then emails HR with the résumé attached. `200 {ok, id, notified}` only after the save succeeds; `notified` is true only once the mail server accepted the HR email |
| cron `*/15 * * * *` | Re-sends HR emails that failed or never ran (up to 6 attempts) |

### Careers flow

1. Validate fields and résumé (`400` with `fields` on failure).
2. Refuse a resent copy of the same submission (`submissionId`, answered with the
   original `id`) and a second application for the same position from the same
   email within 24 hours (`409 duplicate_application`).
3. Save the résumé to KV (`resume/<id>`) and the record to D1 (`applications`).
   If saving fails: `500 storage_failed`, nothing is reported as submitted.
4. Email HR. If that fails the application stays saved with
   `notify_status = 'failed'` and the error; the cron retries it.

Check stored applications and notification status:

```sh
npx wrangler d1 execute yodynix-careers --remote --command \
  "SELECT created_at, kind, position, full_name, email, notify_status, notify_attempts, notify_error FROM applications ORDER BY created_at DESC LIMIT 20"
```

Download a résumé: `npx wrangler kv key get --remote --binding RESUMES "resume/<id>" > resume.pdf`

Errors: `400` validation / spam timing (careers: `fields` names each invalid field),
`403` origin not allowed, `411` no length, `413` body over 16 KB (careers: over 5 MB + 64 KB),
`415` not JSON (careers: not multipart), `429` rate limited (5/min per IP), `502` SMTP failure, `503` not configured.

## Configuration

Non-secret settings live in `wrangler.jsonc` → `vars`:
`SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `CONTACT_RECEIVER_EMAIL`,
`CAREERS_RECEIVER_EMAIL` (applications; falls back to `CONTACT_RECEIVER_EMAIL`), `ALLOWED_ORIGINS`.

Application emails are titled `New Job Application – {Position} – {Name}` or
`New Internship Application – {Position} – {Name}`, with Reply-To set to the
applicant and the application's reference ID in the body; the résumé is attached.

Bindings (IDs in `wrangler.jsonc`): D1 `APPLICATIONS_DB` (database `yodynix-careers`,
schema in `migrations/`) and KV `RESUMES`. Apply schema changes with
`npx wrangler d1 migrations apply yodynix-careers --remote`.

The password is a **secret** and is never stored in any file:

```sh
npx wrangler secret put SMTP_PASSWORD
```

(Dashboard alternative: Workers & Pages → `yodynix-contact` → Settings →
Variables and Secrets → Add → Type **Secret**, name `SMTP_PASSWORD`.)

`ALLOWED_ORIGINS` must list every exact origin that serves the site, e.g. add
`https://<project>.pages.dev` if the site is (also) served from Pages.

## Deploy

```sh
cd cloudflare/contact-worker
npm install
npx wrangler login            # once, opens the browser
npx wrangler d1 migrations apply yodynix-careers --remote   # once per schema change
npx wrangler deploy           # prints https://yodynix-contact.<subdomain>.workers.dev
npx wrangler secret put SMTP_PASSWORD
```

Then point the website at it — either set the default of
`ContactConfig.enquiryApiUrl` in `lib/core/constants/site_config.dart`, or build with:

```sh
flutter build web --release --dart-define=CONTACT_API_URL=https://yodynix-contact.<subdomain>.workers.dev/api/contact \
  --dart-define=CAREERS_API_URL=https://yodynix-contact.<subdomain>.workers.dev/api/careers
```

(`ContactConfig.careersApiUrl` holds the careers default.)

## Test

```sh
npm test                                   # unit tests (validation, escaping, MIME, storage)

# Full local flow against a fake SMTP server (no real mail is sent):
cp .dev.vars.example .dev.vars
node test/fake-smtp.mjs .fake-smtp &       # terminal 1
npx wrangler dev                           # terminal 2
node test/integration.mjs .fake-smtp       # terminal 3

# Deployed Worker
curl https://yodynix-contact.<subdomain>.workers.dev/api/health
npx wrangler tail                          # live logs: event, SMTP stage and code only
```

Logs never contain the password or form contents — only an event name and,
on failure, the SMTP stage (`tls`, `auth`, `rcpt_to`, …) and reply code.
