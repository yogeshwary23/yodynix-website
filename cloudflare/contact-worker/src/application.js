// Careers applications: server-side validation of the form fields and the
// résumé, and the HR notification email with the résumé attached.
//
// Every field is re-checked here; the Flutter form's rules are never trusted.

import { cleanBlock, cleanLine, EMAIL_PATTERN } from './validate.js';
import { base64Lines, bytesBase64Lines, encodeHeaderWord } from './encoding.js';
import { escapeHtml, formatSubmittedAt } from './email.js';

export const MAX_RESUME_BYTES = 5 * 1024 * 1024;

/** Accepted résumé types: extension, MIME type and leading "magic" bytes. */
const RESUME_TYPES = {
  pdf: { mime: 'application/pdf', magic: [0x25, 0x50, 0x44, 0x46, 0x2d] }, // %PDF-
  doc: { mime: 'application/msword', magic: [0xd0, 0xcf, 0x11, 0xe0, 0xa1, 0xb1, 0x1a, 0xe1] }, // OLE2
  docx: { mime: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', magic: [0x50, 0x4b, 0x03, 0x04] }, // ZIP
};

export const KINDS = {
  job: { label: 'Job Application', subject: 'New Job Application' },
  internship: { label: 'Internship Application', subject: 'New Internship Application' },
};

/**
 * @param {Record<string, unknown>} body form fields as strings
 * @returns {{ ok: true, data: object } | { ok: false, errors: Record<string, string> }}
 */
export function validateApplication(body) {
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, errors: { _: 'Expected form fields' } };
  }
  const data = {
    kind: cleanLine(body.kind),
    position: cleanLine(body.position),
    fullName: cleanLine(body.fullName),
    email: cleanLine(body.email),
    mobile: cleanLine(body.mobile),
    education: cleanLine(body.education),
    skills: cleanBlock(body.skills),
    message: cleanBlock(body.message),
  };
  const errors = {};

  if (!Object.hasOwn(KINDS, data.kind)) errors.kind = 'Application type is invalid';
  if (data.position.length < 2 || data.position.length > 120) errors.position = 'A position is required';
  if (data.fullName.length < 2 || data.fullName.length > 100) errors.fullName = 'Full name must be 2–100 characters';
  if (data.email.length > 254 || !EMAIL_PATTERN.test(data.email)) errors.email = 'A valid email address is required';

  const digits = data.mobile.replace(/\D/g, '');
  if (!/^[\d+\-\s()]{10,30}$/.test(data.mobile) || digits.length < 10 || digits.length > 15) {
    errors.mobile = 'A valid mobile number is required';
  }

  if (data.education.length < 2 || data.education.length > 200) errors.education = 'Education must be 2–200 characters';
  if (data.skills.length < 2 || data.skills.length > 500) errors.skills = 'Relevant skills must be 2–500 characters';
  if (data.message.length > 1500) errors.message = 'Message must be at most 1500 characters';

  return Object.keys(errors).length ? { ok: false, errors } : { ok: true, data };
}

/**
 * Checks the uploaded résumé by extension, size and content (its leading
 * bytes must match the claimed type, so a renamed file is refused).
 *
 * @param {string} name original file name
 * @param {Uint8Array} bytes file content
 * @returns {{ ok: true, file: { filename: string, mime: string, bytes: Uint8Array } } | { ok: false, error: string }}
 */
export function validateResume(name, bytes) {
  const ext = String(name ?? '').toLowerCase().match(/\.([a-z0-9]+)$/)?.[1];
  const type = ext && RESUME_TYPES[ext];
  if (!type) return { ok: false, error: 'Résumé must be a PDF, DOC or DOCX file' };
  if (!bytes || bytes.byteLength === 0) return { ok: false, error: 'Résumé file is empty' };
  if (bytes.byteLength > MAX_RESUME_BYTES) return { ok: false, error: 'Résumé must be 5 MB or smaller' };
  if (!type.magic.every((b, i) => bytes[i] === b)) return { ok: false, error: 'Résumé content does not match its file type' };
  return { ok: true, file: { filename: name, mime: type.mime, bytes } };
}

/** "New Job Application – Flutter Developer – Asha Patil" */
export function applicationSubject(a) {
  return `${KINDS[a.kind].subject} – ${a.position} – ${a.fullName}`;
}

/**
 * The attachment's file name: "Resume - Asha Patil.pdf", ASCII only so
 * every mail client shows it the same way.
 */
export function attachmentName(a, file) {
  const ext = file.filename.toLowerCase().match(/\.([a-z0-9]+)$/)[1];
  const name = a.fullName
    .normalize('NFKD')
    .replace(/[^\x20-\x7e]/g, '')
    .replace(/["\\/:*?<>|]/g, '')
    .trim();
  return `Resume - ${name || 'Applicant'}.${ext}`;
}

function rows(a, file, submittedAt) {
  return [
    ...(a.reference ? [['Reference', a.reference]] : []),
    ['Application Type', KINDS[a.kind].label],
    ['Position', a.position],
    ['Full Name', a.fullName],
    ['Email Address', a.email],
    ['Mobile Number', a.mobile],
    ['Education', a.education],
    ['Résumé', `${attachmentName(a, file)} (${formatSize(file.bytes.byteLength)}, attached)`],
    ['Submitted', submittedAt],
  ];
}

function formatSize(bytes) {
  return bytes >= 1024 * 1024 ? `${(bytes / (1024 * 1024)).toFixed(1)} MB` : `${Math.max(1, Math.round(bytes / 1024))} KB`;
}

export function buildApplicationText(a, file, submittedAt) {
  const title = `${KINDS[a.kind].subject} – YODYNIX`;
  const lines = [title, '='.repeat(title.length), ''];
  for (const [label, value] of rows(a, file, submittedAt)) lines.push(`${label}: ${value}`);
  lines.push('', 'Relevant Skills:', '-'.repeat(16), a.skills);
  lines.push('', 'Additional Message:', '-'.repeat(19), a.message || 'Not provided');
  lines.push('', '—', 'Sent from the Careers page on yodynix.it.com.', `Reply to this email to respond directly to ${a.fullName}.`);
  return lines.join('\n');
}

function block(label, text) {
  const body = text ? escapeHtml(text).replace(/\n/g, '<br>') : '<span style="color:#9a948a;">Not provided</span>';
  return `<tr><td style="padding:18px 28px 0;">
    <div style="font-size:13px;color:#6b665e;margin-bottom:8px;">${escapeHtml(label)}</div>
    <div style="font-size:14px;line-height:1.6;color:#2a2826;background:#faf7f1;border:1px solid #ece4d6;border-left:3px solid #c6a46a;border-radius:8px;padding:14px 16px;word-break:break-word;">${body}</div>
  </td></tr>`;
}

export function buildApplicationHtml(a, file, submittedAt) {
  const kind = KINDS[a.kind];
  const tableRows = rows(a, file, submittedAt)
    .map(([label, value]) => {
      let cell = escapeHtml(value);
      if (label === 'Email Address') cell = `<a href="mailto:${escapeHtml(a.email)}" style="color:#8a6a35;text-decoration:none;">${cell}</a>`;
      if (label === 'Mobile Number') cell = `<a href="tel:${escapeHtml(a.mobile.replace(/[^\d+]/g, ''))}" style="color:#8a6a35;text-decoration:none;">${cell}</a>`;
      return `<tr>
  <td style="padding:10px 0;border-bottom:1px solid #efe8dc;width:36%;vertical-align:top;font-size:13px;color:#6b665e;">${escapeHtml(label)}</td>
  <td style="padding:10px 0 10px 12px;border-bottom:1px solid #efe8dc;vertical-align:top;font-size:14px;font-weight:600;color:#2a2826;word-break:break-word;">${cell}</td>
</tr>`;
    })
    .join('\n');

  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<title>${escapeHtml(applicationSubject(a))}</title>
</head>
<body style="margin:0;padding:0;background:#f4efe6;font-family:Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4efe6;padding:24px 12px;">
<tr><td align="center">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #e6dccb;">
  <tr><td style="background:#2a2826;padding:26px 28px 22px;">
    <div style="font-size:22px;font-weight:800;letter-spacing:3px;color:#ffffff;">YODYNIX</div>
    <div style="font-size:12px;color:#e3cfa3;margin-top:4px;letter-spacing:0.4px;">Careers</div>
  </td></tr>
  <tr><td style="height:4px;background:#c6a46a;background-image:linear-gradient(90deg,#a98245,#e3cfa3);font-size:0;line-height:0;">&nbsp;</td></tr>
  <tr><td style="padding:26px 28px 8px;">
    <div style="font-size:12px;font-weight:700;letter-spacing:1.4px;color:#a98245;text-transform:uppercase;">${escapeHtml(kind.label)}</div>
    <div style="font-size:20px;font-weight:700;color:#2a2826;margin-top:6px;">${escapeHtml(a.position)}</div>
    <div style="font-size:13px;color:#6b665e;margin-top:6px;">Submitted through the Careers page on yodynix.it.com. The résumé is attached.</div>
  </td></tr>
  <tr><td style="padding:8px 28px 4px;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
${tableRows}
    </table>
  </td></tr>
  ${block('Relevant Skills', a.skills)}
  ${block('Additional Message', a.message)}
  <tr><td style="padding:22px 28px 28px;">
    <a href="mailto:${escapeHtml(a.email)}?subject=${encodeURIComponent(`Re: Your application for ${a.position} – YODYNIX`)}" style="display:inline-block;background:#c6a46a;color:#2a2826;font-size:14px;font-weight:700;text-decoration:none;padding:11px 20px;border-radius:8px;">Reply to ${escapeHtml(a.fullName)}</a>
  </td></tr>
  <tr><td style="background:#faf7f1;padding:14px 28px;font-size:12px;color:#9a948a;border-top:1px solid #efe8dc;">
    Replying to this email goes straight to the applicant (Reply-To is set to their address).
  </td></tr>
</table>
</td></tr>
</table>
</body>
</html>`;
}

/**
 * Full RFC 5322 message with CRLF line endings: multipart/mixed holding the
 * text and HTML notification and the résumé as an attachment.
 * [a] and [file] must already be validated.
 */
export function buildApplicationMessage(a, file, { from, to, now = new Date(), submitted = now, messageIdDomain = 'yodynix.it.com' }) {
  const submittedAt = formatSubmittedAt(submitted);
  const mixed = `yodynix-mixed-${crypto.randomUUID()}`;
  const alt = `yodynix-alt-${crypto.randomUUID()}`;
  const replyName = a.fullName.replace(/["\\]/g, '');
  const filename = attachmentName(a, file);
  const headers = [
    `From: ${encodeHeaderWord('YODYNIX Careers')} <${from}>`,
    `To: <${to}>`,
    `Reply-To: ${/^[\x20-\x7e]*$/.test(replyName) ? `"${replyName}"` : encodeHeaderWord(replyName)} <${a.email}>`,
    `Subject: ${encodeHeaderWord(applicationSubject(a))}`,
    `Date: ${now.toUTCString().replace('GMT', '+0000')}`,
    `Message-ID: <${crypto.randomUUID()}@${messageIdDomain}>`,
    'MIME-Version: 1.0',
    'X-Mailer: YODYNIX Contact Worker',
    `Content-Type: multipart/mixed; boundary="${mixed}"`,
  ];
  const body = [
    `--${mixed}`,
    `Content-Type: multipart/alternative; boundary="${alt}"`,
    '',
    `--${alt}`,
    'Content-Type: text/plain; charset=UTF-8',
    'Content-Transfer-Encoding: base64',
    '',
    base64Lines(buildApplicationText(a, file, submittedAt)),
    `--${alt}`,
    'Content-Type: text/html; charset=UTF-8',
    'Content-Transfer-Encoding: base64',
    '',
    base64Lines(buildApplicationHtml(a, file, submittedAt)),
    `--${alt}--`,
    `--${mixed}`,
    `Content-Type: ${file.mime}; name="${filename}"`,
    `Content-Disposition: attachment; filename="${filename}"`,
    'Content-Transfer-Encoding: base64',
    '',
    bytesBase64Lines(file.bytes),
    `--${mixed}--`,
    '',
  ];
  return [...headers, '', ...body].join('\r\n');
}
