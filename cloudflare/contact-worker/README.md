# YODYNIX contact Worker

Cloudflare Worker that receives the website's Project Enquiry form and emails
it to `hr@yodynix.it.com` through Spacemail SMTP (`mail.spacemail.com:465`,
implicit TLS, AUTH PLAIN/LOGIN). It uses its own small SMTP client over
`cloudflare:sockets` (`src/smtp.js`); Nodemailer does not run on Workers.

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | `{ ok, service, configured }`; `configured` is false until all SMTP settings and the password secret exist |
| `POST /api/contact` | Validates, then sends. `200 {ok:true}` **only** after the mail server accepts the message |

Errors: `400` validation / spam timing, `403` origin not allowed, `413` body over 16 KB,
`415` not JSON, `429` rate limited (5/min per IP), `502` SMTP failure, `503` not configured.

## Configuration

Non-secret settings live in `wrangler.jsonc` → `vars`:
`SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `CONTACT_RECEIVER_EMAIL`, `ALLOWED_ORIGINS`.

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
npx wrangler deploy           # prints https://yodynix-contact.<subdomain>.workers.dev
npx wrangler secret put SMTP_PASSWORD
```

Then point the website at it — either set the default of
`ContactConfig.enquiryApiUrl` in `lib/core/constants/site_config.dart`, or build with:

```sh
flutter build web --release --dart-define=CONTACT_API_URL=https://yodynix-contact.<subdomain>.workers.dev/api/contact
```

## Test

```sh
npm test                                   # unit tests (validation, escaping, MIME)

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
