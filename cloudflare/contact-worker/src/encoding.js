/** Base64 of the UTF-8 bytes of [text]. */
export function base64(text) {
  const bytes = new TextEncoder().encode(text);
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}

/** Base64 wrapped at 76 characters per line, as MIME bodies require. */
export function base64Lines(text) {
  return base64(text).replace(/.{1,76}/g, '$&\r\n').trimEnd();
}

/** Base64 of raw bytes (e.g. an attachment), wrapped at 76 characters per line. */
export function bytesBase64Lines(bytes) {
  let binary = '';
  // Chunked so large files never exceed the engine's argument limit.
  for (let i = 0; i < bytes.length; i += 0x8000) binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  return btoa(binary).replace(/.{1,76}/g, '$&\r\n').trimEnd();
}

/** RFC 2047 encoded-word, so non-ASCII header text (e.g. "–") survives. */
export function encodeHeaderWord(text) {
  return /^[\x20-\x7e]*$/.test(text) ? text : `=?UTF-8?B?${base64(text)}?=`;
}
