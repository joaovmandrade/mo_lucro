import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { CompoundCalculator } from '@/components/CompoundCalculator';
import {
  getLesson,
  getTrack,
  nextLesson,
  type Block,
  type IconName,
  type Lesson,
} from '@/data/knowledge';
import { useKnowledgeProgress } from '@/lib/knowledgeProgress';
import { alpha, makeStyles, radius, shadows, type Palette } from '@/theme';
import { useTheme } from '@/contexts/ThemeContext';

export default function LessonScreen() {
  const styles = useStyles();
  const { colors, gradients } = useTheme();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const params = useLocalSearchParams<{ id: string }>();
  const { completed, toggle } = useKnowledgeProgress();

  const id = Array.isArray(params.id) ? params.id[0] : params.id;
  const lesson = id ? getLesson(id) : undefined;

  function goBack() {
    if (router.canGoBack()) router.back();
    else router.replace('/knowledge');
  }

  if (!lesson) {
    return (
      <View style={[styles.screen, styles.missing, { paddingTop: insets.top + 16 }]}>
        <MaterialIcons name="menu-book" size={40} color={colors.textMuted} />
        <Text style={styles.missingTitle}>Aula não encontrada</Text>
        <Text style={styles.missingBody}>
          Esse conteúdo pode ter sido movido. Volte para a Base de Conhecimento e escolha outra aula.
        </Text>
        <Pressable style={styles.primaryButton} onPress={goBack}>
          <Text style={styles.primaryButtonText}>Voltar</Text>
        </Pressable>
      </View>
    );
  }

  const track = getTrack(lesson.trackId);
  const done = completed.has(lesson.id);
  const next = nextLesson(lesson.id);

  return (
    <View style={styles.screen}>
      <ScrollView
        keyboardShouldPersistTaps="handled"
        keyboardDismissMode="on-drag"
        automaticallyAdjustKeyboardInsets
        contentContainerStyle={styles.scrollContent}
      >
        <LinearGradient
          colors={gradients.header.colors}
          start={gradients.header.start}
          end={gradients.header.end}
          style={[styles.header, { paddingTop: insets.top + 16 }]}
        >
          <View style={styles.headerTopRow}>
            <Pressable style={styles.circleButton} onPress={goBack} accessibilityLabel="Voltar">
              <MaterialIcons name="arrow-back-ios-new" size={16} color={colors.textOnBlue} />
            </Pressable>
            <Text style={styles.headerTrack} numberOfLines={1}>
              {track?.title}
            </Text>
          </View>

          <Text style={styles.title}>{lesson.title}</Text>
          <Text style={styles.summary}>{lesson.summary}</Text>

          <View style={styles.pills}>
            <View style={styles.pill}>
              <MaterialIcons name="schedule" size={16} color={colors.textOnBlue} />
              <Text style={styles.pillText}>{lesson.minutes} min de leitura</Text>
            </View>
            {done ? (
              <View style={[styles.pill, styles.pillDone]}>
                <MaterialIcons name="check" size={16} color={colors.textOnBlue} />
                <Text style={styles.pillText}>Concluída</Text>
              </View>
            ) : null}
          </View>
        </LinearGradient>

        <View style={styles.body}>
          {lesson.blocks.map((block, index) => (
            <BlockView key={`${lesson.id}-${index}`} block={block} first={index === 0} />
          ))}

          <View style={styles.actions}>
            <Pressable
              onPress={() => toggle(lesson.id)}
              style={({ pressed }) => [
                styles.primaryButton,
                done && styles.doneButton,
                pressed && styles.pressedButton,
              ]}
              accessibilityRole="button"
              accessibilityState={{ selected: done }}
            >
              <MaterialIcons
                name={done ? 'check-circle' : 'check-circle-outline'}
                size={20}
                color={done ? colors.profitDark : '#FFFFFF'}
              />
              <Text style={[styles.primaryButtonText, done && styles.doneButtonText]}>
                {done ? 'Aula concluída' : 'Marcar como concluída'}
              </Text>
            </Pressable>
            {done ? <Text style={styles.undoHint}>Toque de novo para desmarcar</Text> : null}

            {lesson.cta ? (
              <Pressable
                onPress={() => lesson.cta && router.push(lesson.cta.route)}
                style={({ pressed }) => [styles.secondaryButton, pressed && styles.pressedButton]}
                accessibilityRole="button"
              >
                <Text style={styles.secondaryButtonText}>{lesson.cta.label}</Text>
                <MaterialIcons name="arrow-forward" size={18} color={colors.primary} />
              </Pressable>
            ) : null}
          </View>

          {next ? (
            <NextLessonCard
              lesson={next}
              onPress={() =>
                router.replace({ pathname: '/knowledge/[id]', params: { id: next.id } })
              }
            />
          ) : null}

          <Text style={styles.disclaimer}>
            Conteúdo educacional. Não é recomendação de investimento.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Blocos de conteúdo
// ─────────────────────────────────────────────────────────────
type Tone = { color: string; textColor: string; icon: IconName; title: string };

/** Cores dos destaques da aula, conforme o tema (no escuro o texto fica mais claro). */
function tones(colors: Palette, isDark: boolean): Record<'tip' | 'warning' | 'example', Tone> {
  return {
    tip: {
      color: colors.primary,
      textColor: isDark ? '#93C5FD' : colors.primaryDim,
      icon: 'lightbulb-outline',
      title: 'Dica',
    },
    warning: {
      color: colors.warning,
      textColor: isDark ? '#FCD34D' : '#B45309',
      icon: 'warning',
      title: 'Atenção',
    },
    example: {
      color: colors.profit,
      textColor: isDark ? '#6EE7B7' : colors.profitDark,
      icon: 'calculate',
      title: 'Exemplo',
    },
  };
}

function BlockView({ block, first }: { block: Block; first: boolean }) {
  const styles = useStyles();
  const { colors, isDark } = useTheme();
  switch (block.type) {
    case 'p':
      return <Text style={[styles.paragraph, first && styles.noTop]}>{block.text}</Text>;

    case 'h':
      return (
        <Text style={[styles.heading, first && styles.noTop]} accessibilityRole="header">
          {block.text}
        </Text>
      );

    case 'list':
      return (
        <View style={[styles.list, first && styles.noTop]}>
          {block.items.map((item) => (
            <View key={item} style={styles.listItem}>
              <View style={styles.bullet} />
              <Text style={styles.listText}>{item}</Text>
            </View>
          ))}
        </View>
      );

    case 'callout': {
      const tone = tones(colors, isDark)[block.tone];
      return (
        <View
          style={[
            styles.callout,
            first && styles.noTop,
            { backgroundColor: alpha(tone.color, 0.08), borderColor: alpha(tone.color, 0.25) },
          ]}
        >
          <View style={styles.calloutHeader}>
            <MaterialIcons name={tone.icon} size={18} color={tone.textColor} />
            <Text style={[styles.calloutTitle, { color: tone.textColor }]}>
              {block.title ?? tone.title}
            </Text>
          </View>
          <Text style={styles.calloutText}>{block.text}</Text>
        </View>
      );
    }

    case 'table':
      return (
        <View style={[styles.table, first && styles.noTop]}>
          <View style={[styles.tableRow, styles.tableHead]}>
            {block.head.map((cell) => (
              <Text key={cell} style={[styles.tableCell, styles.tableHeadText]}>
                {cell}
              </Text>
            ))}
          </View>
          {block.rows.map((row, rowIndex) => (
            <View
              key={row[0]}
              style={[styles.tableRow, rowIndex < block.rows.length - 1 && styles.tableRowDivider]}
            >
              {row.map((cell, cellIndex) => (
                <Text
                  key={`${row[0]}-${cellIndex}`}
                  style={[styles.tableCell, cellIndex === 0 && styles.tableFirstCell]}
                >
                  {cell}
                </Text>
              ))}
            </View>
          ))}
        </View>
      );

    case 'terms':
      return (
        <View style={[styles.table, first && styles.noTop]}>
          {block.items.map((item, index) => (
            <View
              key={item.term}
              style={[styles.termRow, index < block.items.length - 1 && styles.tableRowDivider]}
            >
              <Text style={styles.termName}>{item.term}</Text>
              <Text style={styles.termDefinition}>{item.definition}</Text>
            </View>
          ))}
        </View>
      );

    case 'calculator':
      return (
        <View style={[styles.calculatorWrap, first && styles.noTop]}>
          <CompoundCalculator />
        </View>
      );
  }
}

function NextLessonCard({ lesson, onPress }: { lesson: Lesson; onPress: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.nextCard, pressed && styles.pressedButton]}
      accessibilityRole="button"
      accessibilityLabel={`Próxima aula: ${lesson.title}`}
    >
      <View style={styles.nextText}>
        <Text style={styles.nextLabel}>Próxima aula</Text>
        <Text style={styles.nextTitle}>{lesson.title}</Text>
        <Text style={styles.nextMeta}>{lesson.minutes} min de leitura</Text>
      </View>
      <MaterialIcons name="chevron-right" size={20} color={colors.textMuted} />
    </Pressable>
  );
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  scrollContent: { paddingBottom: 40 },

  // Cabeçalho
  header: {
    paddingHorizontal: 20,
    paddingBottom: 24,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerTopRow: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 20 },
  circleButton: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderRadius: 18,
  },
  headerTrack: { flex: 1, color: colors.textOnBlueDim, fontSize: 14, fontWeight: '500' },
  title: { color: colors.textOnBlue, fontSize: 26, fontWeight: '600', lineHeight: 26 * 1.15 },
  summary: {
    marginTop: 8,
    color: colors.textOnBlueDim,
    fontSize: 14,
    lineHeight: 14 * 1.45,
  },
  pills: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 16 },
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.20)',
  },
  pillDone: { backgroundColor: 'rgba(16, 185, 129, 0.35)', borderColor: 'rgba(110, 231, 183, 0.5)' },
  pillText: { color: colors.textOnBlue, fontSize: 12, fontWeight: '500' },

  // Corpo
  body: { paddingHorizontal: 20, paddingTop: 24 },
  noTop: { marginTop: 0 },

  paragraph: {
    marginTop: 12,
    color: colors.textPrimary,
    fontSize: 15,
    lineHeight: 15 * 1.6,
  },
  heading: {
    marginTop: 28,
    marginBottom: -2,
    color: colors.textPrimary,
    fontSize: 18,
    fontWeight: '600',
  },

  list: { marginTop: 12, gap: 8 },
  listItem: { flexDirection: 'row', gap: 12 },
  bullet: {
    width: 8,
    height: 8,
    marginTop: 8,
    backgroundColor: colors.primary,
    borderRadius: radius.pill,
  },
  listText: { flex: 1, color: colors.textPrimary, fontSize: 15, lineHeight: 15 * 1.55 },

  callout: {
    marginTop: 16,
    padding: 16,
    borderRadius: radius.lg,
    borderWidth: 1,
  },
  calloutHeader: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  calloutTitle: { fontSize: 13, fontWeight: '500' },
  calloutText: {
    marginTop: 8,
    color: colors.textPrimary,
    fontSize: 14,
    lineHeight: 14 * 1.55,
  },

  table: {
    marginTop: 16,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
    overflow: 'hidden',
  },
  tableRow: { flexDirection: 'row', gap: 12, paddingHorizontal: 16, paddingVertical: 12 },
  tableHead: { backgroundColor: colors.bg3 },
  tableRowDivider: { borderBottomWidth: 1, borderBottomColor: colors.borderLight },
  tableCell: { flex: 1, color: colors.textSecondary, fontSize: 13, lineHeight: 13 * 1.4 },
  tableHeadText: { color: colors.textSecondary, fontSize: 12, fontWeight: '500' },
  tableFirstCell: { color: colors.textPrimary, fontWeight: '600' },

  termRow: { paddingHorizontal: 16, paddingVertical: 12 },
  termName: { color: colors.textPrimary, fontSize: 14, fontWeight: '500' },
  termDefinition: {
    marginTop: 4,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.5,
  },

  calculatorWrap: { marginTop: 16 },

  // Ações no fim da aula
  actions: { marginTop: 32, gap: 8 },
  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 48,
    paddingHorizontal: 20,
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
  },
  primaryButtonText: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },
  doneButton: {
    backgroundColor: alpha(colors.profit, 0.12),
    borderWidth: 1,
    borderColor: alpha(colors.profit, 0.35),
  },
  doneButtonText: { color: colors.profitDark },
  pressedButton: { opacity: 0.85 },
  undoHint: { color: colors.textMuted, fontSize: 12, textAlign: 'center' },

  secondaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 48,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.35),
  },
  secondaryButtonText: { color: colors.primary, fontSize: 15, fontWeight: '600' },

  nextCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 24,
    padding: 20,
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  nextText: { flex: 1 },
  nextLabel: { color: colors.primary, fontSize: 12, fontWeight: '500' },
  nextTitle: { marginTop: 2, color: colors.textPrimary, fontSize: 16, fontWeight: '600' },
  nextMeta: { marginTop: 4, color: colors.textSecondary, fontSize: 12 },

  disclaimer: {
    marginTop: 28,
    color: colors.textMuted,
    fontSize: 11,
    lineHeight: 11 * 1.5,
    textAlign: 'center',
  },

  // Aula inexistente
  missing: { alignItems: 'center', justifyContent: 'center', paddingHorizontal: 32, gap: 8 },
  missingTitle: { marginTop: 8, color: colors.textPrimary, fontSize: 18, fontWeight: '600' },
  missingBody: {
    marginBottom: 16,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.5,
    textAlign: 'center',
  },
}));
