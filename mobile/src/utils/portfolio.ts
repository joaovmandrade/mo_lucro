import type { Operation, PortfolioPosition } from '@/models';

/** Porte de lib/utils/portfolio_utils.dart. */

type MutablePosition = {
  asset: string;
  category: Operation['category'];
  quantity: number;
  totalInvested: number;
};

/**
 * Consolida as operações em posições, corrigindo o preço médio nas vendas.
 * Ordena da mais antiga para a mais nova — o preço médio depende da ordem.
 */
export function calculatePortfolio(operations: Operation[]): Record<string, PortfolioPosition> {
  const mutable = new Map<string, MutablePosition>();

  const sorted = [...operations].sort((a, b) => a.date.getTime() - b.date.getTime());

  for (const op of sorted) {
    let position = mutable.get(op.asset);
    if (!position) {
      position = { asset: op.asset, category: op.category, quantity: 0, totalInvested: 0 };
      mutable.set(op.asset, position);
    }

    if (op.type === 'buy') {
      position.quantity += op.quantity;
      position.totalInvested += op.total;
    } else if (op.type === 'sell') {
      // Usa o preço médio atual quando há posição; senão, o preço da venda.
      const avgPrice =
        position.quantity > 0 ? position.totalInvested / position.quantity : op.price;
      position.quantity -= op.quantity;
      position.totalInvested -= avgPrice * op.quantity;
      // Sem clamp — posição negativa (venda a descoberto) continua visível.
    }
  }

  const result: Record<string, PortfolioPosition> = {};
  for (const [asset, position] of mutable) {
    if (Math.abs(position.quantity) > 0.0001) {
      const { quantity, totalInvested: invested } = position;
      result[asset] = {
        asset,
        category: position.category,
        quantity,
        totalInvested: invested,
        avgPrice: quantity !== 0 ? invested / quantity : 0,
      };
    }
  }

  return result;
}

export function totalInvested(portfolio: Record<string, PortfolioPosition>): number {
  return Object.values(portfolio).reduce((sum, p) => sum + p.totalInvested, 0);
}

/** Distribuição por categoria, em percentual do total investido. */
export function categoryDistribution(
  portfolio: Record<string, PortfolioPosition>,
): Record<string, number> {
  const categories: Record<string, number> = {};
  let total = 0;

  for (const position of Object.values(portfolio)) {
    categories[position.category] = (categories[position.category] ?? 0) + position.totalInvested;
    total += position.totalInvested;
  }

  if (total === 0) return {};

  return Object.fromEntries(
    Object.entries(categories).map(([key, value]) => [key, (value / total) * 100]),
  );
}
