import { MaterialCommunityIcons } from '@expo/vector-icons';
import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Animated, { FadeIn } from 'react-native-reanimated';
import Svg, { G, Path, Text as SvgText } from 'react-native-svg';

import { chartColors, colors, fonts } from '@/theme';

/**
 * Porte de lib/widgets/portfolio_donut_chart.dart.
 *
 * O fl_chart montava o anel com `centerSpaceRadius: 60`, fatias de raio 46 (54
 * quando tocadas) e `sectionsSpace: 3`. Aqui as fatias são paths de SVG com os
 * mesmos números, desenhados num viewBox que comporta o raio da fatia tocada.
 */

const CENTER_RADIUS = 60;
const SECTION_RADIUS = 46;
const TOUCHED_RADIUS = 54;
/** Lado do viewBox: cabe a maior fatia sem cortar. */
const VIEWBOX = (CENTER_RADIUS + TOUCHED_RADIUS) * 2;
const CENTER = VIEWBOX / 2;
/** O `sectionsSpace: 3` do fl_chart é uma folga em pixels; aqui vira ângulo. */
const GAP_DEGREES = (3 / (CENTER_RADIUS + SECTION_RADIUS / 2)) * (180 / Math.PI);
/** Altura que o Flutter reservava para o anel. */
const CHART_HEIGHT = 200;

const LABELS: Record<string, string> = {
  stocks: 'Ações',
  crypto: 'Cripto',
  fixed_income: 'Renda Fixa',
  others: 'Outros',
};

export function PortfolioDonutChart({ distribution }: { distribution: Record<string, number> }) {
  const [touchedIndex, setTouchedIndex] = useState(-1);

  const entries = Object.entries(distribution);

  if (entries.length === 0) {
    return (
      <View style={styles.empty}>
        <MaterialCommunityIcons name="chart-donut" size={40} color={colors.textMuted} />
        <Text style={styles.emptyText}>Nenhum ativo ainda</Text>
      </View>
    );
  }

  const touched = touchedIndex >= 0 && touchedIndex < entries.length ? entries[touchedIndex] : null;

  const total = entries.reduce((sum, [, percent]) => sum + percent, 0) || 1;
  let cursor = 0;

  const sections = entries.map(([category, percent], index) => {
    const sweep = (percent / total) * 360;
    const start = cursor;
    cursor += sweep;

    const isTouched = index === touchedIndex;
    const outerRadius = CENTER_RADIUS + (isTouched ? TOUCHED_RADIUS : SECTION_RADIUS);

    // Uma fatia única não tem vizinha, então não leva folga.
    const gap = entries.length > 1 ? Math.min(GAP_DEGREES, sweep / 2) : 0;

    return {
      category,
      percent,
      index,
      color: chartColors[index % chartColors.length],
      startAngle: start + gap / 2,
      endAngle: start + sweep - gap / 2,
      midAngle: start + sweep / 2,
      outerRadius,
      labelRadius: CENTER_RADIUS + (isTouched ? TOUCHED_RADIUS : SECTION_RADIUS) / 2,
    };
  });

  return (
    <View>
      <View style={styles.donutArea}>
        <Svg width={CHART_HEIGHT} height={CHART_HEIGHT} viewBox={`0 0 ${VIEWBOX} ${VIEWBOX}`}>
          <G>
            {sections.map((section) => (
              <Path
                key={section.category}
                d={donutSlicePath(
                  section.startAngle,
                  section.endAngle,
                  CENTER_RADIUS,
                  section.outerRadius,
                )}
                fill={section.color}
                onPress={() =>
                  setTouchedIndex((current) => (current === section.index ? -1 : section.index))
                }
              />
            ))}

            {/* O fl_chart só escrevia o rótulo dentro da fatia acima de 8%. */}
            {sections
              .filter((section) => section.percent >= 8)
              .map((section) => {
                const position = polarToCartesian(section.midAngle, section.labelRadius);
                return (
                  <SvgText
                    key={`label-${section.category}`}
                    x={position.x}
                    y={position.y}
                    fill="#FFFFFF"
                    fontSize={11}
                    fontFamily={fonts.bold}
                    textAnchor="middle"
                    alignmentBaseline="middle"
                  >
                    {`${section.percent.toFixed(0)}%`}
                  </SvgText>
                );
              })}
          </G>
        </Svg>

        {/* O AnimatedSwitcher do Flutter trocava esse texto com 200ms de fade. */}
        <Animated.View
          key={touched ? touched[0] : 'total'}
          entering={FadeIn.duration(200)}
          style={styles.center}
          pointerEvents="none"
        >
          {touched ? (
            <>
              <Text style={styles.centerPercent}>{touched[1].toFixed(1)}%</Text>
              <Text style={styles.centerLabel}>{LABELS[touched[0]] ?? touched[0]}</Text>
            </>
          ) : (
            <>
              <Text style={styles.centerLabel}>Carteira</Text>
              <Text style={styles.centerTotal}>
                {entries.length} {entries.length === 1 ? 'ativo' : 'ativos'}
              </Text>
            </>
          )}
        </Animated.View>
      </View>

      <View style={styles.legend}>
        {entries.map(([category, percent], index) => (
          <Pressable
            key={category}
            style={styles.legendItem}
            onPress={() => setTouchedIndex(index === touchedIndex ? -1 : index)}
          >
            <View
              style={[
                styles.legendDot,
                { backgroundColor: chartColors[index % chartColors.length] },
              ]}
            />
            <Text style={styles.legendText}>
              {LABELS[category] ?? category} {percent.toFixed(1)}%
            </Text>
          </Pressable>
        ))}
      </View>
    </View>
  );
}

/** 0° é a posição das 3 horas e o ângulo cresce no sentido horário. */
function polarToCartesian(angleDegrees: number, radius: number) {
  const radians = (angleDegrees * Math.PI) / 180;
  return {
    x: CENTER + radius * Math.cos(radians),
    y: CENTER + radius * Math.sin(radians),
  };
}

/** Anel entre dois raios, de startAngle a endAngle. */
function donutSlicePath(
  startAngle: number,
  endAngle: number,
  innerRadius: number,
  outerRadius: number,
): string {
  const sweep = endAngle - startAngle;

  // Um anel completo não pode ser um único arco: o SVG fecharia no mesmo ponto.
  if (sweep >= 359.99) {
    return [
      `M ${CENTER - outerRadius} ${CENTER}`,
      `A ${outerRadius} ${outerRadius} 0 1 1 ${CENTER + outerRadius} ${CENTER}`,
      `A ${outerRadius} ${outerRadius} 0 1 1 ${CENTER - outerRadius} ${CENTER}`,
      `M ${CENTER - innerRadius} ${CENTER}`,
      `A ${innerRadius} ${innerRadius} 0 1 0 ${CENTER + innerRadius} ${CENTER}`,
      `A ${innerRadius} ${innerRadius} 0 1 0 ${CENTER - innerRadius} ${CENTER}`,
      'Z',
    ].join(' ');
  }

  const largeArc = sweep > 180 ? 1 : 0;

  const outerStart = polarToCartesian(startAngle, outerRadius);
  const outerEnd = polarToCartesian(endAngle, outerRadius);
  const innerEnd = polarToCartesian(endAngle, innerRadius);
  const innerStart = polarToCartesian(startAngle, innerRadius);

  return [
    `M ${outerStart.x} ${outerStart.y}`,
    `A ${outerRadius} ${outerRadius} 0 ${largeArc} 1 ${outerEnd.x} ${outerEnd.y}`,
    `L ${innerEnd.x} ${innerEnd.y}`,
    `A ${innerRadius} ${innerRadius} 0 ${largeArc} 0 ${innerStart.x} ${innerStart.y}`,
    'Z',
  ].join(' ');
}

const styles = StyleSheet.create({
  empty: {
    height: 160,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyText: { marginTop: 8, color: colors.textMuted, fontSize: 13 },
  donutArea: {
    height: CHART_HEIGHT,
    alignItems: 'center',
    justifyContent: 'center',
  },
  center: { position: 'absolute', alignItems: 'center' },
  centerPercent: { color: colors.textPrimary, fontSize: 20, fontWeight: '800' },
  centerLabel: { color: colors.textSecondary, fontSize: 11, fontWeight: '500' },
  centerTotal: { marginTop: 2, color: colors.textPrimary, fontSize: 16, fontWeight: '700' },
  legend: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginTop: 16,
    gap: 16,
  },
  legendItem: { flexDirection: 'row', alignItems: 'center' },
  legendDot: { width: 8, height: 8, borderRadius: 4 },
  legendText: {
    marginLeft: 5,
    color: colors.textSecondary,
    fontSize: 12,
    fontWeight: '500',
  },
});
