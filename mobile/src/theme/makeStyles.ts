import { StyleSheet, type TextStyle } from 'react-native';

import { useTheme } from '@/contexts/ThemeContext';

import type { Palette } from './colors';
import { fonts } from './typography';

/**
 * No RN o peso de uma fonte customizada vem do arquivo carregado, não de
 * fontWeight (no Android, fontWeight com fontFamily customizada é ignorado).
 * Por isso cada estilo de texto recebe a família Inter do peso pedido.
 *
 * A escala de pesos segue a tipografia do app: 400 para texto, 500 para
 * rótulos e valores, 600 para títulos e ênfase. Pesos 700 a 900 viram 600.
 */
function familyFor(weight: TextStyle['fontWeight']): string {
  const numeric = weight === 'bold' ? 700 : Number(weight ?? 400);
  if (numeric >= 600) return fonts.semiBold;
  if (numeric >= 500) return fonts.medium;
  return fonts.regular;
}

const NUMERIC_STYLE = /value|amount|total|percent|price|balance|rate|final|return|figure|count/i;

function withInter<T extends Record<string, any>>(styles: T): T {
  const out: Record<string, any> = {};
  for (const [name, style] of Object.entries(styles)) {
    const isText = style && ('fontSize' in style || 'fontWeight' in style);
    if (isText && !('fontFamily' in style)) {
      const { fontWeight, ...rest } = style;
      // Algarismos de largura fixa só em estilos de número, para valores em
      // coluna alinharem (no texto comum eles alargam hífens e pontuação).
      const numeric = NUMERIC_STYLE.test(name) ? { fontVariant: ['tabular-nums'] } : {};
      out[name] = { ...numeric, ...rest, fontFamily: familyFor(fontWeight) };
    } else {
      out[name] = style;
    }
  }
  return out as T;
}

/**
 * Cria um hook de estilos dependente do tema:
 *
 *   const useStyles = makeStyles((colors) => ({ screen: { backgroundColor: colors.bg0 } }));
 *   function Tela() { const styles = useStyles(); ... }
 *
 * Os estilos de cada paleta são criados uma única vez e reaproveitados.
 */
export function makeStyles<T extends StyleSheet.NamedStyles<T>>(
  factory: (colors: Palette) => T,
): () => T {
  const cache = new Map<Palette, T>();

  return function useStyles(): T {
    const { colors } = useTheme();
    let styles = cache.get(colors);
    if (!styles) {
      styles = StyleSheet.create(withInter(factory(colors)));
      cache.set(colors, styles);
    }
    return styles;
  };
}
