/** Porte de lib/models/portfolio_position.dart — posição consolidada de um ativo. */

import type { AssetCategory } from './operation';

export type PortfolioPosition = {
  asset: string;
  category: AssetCategory;
  quantity: number;
  totalInvested: number;
  avgPrice: number;
};

export function profitLoss(position: PortfolioPosition, currentPrice: number): number {
  return (currentPrice - position.avgPrice) * position.quantity;
}

export function profitLossPercent(position: PortfolioPosition, currentPrice: number): number {
  if (position.avgPrice <= 0) return 0;
  return ((currentPrice - position.avgPrice) / position.avgPrice) * 100;
}

export function currentValue(position: PortfolioPosition, currentPrice: number): number {
  return currentPrice * position.quantity;
}
