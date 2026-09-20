import type { TextStyle } from 'react-native';

import { colors } from './colors';

/**
 * Nomes das famílias registradas em src/app/_layout.tsx via @expo-google-fonts/inter.
 * No RN o peso da fonte vem do arquivo carregado, não de fontWeight — por isso
 * cada peso é uma família própria.
 */
export const fonts = {
  regular: 'Inter_400Regular',
  medium: 'Inter_500Medium',
  semiBold: 'Inter_600SemiBold',
  bold: 'Inter_700Bold',
} as const;

/**
 * Porte do TextTheme de AppTheme.dark. Os nomes seguem o Material do Flutter
 * para que a conversão das telas seja uma substituição direta.
 */
export const typography = {
  displayLarge: {
    color: colors.textPrimary,
    fontSize: 34,
    fontFamily: fonts.bold,
    letterSpacing: 0,
  },
  displayMedium: {
    color: colors.textPrimary,
    fontSize: 27,
    fontFamily: fonts.bold,
    letterSpacing: 0,
  },
  displaySmall: {
    color: colors.textPrimary,
    fontSize: 22,
    fontFamily: fonts.bold,
    letterSpacing: 0,
  },
  headlineLarge: {
    color: colors.textPrimary,
    fontSize: 22,
    fontFamily: fonts.bold,
    letterSpacing: 0,
  },
  headlineMedium: {
    color: colors.textPrimary,
    fontSize: 18,
    fontFamily: fonts.semiBold,
    letterSpacing: 0,
  },
  titleLarge: {
    color: colors.textPrimary,
    fontSize: 16,
    fontFamily: fonts.semiBold,
    letterSpacing: 0,
  },
  titleMedium: {
    color: colors.textPrimary,
    fontSize: 14,
    fontFamily: fonts.semiBold,
    letterSpacing: 0,
  },
  titleSmall: {
    color: colors.textSecondary,
    fontSize: 13,
    fontFamily: fonts.medium,
    letterSpacing: 0,
  },
  bodyLarge: {
    color: colors.textPrimary,
    fontSize: 14,
    fontFamily: fonts.regular,
    lineHeight: 14 * 1.35,
    letterSpacing: 0,
  },
  bodyMedium: {
    color: colors.textSecondary,
    fontSize: 13,
    fontFamily: fonts.regular,
    lineHeight: 13 * 1.35,
    letterSpacing: 0,
  },
  bodySmall: {
    color: colors.textMuted,
    fontSize: 11,
    fontFamily: fonts.regular,
    lineHeight: 11 * 1.3,
    letterSpacing: 0,
  },
  labelLarge: {
    color: colors.textPrimary,
    fontSize: 14,
    fontFamily: fonts.semiBold,
    letterSpacing: 0,
  },
  labelMedium: {
    color: colors.textSecondary,
    fontSize: 12,
    fontFamily: fonts.semiBold,
    letterSpacing: 0,
  },
  labelSmall: {
    color: colors.textMuted,
    fontSize: 10,
    fontFamily: fonts.medium,
    letterSpacing: 0,
  },
} satisfies Record<string, TextStyle>;

export type TypographyVariant = keyof typeof typography;
