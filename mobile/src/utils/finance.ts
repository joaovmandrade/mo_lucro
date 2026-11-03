import type { Operation } from '@/models';

import { calculatePortfolio, totalInvested } from './portfolio';

/**
 * Cálculos financeiros puros (sem rede nem estado), usados pelo simulador
 * (RF-006), pela evolução do patrimônio (RF-005) e pelo comparativo com CDI e
 * IPCA (RF-008). Ficam isolados aqui para serem testáveis.
 */

/** Converte uma taxa anual (0,1375 = 13,75% a.a.) na taxa mensal equivalente. */
export function monthlyRateFromAnnual(annualRate: number): number {
  return Math.pow(1 + annualRate, 1 / 12) - 1;
}

/**
 * Valor futuro com juros compostos e aportes mensais no fim de cada mês:
 *   VF = P·(1+i)^n + PMT·[((1+i)^n − 1) / i]
 */
export function compoundFutureValue(params: {
  initial: number;
  monthly: number;
  months: number;
  annualRate: number;
}): number {
  const { initial, monthly, months, annualRate } = params;
  if (months <= 0) return initial;

  const i = monthlyRateFromAnnual(annualRate);
  const growth = Math.pow(1 + i, months);
  if (i === 0) return initial + monthly * months;

  return initial * growth + monthly * ((growth - 1) / i);
}

/**
 * Acumula taxas mensais em percentual (ex.: [1.07, 1.08]) em um único
 * percentual do período: (1+a)(1+b)… − 1.
 */
export function accumulatePercent(monthlyPercents: number[]): number {
  const factor = monthlyPercents.reduce((acc, pct) => acc * (1 + pct / 100), 1);
  return (factor - 1) * 100;
}

/** Rendimento como percentual do indicador (ex.: 12% contra CDI de 10% → 120% do CDI). */
export function percentOfBenchmark(returnPercent: number, benchmarkPercent: number): number | null {
  if (benchmarkPercent <= 0) return null;
  return (returnPercent / benchmarkPercent) * 100;
}

export type PatrimonyPoint = { date: Date; label: string; value: number };

const MONTH_LABELS = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

/**
 * Série histórica do patrimônio investido (RF-005): para o fim de cada um dos
 * últimos `months` meses, consolida as operações feitas até aquela data e soma
 * o valor investido. Usa o custo de aquisição — o app não guarda cotações
 * históricas, então não há marcação a mercado dos meses passados.
 */
export function patrimonyHistory(
  operations: Operation[],
  months = 6,
  now = new Date(),
): PatrimonyPoint[] {
  const points: PatrimonyPoint[] = [];

  for (let offset = months - 1; offset >= 0; offset--) {
    // Último instante do mês (o dia 0 do mês seguinte é o último dia deste).
    const monthEnd = new Date(now.getFullYear(), now.getMonth() - offset + 1, 0, 23, 59, 59, 999);
    const cutoff = offset === 0 ? now : monthEnd;
    const upToDate = operations.filter((op) => op.date.getTime() <= cutoff.getTime());

    points.push({
      date: cutoff,
      label: `${MONTH_LABELS[monthEnd.getMonth()]}/${String(monthEnd.getFullYear()).slice(2)}`,
      value: totalInvested(calculatePortfolio(upToDate)),
    });
  }

  return points;
}
