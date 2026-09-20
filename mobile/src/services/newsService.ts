import { fetchWithTimeout } from './http';

/** Porte de lib/services/new_service.dart. */

export type NewsItem = {
  category: string;
  ticker: string | null;
  headline: string;
  sub: string;
  timeAgo: string;
  url?: string | null;
  imageUrl?: string | null;
  source?: string | null;
  isFeatured: boolean;
};

const TICKERS = [
  'PETR4', 'VALE3', 'ITUB4', 'BBDC4', 'ABEV3', 'B3SA3', 'WEGE3',
  'RENT3', 'RADL3', 'MGLU3', 'MXRF11', 'HGLG11', 'KNRI11', 'VISC11',
];

function extractTicker(text: string): string | null {
  const upper = text.toUpperCase();
  return TICKERS.find((t) => upper.includes(t)) ?? null;
}

function inferCategory(text: string): string {
  const lower = text.toLowerCase();
  if (lower.includes('fii') || lower.includes('fundo imobiliario') || lower.includes('cota'))
    return 'fiis';
  if (lower.includes('dividendo') || lower.includes('jcp') || lower.includes('proventos'))
    return 'dividends';
  if (
    lower.includes('selic') || lower.includes('inflacao') || lower.includes('ipca') ||
    lower.includes('pib') || lower.includes('copom')
  )
    return 'economy';
  if (
    lower.includes('guerra') || lower.includes('oriente') ||
    lower.includes('china') || lower.includes('petroleo')
  )
    return 'geo';
  return 'market';
}

function formatTimeAgo(iso: string): string {
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return '';

  const diffMs = Date.now() - date.getTime();
  const minutes = Math.floor(diffMs / 60_000);
  if (minutes < 60) return `há ${minutes} min`;

  const hours = Math.floor(diffMs / 3_600_000);
  if (hours < 24) return `há ${hours} h`;

  return `há ${Math.floor(diffMs / 86_400_000)} d`;
}

function newsItemFromApi(json: Record<string, any>, index: number): NewsItem {
  // Remove o sufixo " - Nome do Veículo" que a NewsAPI acrescenta ao título.
  const title = String(json.title ?? '').replace(/\s*-\s*[^-]+$/, '');
  const description = String(json.description ?? '');

  return {
    category: inferCategory(title + description),
    ticker: extractTicker(title),
    headline: title,
    sub: description.length > 0 ? description : 'Toque para ler mais.',
    timeAgo: formatTimeAgo(String(json.publishedAt ?? '')),
    url: json.url ?? null,
    imageUrl: json.urlToImage ?? null,
    source: json.source?.name ?? '',
    isFeatured: index === 0,
  };
}

// 🔑 NewsAPI key (newsapi.org) — o plano Developer só responde em
// localhost/emulador, não em dispositivo físico em produção.
const API_KEY = process.env.EXPO_PUBLIC_NEWS_API_KEY ?? 'a12538a4596c42fe9221d38f17e8e65a';
const BASE_URL = 'https://newsapi.org/v2';

const QUERY_BY_CATEGORY: Record<string, string> = {
  all: 'mercado financeiro brasil',
  geo: 'geopolitica petroleo brasil',
  fiis: 'fundos imobiliarios brasil',
  dividends: 'dividendos acoes brasil',
  economy: 'selic inflacao brasil',
};

export async function fetchNews(category = 'all'): Promise<NewsItem[]> {
  try {
    const items = await fetchFromNewsApi(category);
    return items.length > 0 ? items : mockNews(category);
  } catch (error) {
    console.warn('[NewsService] erro:', error, '— usando mock');
    return mockNews(category);
  }
}

async function fetchFromNewsApi(category: string): Promise<NewsItem[]> {
  const rawQuery = QUERY_BY_CATEGORY[category] ?? QUERY_BY_CATEGORY.all;
  const query = encodeURIComponent(rawQuery);
  const url = `${BASE_URL}/everything?q=${query}&language=pt&sortBy=publishedAt&pageSize=10&apiKey=${API_KEY}`;

  const response = await fetchWithTimeout(url);

  if (!response.ok) {
    throw new Error(`NewsAPI error ${response.status}: ${await response.text()}`);
  }

  const decoded = await response.json();

  // A NewsAPI devolve status "ok" ou "error" no corpo mesmo com HTTP 200.
  if (decoded?.status !== 'ok') {
    throw new Error(decoded?.message ?? 'NewsAPI error');
  }

  const articles: any[] = decoded.articles ?? [];
  return articles.map(newsItemFromApi);
}

function mockNews(category: string): NewsItem[] {
  const all: NewsItem[] = [
    {
      category: 'dividends', ticker: 'PETR4',
      headline: 'Petrobras anuncia dividendos de R$ 2,50 por ação',
      sub: 'Valor será pago em maio aos acionistas registrados.',
      timeAgo: 'há 2 h', isFeatured: true,
    },
    {
      category: 'dividends', ticker: 'VALE3',
      headline: 'Vale bate recorde de produção no 4º trimestre',
      sub: 'Resultado acima do esperado pelo mercado.',
      timeAgo: 'há 4 h', isFeatured: false,
    },
    {
      category: 'economy', ticker: null,
      headline: 'Selic deve subir 0,5% na próxima reunião do Copom',
      sub: 'Analistas revisam projeção de inflação para cima.',
      timeAgo: 'há 5 h', isFeatured: false,
    },
    {
      category: 'dividends', ticker: 'ITUB4',
      headline: 'Itaú reporta lucro líquido de R$ 9,8 bilhões',
      sub: 'Crescimento de 15% sobre o mesmo período do ano anterior.',
      timeAgo: 'há 6 h', isFeatured: false,
    },
    {
      category: 'fiis', ticker: 'MXRF11',
      headline: 'MXRF11 anuncia distribuição de R$ 0,10/cota',
      sub: 'Yield mensal de 0,95% sobre o valor de mercado.',
      timeAgo: 'há 8 h', isFeatured: false,
    },
    {
      category: 'geo', ticker: null,
      headline: 'Tensões no Oriente Médio pressionam petróleo',
      sub: 'Brent sobe 2% com incertezas geopolíticas.',
      timeAgo: 'há 10 h', isFeatured: false,
    },
    {
      category: 'economy', ticker: 'BBDC4',
      headline: 'Banco do Brasil eleva guidance de crédito para 2025',
      sub: 'Carteira deve crescer entre 9% e 13%.',
      timeAgo: 'há 12 h', isFeatured: false,
    },
  ];

  if (category === 'all') return all;
  return all.filter((n) => n.category === category);
}
