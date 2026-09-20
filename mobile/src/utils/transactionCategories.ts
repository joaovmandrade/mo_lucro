import type { MaterialIcons } from '@expo/vector-icons';

/**
 * Ícones e rótulos das categorias de transação — porte de
 * TransactionTile._categoryIcon e _categoryLabel.
 */

type IconName = keyof typeof MaterialIcons.glyphMap;

export function transactionCategoryIcon(category: string, isIncome: boolean): IconName {
  if (isIncome) {
    switch (category) {
      case 'salary':
        return 'work-outline';
      case 'investment':
        return 'trending-up';
      case 'bonus':
        return 'stars';
      default:
        return 'arrow-upward';
    }
  }

  switch (category) {
    case 'food':
      return 'restaurant';
    case 'transport':
      return 'directions-car';
    case 'health':
      return 'local-hospital';
    case 'education':
      return 'school';
    case 'entertainment':
      return 'movie';
    case 'housing':
      return 'home';
    case 'utilities':
      return 'bolt';
    case 'shopping':
      return 'shopping-bag';
    default:
      return 'receipt-long';
  }
}

const LABELS: Record<string, string> = {
  salary: 'Salário',
  investment: 'Investimento',
  bonus: 'Bônus',
  food: 'Alimentação',
  transport: 'Transporte',
  health: 'Saúde',
  education: 'Educação',
  entertainment: 'Lazer',
  housing: 'Moradia',
  utilities: 'Utilidades',
  shopping: 'Compras',
};

export function transactionCategoryLabel(category: string): string {
  return LABELS[category] ?? 'Outros';
}
