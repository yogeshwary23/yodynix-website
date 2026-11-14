// Builds the enquiry notification: a multipart/alternative message with a
// branded HTML part and a plain-text part. All user content is HTML-escaped.

import { base64Lines, encodeHeaderWord } from './encoding.js';

export const SUBJECT = 'New Project Enquiry – YODYNIX';

const NOT_PROVIDED = 'Not provided';

export function escapeHtml(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

/** "14 November 2026, 8:11 pm IST" */
export function formatSubmittedAt(date) {
  const text = new Intl.DateTimeFormat('en-IN', {
    timeZone: 'Asia/Kolkata',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  }).format(date);
  return `${text} IST`;
}

function rows(e, submittedAt) {
  return [
    ['Customer Name', e.fullName],
    ['Business Name', e.businessName || NOT_PROVIDED],
    ['Customer Email', e.email],
    ['Mobile Number', e.mobile],
    ['Required Service', e.service],
    ['Project Budget', e.budget || NOT_PROVIDED],
    ['Preferred Contact Method', e.preferredContactMethod],
    ['Submitted', submittedAt],
  ];
}

export function buildText(e, submittedAt) {
  const lines = ['New Project Enquiry – YODYNIX', '='.repeat(30), ''];
  for (const [label, value] of rows(e, submittedAt)) lines.push(`${label}: ${value}`);
  lines.push('', 'Project Description:', '-'.repeat(20), e.description, '', '—', 'Sent from the enquiry form on yodynix.it.com.', `Reply to this email to respond directly to ${e.fullName}.`);
  return lines.join('\n');
}

export function buildHtml(e, submittedAt) {
  const tableRows = rows(e, submittedAt)
    .map(([label, value]) => {
      let cell = escapeHtml(value);
      if (label === 'Customer Email') cell = `<a href="mailto:${escapeHtml(e.email)}" style="color:#2346C8;text-decoration:none;">${cell}</a>`;
      if (label === 'Mobile Number') cell = `<a href="tel:${escapeHtml(e.mobile.replace(/[^\d+]/g, ''))}" style="color:#2346C8;text-decoration:none;">${cell}</a>`;
      const muted = value === NOT_PROVIDED ? 'color:#8a94ab;' : 'color:#101A35;';
      return `<tr>
  <td style="padding:10px 0;border-bottom:1px solid #e6eaf3;width:38%;vertical-align:top;font-size:13px;color:#5b6784;">${escapeHtml(label)}</td>
  <td style="padding:10px 0 10px 12px;border-bottom:1px solid #e6eaf3;vertical-align:top;font-size:14px;font-weight:600;${muted}word-break:break-word;">${cell}</td>
</tr>`;
    })
    .join('\n');

  const description = escapeHtml(e.description).replace(/\n/g, '<br>');

  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<title>${escapeHtml(SUBJECT)}</title>
</head>
<body style="margin:0;padding:0;background:#eef1f7;font-family:Segoe UI,Roboto,Helvetica,Arial,sans-serif;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#eef1f7;padding:24px 12px;">
<tr><td align="center">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:600px;background:#ffffff;border-radius:14px;overflow:hidden;border:1px solid #dde3ef;">
  <tr><td style="background:#0A1022;padding:26px 28px 22px;">
    <div style="font-size:22px;font-weight:800;letter-spacing:3px;color:#ffffff;">YODYNIX</div>
    <div style="font-size:12px;color:#8CCFFF;margin-top:4px;letter-spacing:0.4px;">Digital Technology &amp; Innovation Studio</div>
  </td></tr>
  <tr><td style="height:4px;background:#386BFF;background-image:linear-gradient(90deg,#386BFF,#00D4FF);font-size:0;line-height:0;">&nbsp;</td></tr>
  <tr><td style="padding:26px 28px 8px;">
    <div style="font-size:20px;font-weight:700;color:#101A35;">New Project Enquiry</div>
    <div style="font-size:13px;color:#5b6784;margin-top:6px;">Submitted through the enquiry form on yodynix.it.com</div>
  </td></tr>
  <tr><td style="padding:8px 28px 4px;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
${tableRows}
    </table>
  </td></tr>
  <tr><td style="padding:18px 28px 6px;">
    <div style="font-size:13px;color:#5b6784;margin-bottom:8px;">Project Description</div>
    <div style="font-size:14px;line-height:1.6;color:#101A35;background:#f5f7fc;border:1px solid #e6eaf3;border-left:3px solid #386BFF;border-radius:8px;padding:14px 16px;word-break:break-word;">${description}</div>
  </td></tr>
  <tr><td style="padding:20px 28px 28px;">
    <a href="mailto:${escapeHtml(e.email)}?subject=${encodeURIComponent('Re: Your project enquiry – YODYNIX')}" style="display:inline-block;background:#386BFF;color:#ffffff;font-size:14px;font-weight:600;text-decoration:none;padding:11px 20px;border-radius:8px;">Reply to ${escapeHtml(e.fullName)}</a>
  </td></tr>
  <tr><td style="background:#f5f7fc;padding:14px 28px;font-size:12px;color:#8a94ab;border-top:1px solid #e6eaf3;">
    Replying to this email goes straight to the customer (Reply-To is set to their address).
  </td></tr>
</table>
</td></tr>
</table>
</body>
</html>`;
}

/**
 * Full RFC 5322 message with CRLF line endings.
 * [e] must already be validated — its email and name contain no line breaks.
 */
export function buildMessage(e, { from, to, now = new Date(), messageIdDomain = 'yodynix.it.com' }) {
  const submittedAt = formatSubmittedAt(now);
  const boundary = `yodynix-${crypto.randomUUID()}`;
  const replyName = e.fullName.replace(/["\\]/g, '');
  const headers = [
    `From: ${encodeHeaderWord('YODYNIX Website')} <${from}>`,
    `To: <${to}>`,
    // ASCII names are quoted; others become an (unquoted) encoded-word, per RFC 2047.
    `Reply-To: ${/^[\x20-\x7e]*$/.test(replyName) ? `"${replyName}"` : encodeHeaderWord(replyName)} <${e.email}>`,
    `Subject: ${encodeHeaderWord(SUBJECT)}`,
    `Date: ${now.toUTCString().replace('GMT', '+0000')}`,
    `Message-ID: <${crypto.randomUUID()}@${messageIdDomain}>`,
    'MIME-Version: 1.0',
    'X-Mailer: YODYNIX Contact Worker',
    `Content-Type: multipart/alternative; boundary="${boundary}"`,
  ];
  const body = [
    `--${boundary}`,
    'Content-Type: text/plain; charset=UTF-8',
    'Content-Transfer-Encoding: base64',
    '',
    base64Lines(buildText(e, submittedAt)),
    `--${boundary}`,
    'Content-Type: text/html; charset=UTF-8',
    'Content-Transfer-Encoding: base64',
    '',
    base64Lines(buildHtml(e, submittedAt)),
    `--${boundary}--`,
    '',
  ];
  return [...headers, '', ...body].join('\r\n');
}
