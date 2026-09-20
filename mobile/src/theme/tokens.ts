/** Espaçamento, raio e sombra — porte de AppSpacing / AppRadius / AppShadows. */

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  base: 16,
  lg: 20,
  xl: 24,
  xxl: 32,
  huge: 48,
} as const;

export const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  pill: 100,
} as const;

/**
 * As sombras usam a prop `boxShadow` do RN 0.76+, que aceita múltiplas camadas
 * — é o que permite reproduzir as duas BoxShadow de AppShadows.card.
 * O raio do Flutter (blurRadius) equivale ao blur do CSS.
 */
export const shadows = {
  card: '0px 4px 16px rgba(0, 0, 0, 0.06), 0px 1px 4px rgba(0, 0, 0, 0.04)',
} as const;

/** Equivalente a AppShadows.glow(color) — aceita hex de 6 dígitos. */
export function glow(hexColor: string): string {
  const hex = hexColor.replace('#', '');
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  return `0px 8px 20px rgba(${r}, ${g}, ${b}, 0.18)`;
}

/** Equivalente a Color.withOpacity() do Flutter. Aceita hex de 6 dígitos. */
export function alpha(hexColor: string, opacity: number): string {
  const hex = hexColor.replace('#', '');
  const r = parseInt(hex.slice(0, 2), 16);
  const g = parseInt(hex.slice(2, 4), 16);
  const b = parseInt(hex.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${opacity})`;
}
