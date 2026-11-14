// Server-side validation for enquiry submissions. Mirrors the Flutter form's
// rules but never relies on them: every field is re-checked and cleaned here.

export const CONTACT_METHODS = ['Email', 'Phone Call', 'WhatsApp'];

const EMAIL_PATTERN = /^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.[A-Za-z]{2,}$/;

/** Single-line text: no control characters at all (blocks header injection). */
function cleanLine(value) {
  if (typeof value !== 'string') return '';
  return value
    .normalize('NFC')
    .replace(/[\p{Cc}\p{Zl}\p{Zp}]+/gu, ' ')
    .replace(/\s{2,}/g, ' ')
    .trim();
}

/** Multi-line text: keeps line breaks, drops every other control character. */
function cleanBlock(value) {
  if (typeof value !== 'string') return '';
  return value
    .normalize('NFC')
    .replace(/\r\n?/g, '\n')
    .replace(/\t/g, ' ')
    .replace(/(?!\n)[\p{Cc}\p{Zl}\p{Zp}]/gu, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

/**
 * @returns {{ ok: true, data: object } | { ok: false, errors: Record<string, string> }}
 */
export function validateEnquiry(body) {
  if (body === null || typeof body !== 'object' || Array.isArray(body)) {
    return { ok: false, errors: { _: 'Expected a JSON object' } };
  }

  const data = {
    fullName: cleanLine(body.fullName),
    businessName: cleanLine(body.businessName),
    email: cleanLine(body.email),
    mobile: cleanLine(body.mobile),
    service: cleanLine(body.service),
    budget: cleanLine(body.budget),
    description: cleanBlock(body.description),
    preferredContactMethod: cleanLine(body.preferredContactMethod),
  };
  const errors = {};

  if (data.fullName.length < 2 || data.fullName.length > 100) errors.fullName = 'Full name must be 2–100 characters';
  if (data.businessName.length > 150) errors.businessName = 'Business name must be at most 150 characters';
  if (data.email.length > 254 || !EMAIL_PATTERN.test(data.email)) errors.email = 'A valid email address is required';

  const digits = data.mobile.replace(/\D/g, '');
  if (!/^[\d+\-\s()]{7,30}$/.test(data.mobile) || digits.length < 7 || digits.length > 15) {
    errors.mobile = 'A valid mobile number is required';
  }

  if (data.service.length < 2 || data.service.length > 120) errors.service = 'A service is required';
  if (data.budget.length > 120) errors.budget = 'Budget must be at most 120 characters';
  if (data.description.length < 20 || data.description.length > 1500) {
    errors.description = 'Project description must be 20–1500 characters';
  }
  if (!CONTACT_METHODS.includes(data.preferredContactMethod)) {
    errors.preferredContactMethod = 'Preferred contact method is invalid';
  }

  return Object.keys(errors).length ? { ok: false, errors } : { ok: true, data };
}
