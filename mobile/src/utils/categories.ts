import type { AssetCategory } from '@/models';
import { colors } from '@/theme';

/**
 * Rótulos e cores de categoria. No Flutter isso estava duplicado em
 * asset_card.dart, portfolio_page.dart e add_operation_page.dart — aqui fica
 * em um lugar só.
 */

/** Nome longo, como em AssetCard._categoryLabel. */
export const categoryLabels: Record<string, string> = {
  stocks: 'Ações',
  crypto: 'Criptomoedas',
  fixed_income: 'Renda Fixa',
  fiis: 'FIIs',
  others: 'Outros',
};

/** Nome curto da tag, como em _CategoryTag._label. */
export const categoryTagLabels: Record<string, string> = {
  stocks: 'Ações',
  crypto: 'Cripto',
  fixed_income: 'Renda Fixa',
  fiis: 'FIIs',
  others: 'Outros',
};

export function categoryLabel(category: string): string {
  return categoryLabels[category] ?? 'Outros';
}

export function categoryTagLabel(category: string): string {
  return categoryTagLabels[category] ?? 'Outros';
}

/** Cor do avatar — o default é textSecondary, como em _Avatar._color. */
export function categoryColor(category: string): string {
  switch (category) {
    case 'stocks':
      return colors.primary;
    case 'crypto':
      return colors.warning;
    case 'fixed_income':
      return colors.profit;
    case 'fiis':
      return colors.accent;
    default:
      return colors.textSecondary;
  }
}

/** Cor da tag — igual à do avatar, exceto o default, que é textMuted. */
export function categoryTagColor(category: string): string {
  return category in categoryLabels && category !== 'others'
    ? categoryColor(category)
    : colors.textMuted;
}

/** Razão social conhecida; cai no rótulo da categoria, como em _companyName. */
const COMPANY_NAMES: Record<string, string> = {
  PETR4: 'Petrobras',
  VALE3: 'Vale',
  ITUB4: 'Itaú Unibanco',
  BBDC4: 'Bradesco',
  MGLU3: 'Magazine Luiza',
  WEGE3: 'Weg',
  ABEV3: 'Ambev',
};

export function companyName(asset: string, category: AssetCategory | string): string {
  return COMPANY_NAMES[asset] ?? categoryLabel(category);
}

/** Inteiro quando não há fração, senão 2 casas — como _quantityLabel. */
export function quantityLabel(quantity: number): string {
  return quantity % 1 === 0 ? String(Math.trunc(quantity)) : quantity.toFixed(2);
}
