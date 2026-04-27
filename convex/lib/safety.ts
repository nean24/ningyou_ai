const maxMessageLength = 8000;

export function sanitizeMessageContent(content: string) {
  const normalized = content.replace(/\r\n/g, "\n").trim();

  if (normalized.length === 0) {
    throw new Error("Message is empty");
  }

  if (normalized.length > maxMessageLength) {
    throw new Error(`Message exceeds ${maxMessageLength} characters`);
  }

  return normalized;
}

export function sanitizeOptionalText(content: string | undefined) {
  if (content === undefined) {
    return undefined;
  }

  const normalized = content.replace(/\r\n/g, "\n").trim();
  return normalized.length === 0 ? undefined : normalized;
}
