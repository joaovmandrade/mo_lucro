/**
 * Paleta portada de mo_lucro_app/lib/core/theme.dart (AppColors).
 * Os valores ARGB do Flutter viram hex/rgba aqui — mesma cor, mesma ordem.
 */

export const colors = {
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
} as const;

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
export const gradients = {
  header: {
    colors: ['#2563EB', '#1D4ED8', '#4338CA'],
    start: { x: 0.2, y: 0 },
    end: { x: 1, y: 0.8 },
  },
  primary: {
    colors: ['#2563EB', '#7C3AED'],
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
    colors: ['#2563EB', '#1D4ED8', '#4338CA'],
    start: { x: 0, y: 0 },
    end: { x: 1, y: 1 },
  },
} satisfies Record<string, GradientStops>;
