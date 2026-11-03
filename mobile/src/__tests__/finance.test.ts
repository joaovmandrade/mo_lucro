/// <reference types="jest" />
import type { Operation } from '@/models';
import {
  accumulatePercent,
  compoundFutureValue,
  monthlyRateFromAnnual,
  patrimonyHistory,
  percentOfBenchmark,
} from '@/utils/finance';

function op(partial: Partial<Operation> & Pick<Operation, 'type' | 'date'>): Operation {
  return {
    id: Math.random().toString(36),
    userId: 'u1',
    asset: 'PETR4',
    category: 'stocks',
    quantity: 10,
    price: 100,
    total: 1000,
    ...partial,
  };
}

describe('juros compostos (RF-006)', () => {
  it('converte taxa anual na mensal equivalente', () => {
    // 12,68% a.a. ≈ 1% a.m.
    expect(monthlyRateFromAnnual(Math.pow(1.01, 12) - 1)).toBeCloseTo(0.01, 10);
  });

  it('capitaliza o valor inicial sem aportes', () => {
    // Taxa mensal equivalente: 12 meses a 12% a.a. resultam exatamente em 12%.
    expect(compoundFutureValue({ initial: 1000, monthly: 0, months: 12, annualRate: 0.12 })).toBeCloseTo(
      1120,
      6,
    );
  });

  it('soma aportes mensais com rendimento composto (série uniforme)', () => {
    const annualRate = Math.pow(1.01, 12) - 1;
    const expected = 100 * ((Math.pow(1.01, 12) - 1) / 0.01); // ≈ 1268,25
    expect(compoundFutureValue({ initial: 0, monthly: 100, months: 12, annualRate })).toBeCloseTo(
      expected,
      6,
    );
  });

  it('rende mais que juros simples no longo prazo', () => {
    const composto = compoundFutureValue({ initial: 10000, monthly: 0, months: 120, annualRate: 0.1 });
    const simples = 10000 * (1 + 0.1 * 10);
    expect(composto).toBeGreaterThan(simples);
    expect(composto).toBeCloseTo(10000 * Math.pow(1.1, 10), 4);
  });

  it('com taxa zero devolve só o que foi aportado', () => {
    expect(compoundFutureValue({ initial: 1000, monthly: 100, months: 12, annualRate: 0 })).toBe(2200);
  });

  it('com prazo zero devolve o valor inicial', () => {
    expect(compoundFutureValue({ initial: 1000, monthly: 100, months: 0, annualRate: 0.1 })).toBe(1000);
  });
});

describe('indicadores (RF-008)', () => {
  it('acumula taxas mensais de forma composta', () => {
    expect(accumulatePercent([1, 1])).toBeCloseTo(2.01, 10);
    expect(accumulatePercent([])).toBe(0);
    expect(accumulatePercent([0.5, -0.32, 0.82])).toBeCloseTo((1.005 * 0.9968 * 1.0082 - 1) * 100, 10);
  });

  it('calcula o rendimento como percentual do indicador', () => {
    expect(percentOfBenchmark(12, 10)).toBeCloseTo(120);
    expect(percentOfBenchmark(5, 0)).toBeNull();
  });
});

describe('evolução do patrimônio (RF-005)', () => {
  const now = new Date(2026, 10, 3); // 03/11/2026

  it('gera um ponto por mês com o valor investido até aquela data', () => {
    const history = patrimonyHistory(
      [
        op({ type: 'buy', date: new Date(2026, 7, 10), total: 1000 }), // ago
        op({ type: 'buy', date: new Date(2026, 9, 5), asset: 'VALE3', total: 500, quantity: 5 }), // out
      ],
      6,
      now,
    );

    expect(history.map((p) => p.label)).toEqual([
      'jun/26',
      'jul/26',
      'ago/26',
      'set/26',
      'out/26',
      'nov/26',
    ]);
    expect(history.map((p) => p.value)).toEqual([0, 0, 1000, 1000, 1500, 1500]);
  });

  it('reduz o valor investido após uma venda, pelo preço médio', () => {
    const history = patrimonyHistory(
      [
        op({ type: 'buy', date: new Date(2026, 8, 1), quantity: 10, price: 100, total: 1000 }),
        op({ type: 'sell', date: new Date(2026, 9, 1), quantity: 4, price: 150, total: 600 }),
      ],
      3,
      now,
    );
    expect(history.map((p) => p.value)).toEqual([1000, 600, 600]);
  });

  it('ignora operações futuras em relação à data de referência', () => {
    const history = patrimonyHistory(
      [op({ type: 'buy', date: new Date(2026, 10, 20), total: 1000 })],
      2,
      now,
    );
    expect(history.map((p) => p.value)).toEqual([0, 0]);
  });
});
