import * as Print from 'expo-print';
import * as Sharing from 'expo-sharing';
import { Platform } from 'react-native';

import { goalProgressPercent, type Goal, type PortfolioPosition } from '@/models';
import { categoryLabels } from '@/utils/categories';
import { patrimonyHistory, type PatrimonyPoint } from '@/utils/finance';
import { currency, dateFull } from '@/utils/formatters';
import { calculatePortfolio, categoryDistribution, totalInvested } from '@/utils/portfolio';

import * as goalService from './goalService';
import * as operationService from './operationService';
import * as profileService from './profileService';
import * as transactionService from './transactionService';

/**
 * RF-012 — relatório do patrimônio em PDF. O HTML é montado por uma função
 * pura (buildReportHtml) e convertido em PDF pelo expo-print; em seguida o
 * arquivo é aberto na folha de compartilhamento do sistema.
 */

export type ReportData = {
  generatedAt: Date;
  email: string | null;
  positions: PortfolioPosition[];
  invested: number;
  distribution: Record<string, number>;
  history: PatrimonyPoint[];
  monthIncome: number;
  monthExpense: number;
  goals: Goal[];
  profileLabel: string | null;
};

const PROFILE_LABELS: Record<profileService.InvestorProfileType, string> = {
  conservative: 'Conservador',
  moderate: 'Moderado',
  aggressive: 'Arrojado',
};

/** Escapa texto digitado pelo usuário (nomes de ativos e metas) antes de ir para o HTML. */
function esc(text: string): string {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

const pct = (value: number) => `${value.toFixed(1).replace('.', ',')}%`;

export function buildReportHtml(data: ReportData): string {
  const balance = data.monthIncome - data.monthExpense;
  const maxHistory = Math.max(...data.history.map((p) => p.value), 1);

  const positionRows = data.positions
    .sort((a, b) => b.totalInvested - a.totalInvested)
    .map(
      (p) => `<tr>
        <td><b>${esc(p.asset)}</b></td>
        <td>${esc(categoryLabels[p.category] ?? p.category)}</td>
        <td class="num">${p.quantity.toLocaleString('pt-BR', { maximumFractionDigits: 8 })}</td>
        <td class="num">${currency(p.avgPrice)}</td>
        <td class="num">${currency(p.totalInvested)}</td>
        <td class="num">${pct(data.invested > 0 ? (p.totalInvested / data.invested) * 100 : 0)}</td>
      </tr>`,
    )
    .join('');

  const distributionRows = Object.entries(data.distribution)
    .sort(([, a], [, b]) => b - a)
    .map(
      ([category, share]) => `<div class="bar-row">
        <span class="bar-label">${esc(categoryLabels[category] ?? category)}</span>
        <span class="bar-track"><span class="bar-fill" style="width:${share.toFixed(1)}%"></span></span>
        <span class="bar-value">${pct(share)}</span>
      </div>`,
    )
    .join('');

  const historyRows = data.history
    .map(
      (p) => `<div class="bar-row">
        <span class="bar-label">${p.label}</span>
        <span class="bar-track"><span class="bar-fill" style="width:${((p.value / maxHistory) * 100).toFixed(1)}%"></span></span>
        <span class="bar-value">${currency(p.value)}</span>
      </div>`,
    )
    .join('');

  const goalRows = data.goals
    .map(
      (g) => `<tr>
        <td>${esc(g.title)}</td>
        <td class="num">${currency(g.currentValue)}</td>
        <td class="num">${currency(g.targetValue)}</td>
        <td class="num">${pct(goalProgressPercent(g))}</td>
      </tr>`,
    )
    .join('');

  return `<!doctype html>
<html lang="pt-BR"><head><meta charset="utf-8" />
<style>
  * { box-sizing: border-box; }
  body { font-family: -apple-system, Roboto, Helvetica, Arial, sans-serif; color: #111827; margin: 32px; font-size: 12px; }
  h1 { font-size: 22px; margin: 0; color: #1D4ED8; }
  h2 { font-size: 14px; margin: 24px 0 8px; padding-bottom: 4px; border-bottom: 1px solid #E5E7EB; }
  .muted { color: #6B7280; }
  .cards { display: flex; gap: 12px; margin-top: 16px; }
  .card { flex: 1; border: 1px solid #E5E7EB; border-radius: 8px; padding: 10px 12px; }
  .card .label { color: #6B7280; font-size: 10px; text-transform: uppercase; letter-spacing: .04em; }
  .card .value { font-size: 16px; font-weight: 700; margin-top: 2px; }
  table { width: 100%; border-collapse: collapse; }
  th { text-align: left; font-size: 10px; color: #6B7280; text-transform: uppercase; padding: 6px 4px; border-bottom: 1px solid #E5E7EB; }
  td { padding: 6px 4px; border-bottom: 1px solid #F3F4F6; }
  .num { text-align: right; font-variant-numeric: tabular-nums; }
  .bar-row { display: flex; align-items: center; gap: 8px; margin: 4px 0; }
  .bar-label { width: 90px; }
  .bar-track { flex: 1; height: 8px; background: #F3F4F6; border-radius: 4px; overflow: hidden; }
  .bar-fill { display: block; height: 8px; background: #2563EB; }
  .bar-value { width: 110px; text-align: right; font-variant-numeric: tabular-nums; }
  .pos { color: #047857; } .neg { color: #B91C1C; }
  footer { margin-top: 32px; font-size: 10px; color: #9CA3AF; }
</style></head>
<body>
  <h1>Mo Lucro — Relatório do Patrimônio</h1>
  <div class="muted">Gerado em ${dateFull(data.generatedAt)}${data.email ? ` · ${esc(data.email)}` : ''}${
    data.profileLabel ? ` · Perfil ${data.profileLabel}` : ''
  }</div>

  <div class="cards">
    <div class="card"><div class="label">Total investido</div><div class="value">${currency(data.invested)}</div></div>
    <div class="card"><div class="label">Ativos</div><div class="value">${data.positions.length}</div></div>
    <div class="card"><div class="label">Saldo do mês</div><div class="value ${balance >= 0 ? 'pos' : 'neg'}">${currency(balance)}</div></div>
  </div>

  <h2>Carteira</h2>
  ${
    data.positions.length > 0
      ? `<table><thead><tr><th>Ativo</th><th>Categoria</th><th class="num">Qtd.</th><th class="num">Preço médio</th><th class="num">Investido</th><th class="num">% carteira</th></tr></thead><tbody>${positionRows}</tbody></table>`
      : '<p class="muted">Nenhuma posição em aberto.</p>'
  }

  <h2>Distribuição por categoria</h2>
  ${distributionRows || '<p class="muted">Sem dados.</p>'}

  <h2>Evolução do valor investido (6 meses)</h2>
  ${historyRows}

  <h2>Receitas e despesas do mês</h2>
  <table><tbody>
    <tr><td>Receitas</td><td class="num pos">${currency(data.monthIncome)}</td></tr>
    <tr><td>Despesas</td><td class="num neg">${currency(data.monthExpense)}</td></tr>
    <tr><td><b>Saldo</b></td><td class="num"><b>${currency(balance)}</b></td></tr>
  </tbody></table>

  <h2>Metas</h2>
  ${
    data.goals.length > 0
      ? `<table><thead><tr><th>Meta</th><th class="num">Atual</th><th class="num">Alvo</th><th class="num">Progresso</th></tr></thead><tbody>${goalRows}</tbody></table>`
      : '<p class="muted">Nenhuma meta cadastrada.</p>'
  }

  <footer>Valores baseados no custo de aquisição informado pelo usuário, sem marcação a mercado. Documento gerado pelo aplicativo Mo Lucro para uso pessoal; não constitui recomendação de investimento.</footer>
</body></html>`;
}

export async function loadReportData(email: string | null): Promise<ReportData> {
  const now = new Date();
  const [operations, summary, goals, profile] = await Promise.all([
    operationService.getOperations(),
    transactionService.getMonthSummary(now.getFullYear(), now.getMonth() + 1),
    goalService.getGoals(),
    profileService.getProfile().catch(() => null),
  ]);

  const portfolio = calculatePortfolio(operations);

  return {
    generatedAt: now,
    email,
    positions: Object.values(portfolio).filter((p) => p.quantity > 0),
    invested: totalInvested(portfolio),
    distribution: categoryDistribution(portfolio),
    history: patrimonyHistory(operations, 6, now),
    monthIncome: summary.income,
    monthExpense: summary.expense,
    goals,
    profileLabel: profile ? PROFILE_LABELS[profile.profile] : null,
  };
}

/** Gera o PDF e abre o compartilhamento. Retorna o caminho do arquivo gerado. */
export async function exportReport(email: string | null): Promise<string | null> {
  const html = buildReportHtml(await loadReportData(email));

  // Na web não há arquivo local: abre a impressão do navegador ("Salvar como PDF").
  if (Platform.OS === 'web') {
    await Print.printAsync({ html });
    return null;
  }

  const { uri } = await Print.printToFileAsync({ html });

  if (await Sharing.isAvailableAsync()) {
    await Sharing.shareAsync(uri, {
      mimeType: 'application/pdf',
      dialogTitle: 'Relatório Mo Lucro',
      UTI: 'com.adobe.pdf',
    });
  }

  return uri;
}
