import { fetchWithTimeout } from './http';

/** Porte de lib/services/market_data_service.dart. */

export type QuoteResult = {
  ticker: string;
  price: number;
  changePercent: number;
  success: boolean;
};

export function emptyQuote(ticker: string): QuoteResult {
  return { ticker, price: 0, changePercent: 0, success: false };
}

const BRAPI_URL = 'https://brapi.dev/api';
const GECKO_URL = 'https://api.coingecko.com/api/v3';

const CACHE_TTL_MS = 5 * 60 * 1000;
const cache = new Map<string, { quote: QuoteResult; at: number }>();

// Mapa de ticker do app → ID do CoinGecko
const CRYPTO_IDS: Record<string, string> = {
  BTC: 'bitcoin',
  ETH: 'ethereum',
  BNB: 'binancecoin',
  SOL: 'solana',
  ADA: 'cardano',
  XRP: 'ripple',
  DOGE: 'dogecoin',
  DOT: 'polkadot',
  MATIC: 'matic-network',
  LTC: 'litecoin',
  USDT: 'tether',
  USDC: 'usd-coin',
};

function cached(ticker: string): QuoteResult | null {
  const hit = cache.get(ticker);
  if (hit && Date.now() - hit.at < CACHE_TTL_MS) return hit.quote;
  return null;
}

function store(ticker: string, quote: QuoteResult): void {
  cache.set(ticker, { quote, at: Date.now() });
}

/** Busca a cotação pelo ticker, escolhendo a fonte conforme a categoria. */
export async function getQuote(ticker: string, category = 'stocks'): Promise<QuoteResult> {
  const upper = ticker.toUpperCase();

  const hit = cached(upper);
  if (hit) return hit;

  try {
    const result = category === 'crypto' ? await fetchCrypto(upper) : await fetchBrapi(upper);
    store(upper, result);
    return result;
  } catch (error) {
    console.warn(`[MarketData] erro para ${upper}:`, error);
    return emptyQuote(upper);
  }
}

// ── BRAPI — Ações e FIIs da B3 ───────────────────────────────
async function fetchBrapi(ticker: string): Promise<QuoteResult> {
  const url = `${BRAPI_URL}/quote/${ticker}?fundamental=false`;
  const response = await fetchWithTimeout(url);

  if (!response.ok) throw new Error(`BRAPI error ${response.status}`);

  const decoded = await response.json();
  const results: any[] = decoded?.results ?? [];
  if (results.length === 0) return emptyQuote(ticker);

  const item = results[0];
  const price = Number(item?.regularMarketPrice ?? 0);
  const changePercent = Number(item?.regularMarketChangePercent ?? 0);

  return { ticker, price, changePercent, success: price > 0 };
}

// ── CoinGecko — Criptomoedas ─────────────────────────────────
async function fetchCrypto(ticker: string): Promise<QuoteResult> {
  const coinId = CRYPTO_IDS[ticker] ?? ticker.toLowerCase();

  const url = `${GECKO_URL}/simple/price?ids=${coinId}&vs_currencies=brl&include_24hr_change=true`;
  const response = await fetchWithTimeout(url, { headers: { Accept: 'application/json' } });

  if (!response.ok) throw new Error(`CoinGecko error ${response.status}`);

  const decoded = await response.json();
  const data = decoded?.[coinId];

  if (!data) {
    console.warn(`[MarketData] CoinGecko: coin "${coinId}" não encontrado`);
    return emptyQuote(ticker);
  }

  const price = Number(data.brl ?? 0);
  const changePercent = Number(data.brl_24h_change ?? 0);

  return { ticker, price, changePercent, success: price > 0 };
}

/** Busca vários tickers de uma vez, separando por fonte. */
export async function getQuotes(
  tickerCategories: Record<string, string>,
): Promise<Record<string, QuoteResult>> {
  const entries = Object.entries(tickerCategories);
  if (entries.length === 0) return {};

  const result: Record<string, QuoteResult> = {};
  const toFetchBrapi: string[] = [];
  const toFetchCrypto: string[] = [];

  for (const [ticker, category] of entries) {
    const upper = ticker.toUpperCase();
    const hit = cached(upper);
    if (hit) result[upper] = hit;
    else if (category === 'crypto') toFetchCrypto.push(upper);
    else toFetchBrapi.push(upper);
  }

  // Lote BRAPI
  if (toFetchBrapi.length > 0) {
    try {
      const url = `${BRAPI_URL}/quote/${toFetchBrapi.join(',')}?fundamental=false`;
      const response = await fetchWithTimeout(url);

      if (response.ok) {
        const decoded = await response.json();
        for (const item of (decoded?.results ?? []) as any[]) {
          const ticker = String(item?.symbol ?? '').toUpperCase();
          const price = Number(item?.regularMarketPrice ?? 0);
          const changePercent = Number(item?.regularMarketChangePercent ?? 0);
          const quote: QuoteResult = { ticker, price, changePercent, success: price > 0 };
          result[ticker] = quote;
          store(ticker, quote);
        }
      }
    } catch (error) {
      console.warn('[MarketData] erro batch BRAPI:', error);
    }
    for (const ticker of toFetchBrapi) {
      result[ticker] ??= emptyQuote(ticker);
    }
  }

  // Lote CoinGecko
  if (toFetchCrypto.length > 0) {
    try {
      const ids = toFetchCrypto.map((t) => CRYPTO_IDS[t] ?? t.toLowerCase()).join(',');
      const url = `${GECKO_URL}/simple/price?ids=${ids}&vs_currencies=brl&include_24hr_change=true`;
      const response = await fetchWithTimeout(url, { headers: { Accept: 'application/json' } });

      if (response.ok) {
        const decoded = await response.json();
        for (const ticker of toFetchCrypto) {
          const coinId = CRYPTO_IDS[ticker] ?? ticker.toLowerCase();
          const data = decoded?.[coinId];
          if (data) {
            const price = Number(data.brl ?? 0);
            const changePercent = Number(data.brl_24h_change ?? 0);
            const quote: QuoteResult = { ticker, price, changePercent, success: price > 0 };
            result[ticker] = quote;
            store(ticker, quote);
          }
        }
      }
    } catch (error) {
      console.warn('[MarketData] erro batch CoinGecko:', error);
    }
    for (const ticker of toFetchCrypto) {
      result[ticker] ??= emptyQuote(ticker);
    }
  }

  return result;
}
