import { Easing } from 'react-native-reanimated';

/**
 * Movimento do app: uma curva só (saída suave, sem quique) e poucas durações.
 * Entradas sobem poucos pixels; o toque responde com uma mudança de superfície
 * ou uma leve redução de escala.
 */
export const motion = {
  ease: Easing.bezier(0.22, 1, 0.36, 1),
  /** Entradas de tela e troca de etapa. */
  enter: 400,
  /** Distância da subida/deslize na entrada, em px. */
  rise: 8,
  /** Escala ao pressionar botões compactos. */
  pressScale: 0.97,
} as const;
