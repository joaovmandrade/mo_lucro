import { accumulatePercent } from '@/utils/finance';

import { fetchWithTimeout } from './http';

/**
 * Indicadores de referência (RF-008) obtidos da API pública do Banco Central
 * (SGS — Sistema Gerenciador de Séries Temporais). Não exige chave.
 *
 *   CDI  — série 4391: taxa CDI acumulada no mês, em % a.m.
 *   IPCA — série 433:  variação mensal do IPCA, em %.
 */

export type BenchmarkCode = 'cdi' | 'ipca';

const SERIES: Record<BenchmarkCode, number> = { cdi: 4391, ipca: 433 };

const SGS_URL = 'https://api.bcb.gov.br/dados/serie/bcdata.sgs';

export type MonthlyRate = { month: Date; percent: number };

export type BenchmarkReturn = {
  code: BenchmarkCode;
  /** Variação acumulada no período, em %. */
  percent: number;
  /** Número de meses considerados. */
  months: number;
  /** Último mês com dado publicado (o IPCA sai com cerca de um mês de atraso). */
  lastMonth: Date | null;
};

const CACHE_TTL_MS = 6 * 60 * 60 * 1000;
const cache = new Map<BenchmarkCode, { rates: MonthlyRate[]; at: number }>();

function formatBcbDate(date: Date): string {
  const day = String(date.getDate()).padStart(2, '0');
  const month = String(date.getMonth() + 1).padStart(2, '0');
  return `${day}/${month}/${date.getFullYear()}`;
}

/** "01/10/2026" → Date(2026, 9, 1). */
function parseBcbDate(text: string): Date | null {
  const [day, month, year] = text.split('/').map(Number);
  if (!day || !month || !year) return null;
  return new Date(year, month - 1, day);
}

/** Últimos 10 anos de taxas mensais (a API limita consultas a 10 anos). */
async function fetchMonthlyRates(code: BenchmarkCode): Promise<MonthlyRate[]> {
  const hit = cache.get(code);
  if (hit && Date.now() - hit.at < CACHE_TTL_MS) return hit.rates;

  const now = new Date();
  const start = new Date(now.getFullYear() - 10, now.getMonth(), 1);
  const url =
    `${SGS_URL}.${SERIES[code]}/dados?formato=json` +
    `&dataInicial=${formatBcbDate(start)}&dataFinal=${formatBcbDate(now)}`;

  const response = await fetchWithTimeout(url);
  if (!response.ok) throw new Error(`Banco Central respondeu ${response.status}`);

  const json: unknown = await response.json();
  if (!Array.isArray(json)) throw new Error('Resposta inesperada do Banco Central');

  const rates = json
    .map((row: any) => ({
      month: parseBcbDate(String(row?.data ?? '')),
      percent: Number.parseFloat(String(row?.valor ?? '')),
    }))
    .filter((r): r is MonthlyRate => r.month !== null && Number.isFinite(r.percent))
    .sort((a, b) => a.month.getTime() - b.month.getTime());

  cache.set(code, { rates, at: Date.now() });
  return rates;
}

/**
 * Variação acumulada do indicador desde `since`. Considera os meses completos
 * posteriores ao mês de início: uma compra feita em 15/03 é comparada com o
 * indicador de abril em diante, para não atribuir ao ativo um mês parcial.
 */
export function accumulateSince(rates: MonthlyRate[], since: Date): Omit<BenchmarkReturn, 'code'> {
  const firstMonth = new Date(since.getFullYear(), since.getMonth() + 1, 1);
  const inPeriod = rates.filter((r) => r.month.getTime() >= firstMonth.getTime());

  return {
    percent: accumulatePercent(inPeriod.map((r) => r.percent)),
    months: inPeriod.length,
    lastMonth: inPeriod.length > 0 ? inPeriod[inPeriod.length - 1].month : null,
  };
}

export type BenchmarkSeries = Record<BenchmarkCode, MonthlyRate[]>;

/** Busca CDI e IPCA juntos. Lança erro se algum falhar — a tela mostra o aviso. */
export async function getBenchmarks(): Promise<BenchmarkSeries> {
  const [cdi, ipca] = await Promise.all([fetchMonthlyRates('cdi'), fetchMonthlyRates('ipca')]);
  return { cdi, ipca };
}
