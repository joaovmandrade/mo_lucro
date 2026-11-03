/// <reference types="jest" />
// Os serviços importam o cliente do Supabase; nos testes ele não é usado.
jest.mock('@/lib/supabase', () => ({ supabase: {}, requireUserId: jest.fn() }));
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock'),
);
jest.mock('expo-print', () => ({ printToFileAsync: jest.fn(), printAsync: jest.fn() }));
jest.mock('expo-sharing', () => ({ isAvailableAsync: jest.fn(), shareAsync: jest.fn() }));

import { accumulateSince } from '@/services/benchmarkService';
import { classify } from '@/services/profileService';
import { buildReportHtml, type ReportData } from '@/services/reportService';

describe('perfil do investidor (RF-010)', () => {
  it.each([
    [[0, 0, 0, 0, 0, 0], 'conservative', 0],
    [[1, 1, 1, 1, 0, 0], 'conservative', 4],
    [[1, 1, 1, 1, 1, 0], 'moderate', 5],
    [[2, 2, 2, 2, 0, 0], 'moderate', 8],
    [[2, 2, 2, 2, 1, 0], 'aggressive', 9],
    [[2, 2, 2, 2, 2, 2], 'aggressive', 12],
  ])('respostas %j → %s (pontuação %d)', (answers, profile, score) => {
    expect(classify(answers)).toEqual({ profile, score });
  });
});

describe('CDI e IPCA acumulados (RF-008)', () => {
  const rates = [
    { month: new Date(2026, 0, 1), percent: 1 },
    { month: new Date(2026, 1, 1), percent: 1 },
    { month: new Date(2026, 2, 1), percent: 1 },
  ];

  it('considera apenas os meses completos após a compra', () => {
    const result = accumulateSince(rates, new Date(2026, 0, 15));
    expect(result.months).toBe(2);
    expect(result.percent).toBeCloseTo(2.01, 10);
    expect(result.lastMonth).toEqual(new Date(2026, 2, 1));
  });

  it('não há comparação para compras feitas no último mês publicado', () => {
    const result = accumulateSince(rates, new Date(2026, 2, 10));
    expect(result).toEqual({ percent: 0, months: 0, lastMonth: null });
  });
});

describe('relatório em PDF (RF-012)', () => {
  const base: ReportData = {
    generatedAt: new Date(2026, 10, 3),
    email: 'investidor@exemplo.com',
    positions: [
      { asset: 'PETR4', category: 'stocks', quantity: 10, totalInvested: 300, avgPrice: 30 },
    ],
    invested: 300,
    distribution: { stocks: 100 },
    history: [
      { date: new Date(2026, 9, 31), label: 'out/26', value: 0 },
      { date: new Date(2026, 10, 3), label: 'nov/26', value: 300 },
    ],
    monthIncome: 5000,
    monthExpense: 3200,
    goals: [],
    profileLabel: 'Moderado',
  };

  it('inclui os totais, as posições e o perfil', () => {
    const html = buildReportHtml(base);
    expect(html).toContain('PETR4');
    expect(html).toContain('Perfil Moderado');
    expect(html).toContain('Nenhuma meta cadastrada.');
    expect(html.replace(/\s/g, ' ')).toContain('R$ 1.800,00'); // saldo do mês
  });

  it('escapa texto digitado pelo usuário', () => {
    const html = buildReportHtml({
      ...base,
      goals: [
        {
          id: 'g1',
          userId: 'u1',
          title: '<img src=x onerror=alert(1)>',
          targetValue: 1000,
          currentValue: 100,
          deadline: null,
          createdAt: new Date(),
        },
      ],
    });
    expect(html).not.toContain('<img src=x');
    expect(html).toContain('&lt;img src=x onerror=alert(1)&gt;');
  });
});
