/**
 * Paleta portada de mo_lucro_app/lib/core/theme.dart (AppColors).
 * Os valores ARGB do Flutter viram hex/rgba aqui — mesma cor, mesma ordem.
 */

export const lightColors = {
  // ── Backgrounds (light theme) ──────────────────────────────
  bg0: '#ECEEF2',
  bg1: '#FFFFFF',
  bg2: '#FFFFFF',
  bg3: '#F3F4F6',
  bg4: '#E5E7EB',

  surfaceGlass: 'rgba(255, 255, 255, 0.98)',
  surfaceElevated: '#FFFFFF',
  surfacePressed: '#F3F4F6',

  // ── Brand ──────────────────────────────────────────────────
  primary: '#2563EB',
  primaryDim: '#1D4ED8',
  profit: '#10B981',
  profitDark: '#047857',
  loss: '#EF4444',
  warning: '#F59E0B',
  accent: '#10B981',
  purple: '#7C3AED',

  accentBlue: '#2563EB',
  accentGreen: '#10B981',
  accentRed: '#EF4444',
  accentOrange: '#F59E0B',
  accentPurple: '#7C3AED',
  accentTeal: '#06B6D4',

  // ── Text ───────────────────────────────────────────────────
  textPrimary: '#111827',
  textSecondary: '#6B7280',
  textMuted: '#9CA3AF',

  // Texto sobre o header azul
  textOnBlue: '#FFFFFF',
  textOnBlueDim: '#DBEAFE',
  textOnBlueReturn: '#6EE7B7',
  textOnBlueProfit: '#10B981',

  // ── Borders ────────────────────────────────────────────────
  border: '#E5E7EB',
  borderLight: '#F3F4F6',
  badgeBg: 'rgba(0, 0, 0, 0.06)',
};

/** Mesmas chaves da paleta clara — as telas trocam de tema sem mudar código. */
export type Palette = { [K in keyof typeof lightColors]: string };

/**
 * Paleta escura (RNF-005). As cores de marca e de ganho/perda mudam pouco,
 * só o suficiente para manter contraste sobre fundo escuro.
 */
export const darkColors: Palette = {
  bg0: '#0B1120',
  bg1: '#111827',
  bg2: '#161F2E',
  bg3: '#1F2937',
  bg4: '#2A3647',

  surfaceGlass: 'rgba(22, 31, 46, 0.98)',
  surfaceElevated: '#1B2536',
  surfacePressed: '#1F2937',

  primary: '#3B82F6',
  primaryDim: '#2563EB',
  profit: '#34D399',
  profitDark: '#10B981',
  loss: '#F87171',
  warning: '#FBBF24',
  accent: '#34D399',
  purple: '#A78BFA',

  accentBlue: '#3B82F6',
  accentGreen: '#34D399',
  accentRed: '#F87171',
  accentOrange: '#FBBF24',
  accentPurple: '#A78BFA',
  accentTeal: '#22D3EE',

  textPrimary: '#F3F4F6',
  textSecondary: '#A1A9B8',
  textMuted: '#6B7280',

  textOnBlue: '#FFFFFF',
  textOnBlueDim: '#DBEAFE',
  textOnBlueReturn: '#6EE7B7',
  textOnBlueProfit: '#34D399',

  border: '#263244',
  borderLight: '#1F2937',
  badgeBg: 'rgba(255, 255, 255, 0.08)',
};

/**
 * Paleta clara exportada com o nome antigo para código fora de componentes
 * (ex.: HTML do relatório PDF, que é sempre claro). Telas devem usar useTheme().
 */
export const colors: Palette = lightColors;

/** Cores de série dos gráficos, na mesma ordem de AppColors.chartColors. */
export const chartColors = [
  '#2563EB',
  '#10B981',
  '#F59E0B',
  '#EF4444',
  '#7C3AED',
  '#06B6D4',
] as const;

type GradientStops = {
  colors: readonly [string, string, ...string[]];
  start: { x: number; y: number };
  end: { x: number; y: number };
};

/**
 * Gradientes no formato de <LinearGradient> do expo-linear-gradient.
 * As Alignments do Flutter (-1..1) foram convertidas para coordenadas 0..1.
 */
export const lightGradients = {
  header: {
    colors: ['#2563EB', '#1D4ED8'],
    start: { x: 0.2, y: 0 },
    end: { x: 1, y: 0.8 },
  },
  primary: {
    colors: ['#2563EB', '#1D4ED8'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  card: {
    colors: ['#FFFFFF', '#FAFBFC'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  /** Usado no BalanceCard — fica sobre o header azul, texto branco. */
  hero: {
    colors: ['#2563EB', '#1D4ED8'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
} satisfies Record<string, GradientStops>;

export type Gradients = { [K in keyof typeof lightGradients]: GradientStops };

export const darkGradients: Gradients = {
  header: {
    colors: ['#1E40AF', '#1E3A8A'],
    start: { x: 0.2, y: 0 },
    end: { x: 1, y: 0.8 },
  },
  primary: {
    colors: ['#1D4ED8', '#1E40AF'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  card: {
    colors: ['#161F2E', '#1B2536'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
  hero: {
    colors: ['#1E40AF', '#1E3A8A'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
};

export const gradients: Gradients = lightGradients;
