import { useState } from 'react';
import { StyleSheet, Text, View, type LayoutChangeEvent } from 'react-native';
import Svg, { Circle, Defs, LinearGradient, Path, Stop } from 'react-native-svg';

import { colors, radius } from '@/theme';

/**
 * Porte de lib/widgets/patrimonio_line_chart.dart.
 *
 * O fl_chart desenhava a série com `isCurved: true` e `curveSmoothness: 0.35`;
 * aqui a mesma curva é montada à mão em SVG (ver `buildCurvePath`).
 */

const CHART_HEIGHT = 88;
/** O fl_chart reservava 22px embaixo para os rótulos do eixo X. */
const AXIS_HEIGHT = 22;
const PLOT_HEIGHT = CHART_HEIGHT - AXIS_HEIGHT;
const DOT_RADIUS = 3;
const SMOOTHNESS = 0.35;

export function PatrimonioLineChart({
  isLoading = false,
  totalInvested = 0,
}: {
  isLoading?: boolean;
  totalInvested?: number;
}) {
  const [width, setWidth] = useState(0);

  function onLayout(event: LayoutChangeEvent) {
    setWidth(event.nativeEvent.layout.width);
  }

  if (isLoading) return <View style={styles.skeleton} />;

  const base = totalInvested > 0 ? totalInvested : 10000;
  const values = [base * 0.92, base * 0.88, base * 0.91, base * 0.95, base * 0.98, base];
  const labels = last6Labels();

  // Espaço para o raio do ponto não ser cortado nas bordas.
  const left = DOT_RADIUS;
  const right = Math.max(width - DOT_RADIUS, DOT_RADIUS);
  const top = DOT_RADIUS;
  const bottom = PLOT_HEIGHT - DOT_RADIUS;

  const min = Math.min(...values);
  const max = Math.max(...values);
  const span = max - min || 1;

  const points = values.map((value, index) => ({
    x: left + ((right - left) * index) / (values.length - 1),
    // O eixo Y do SVG cresce para baixo, por isso a inversão.
    y: bottom - ((value - min) / span) * (bottom - top),
  }));

  const curve = buildCurvePath(points);
  // Fecha a curva até a base para pintar a área com gradiente.
  const area = `${curve} L ${points[points.length - 1].x} ${PLOT_HEIGHT} L ${points[0].x} ${PLOT_HEIGHT} Z`;

  return (
    <View style={styles.container} onLayout={onLayout}>
      {width > 0 ? (
        <Svg width={width} height={PLOT_HEIGHT}>
          <Defs>
            <LinearGradient id="patrimonioArea" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor={colors.primary} stopOpacity={0.12} />
              <Stop offset="1" stopColor={colors.primary} stopOpacity={0} />
            </LinearGradient>
          </Defs>

          <Path d={area} fill="url(#patrimonioArea)" />
          <Path
            d={curve}
            stroke={colors.primary}
            strokeWidth={2}
            strokeLinecap="round"
            strokeLinejoin="round"
            fill="none"
          />

          {points.map((point, index) => (
            <Circle
              key={labels[index]}
              cx={point.x}
              cy={point.y}
              r={DOT_RADIUS}
              fill={colors.primary}
            />
          ))}
        </Svg>
      ) : (
        <View style={{ height: PLOT_HEIGHT }} />
      )}

      <View style={styles.axis}>
        {labels.map((label) => (
          <Text key={label} style={styles.label}>
            {label}
          </Text>
        ))}
      </View>
    </View>
  );
}

type Point = { x: number; y: number };

/**
 * Curva cúbica com a mesma fórmula do fl_chart: cada par de pontos vira um
 * segmento de Bézier cujos controles seguem a direção dos vizinhos, escalada
 * pelo fator de suavização.
 */
function buildCurvePath(points: Point[]): string {
  if (points.length === 0) return '';
  if (points.length === 1) return `M ${points[0].x} ${points[0].y}`;

  let path = `M ${points[0].x} ${points[0].y}`;

  for (let i = 0; i < points.length - 1; i++) {
    const previous = points[i - 1] ?? points[i];
    const current = points[i];
    const next = points[i + 1];
    const afterNext = points[i + 2] ?? next;

    const control1 = {
      x: current.x + (next.x - previous.x) * SMOOTHNESS,
      y: current.y + (next.y - previous.y) * SMOOTHNESS,
    };
    const control2 = {
      x: next.x - (afterNext.x - current.x) * SMOOTHNESS,
      y: next.y - (afterNext.y - current.y) * SMOOTHNESS,
    };

    path += ` C ${control1.x} ${control1.y}, ${control2.x} ${control2.y}, ${next.x} ${next.y}`;
  }

  return path;
}

/** Os 6 últimos dias em dd/MM, como _last6Labels. */
function last6Labels(): string[] {
  const now = new Date();
  const labels: string[] = [];

  for (let i = 5; i >= 0; i--) {
    const date = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    labels.push(`${day}/${month}`);
  }

  return labels;
}

const styles = StyleSheet.create({
  skeleton: {
    height: CHART_HEIGHT,
    backgroundColor: colors.bg3,
    borderRadius: radius.sm,
  },
  container: { height: CHART_HEIGHT },
  axis: {
    height: AXIS_HEIGHT,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingTop: 4,
  },
  label: { color: colors.textMuted, fontSize: 9 },
});
