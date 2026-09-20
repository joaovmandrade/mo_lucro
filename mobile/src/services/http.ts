/**
 * Equivalente ao `.timeout(Duration(seconds: 10))` que os services Dart usavam
 * em cima do package:http. O fetch do RN não tem timeout próprio.
 */
export async function fetchWithTimeout(
  url: string,
  init: RequestInit = {},
  timeoutMs = 10_000,
): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);

  try {
    return await fetch(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}
