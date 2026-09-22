import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { Pressable, ScrollView, StyleSheet, Text, TextInput, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import {
  LESSONS,
  TRACKS,
  getTrack,
  lessonSearchText,
  lessonsOfTrack,
  normalizeText,
  type Lesson,
} from '@/data/knowledge';
import { useKnowledgeProgress } from '@/lib/knowledgeProgress';
import { alpha, colors, gradients, radius, shadows } from '@/theme';

const FILTERS = [{ key: 'all', label: 'Todas' }, ...TRACKS.map((t) => ({ key: t.id, label: t.title }))];

export default function KnowledgeScreen() {
  const router = useRouter();
  const { completed } = useKnowledgeProgress();

  const [query, setQuery] = useState('');
  const [trackFilter, setTrackFilter] = useState('all');

  // Texto de cada aula já normalizado, calculado uma vez só.
  const searchIndex = useMemo(
    () => new Map(LESSONS.map((lesson) => [lesson.id, lessonSearchText(lesson)])),
    [],
  );

  const total = LESSONS.length;
  const done = LESSONS.filter((lesson) => completed.has(lesson.id)).length;
  const remainingMinutes = LESSONS.filter((lesson) => !completed.has(lesson.id)).reduce(
    (sum, lesson) => sum + lesson.minutes,
    0,
  );
  const progress = total > 0 ? done / total : 0;
  const nextUp = LESSONS.find((lesson) => !completed.has(lesson.id)) ?? null;

  const normalizedQuery = normalizeText(query.trim());
  const searching = normalizedQuery.length > 0;

  const pool = trackFilter === 'all' ? LESSONS : lessonsOfTrack(trackFilter);
  const results = searching
    ? pool.filter((lesson) => searchIndex.get(lesson.id)?.includes(normalizedQuery))
    : [];
  const visibleTracks = trackFilter === 'all' ? TRACKS : TRACKS.filter((t) => t.id === trackFilter);

  function openLesson(id: string) {
    router.push({ pathname: '/knowledge/[id]', params: { id } });
  }

  return (
    <View style={styles.screen}>
      <ScrollView keyboardShouldPersistTaps="handled" keyboardDismissMode="on-drag">
        <Header done={done} total={total} progress={progress} remainingMinutes={remainingMinutes} />

        <View style={styles.body}>
          <View style={styles.searchBox}>
            <MaterialIcons name="search" size={20} color={colors.textMuted} />
            <TextInput
              style={styles.searchInput}
              value={query}
              onChangeText={setQuery}
              placeholder="Buscar um tema, como FGC ou preço médio"
              placeholderTextColor={colors.textMuted}
              returnKeyType="search"
              autoCorrect={false}
              accessibilityLabel="Buscar na Base de Conhecimento"
            />
            {query.length > 0 ? (
              <Pressable
                onPress={() => setQuery('')}
                hitSlop={10}
                accessibilityLabel="Limpar busca"
              >
                <MaterialIcons name="close" size={18} color={colors.textMuted} />
              </Pressable>
            ) : null}
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            style={styles.filters}
            contentContainerStyle={styles.filtersContent}
            keyboardShouldPersistTaps="handled"
          >
            {FILTERS.map((item) => {
              const selected = trackFilter === item.key;
              return (
                <Pressable
                  key={item.key}
                  onPress={() => setTrackFilter(item.key)}
                  style={[styles.chip, selected && styles.chipSelected]}
                  accessibilityRole="button"
                  accessibilityState={{ selected }}
                >
                  <Text style={[styles.chipText, selected && styles.chipTextSelected]}>
                    {item.label}
                  </Text>
                </Pressable>
              );
            })}
          </ScrollView>

          {searching ? (
            <SearchResults
              results={results}
              query={query.trim()}
              completed={completed}
              onOpen={openLesson}
            />
          ) : (
            <>
              {trackFilter === 'all' ? (
                <NextUpCard
                  lesson={nextUp}
                  started={done > 0}
                  onOpen={() => nextUp && openLesson(nextUp.id)}
                />
              ) : null}

              {visibleTracks.map((track) => {
                const lessons = lessonsOfTrack(track.id);
                const doneInTrack = lessons.filter((lesson) => completed.has(lesson.id)).length;

                return (
                  <View key={track.id} style={styles.section}>
                    <View style={styles.sectionHeader}>
                      <View style={styles.sectionIcon}>
                        <MaterialIcons name={track.icon} size={20} color={colors.primary} />
                      </View>
                      <View style={styles.sectionText}>
                        <Text style={styles.sectionTitle}>{track.title}</Text>
                        <Text style={styles.sectionDescription}>{track.description}</Text>
                      </View>
                      <Text
                        style={styles.sectionCount}
                        accessibilityLabel={`${doneInTrack} de ${lessons.length} aulas concluídas`}
                      >
                        {doneInTrack}/{lessons.length}
                      </Text>
                    </View>

                    <View style={styles.rowsCard}>
                      {lessons.map((lesson, index) => (
                        <LessonRow
                          key={lesson.id}
                          lesson={lesson}
                          leading={String(index + 1)}
                          done={completed.has(lesson.id)}
                          isLast={index === lessons.length - 1}
                          onPress={() => openLesson(lesson.id)}
                        />
                      ))}
                    </View>
                  </View>
                );
              })}
            </>
          )}

          <Text style={styles.disclaimer}>
            Conteúdo educacional. Não é recomendação de investimento nem substitui a orientação de
            um profissional certificado.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Cabeçalho com o progresso geral
// ─────────────────────────────────────────────────────────────
function Header({
  done,
  total,
  progress,
  remainingMinutes,
}: {
  done: number;
  total: number;
  progress: number;
  remainingMinutes: number;
}) {
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={gradients.header.colors}
      start={gradients.header.start}
      end={gradients.header.end}
      style={[styles.header, { paddingTop: insets.top + 14 }]}
    >
      <Text style={styles.headerTitle}>Base de Conhecimento</Text>
      <Text style={styles.headerSubtitle}>Estude tudo sobre aportes, no seu ritmo.</Text>

      <View style={styles.progressCard}>
        <View style={styles.progressTopRow}>
          <Text style={styles.progressLabel}>Seu progresso</Text>
          <Text style={styles.progressPercent}>{Math.round(progress * 100)}%</Text>
        </View>

        <View
          style={styles.progressTrack}
          accessibilityRole="progressbar"
          accessibilityValue={{ min: 0, max: total, now: done }}
        >
          <LinearGradient
            colors={[colors.warning, '#FBBF24']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={[styles.progressFill, { width: `${Math.min(Math.max(progress, 0), 1) * 100}%` }]}
          />
        </View>

        <View style={styles.progressBottomRow}>
          <View>
            <Text style={styles.progressSmallLabel}>Aulas concluídas</Text>
            <Text style={styles.progressStrong}>
              {done} de {total}
            </Text>
          </View>
          <View style={styles.alignEnd}>
            <Text style={styles.progressSmallLabel}>Leitura restante</Text>
            <Text style={styles.progressDim}>
              {remainingMinutes > 0 ? `${remainingMinutes} min` : 'Nada pendente'}
            </Text>
          </View>
        </View>
      </View>
    </LinearGradient>
  );
}

// ─────────────────────────────────────────────────────────────
// Próxima aula
// ─────────────────────────────────────────────────────────────
function NextUpCard({
  lesson,
  started,
  onOpen,
}: {
  lesson: Lesson | null;
  started: boolean;
  onOpen: () => void;
}) {
  if (!lesson) {
    return (
      <View style={styles.doneCard}>
        <MaterialIcons name="check-circle" size={22} color={colors.profit} />
        <Text style={styles.doneText}>
          Você concluiu todas as aulas. Volte a qualquer tema quando quiser rever.
        </Text>
      </View>
    );
  }

  const track = getTrack(lesson.trackId);

  return (
    <Pressable
      onPress={onOpen}
      style={({ pressed }) => [styles.nextCard, pressed && styles.pressed]}
      accessibilityRole="button"
      accessibilityLabel={`${started ? 'Continuar' : 'Começar'}: ${lesson.title}`}
    >
      <View style={styles.nextIcon}>
        <MaterialIcons name="play-arrow" size={26} color="#FFFFFF" />
      </View>
      <View style={styles.nextText}>
        <Text style={styles.nextLabel}>{started ? 'Continuar' : 'Comece por aqui'}</Text>
        <Text style={styles.nextTitle}>{lesson.title}</Text>
        <Text style={styles.nextMeta}>
          {track?.title}, {lesson.minutes} min de leitura
        </Text>
      </View>
      <MaterialIcons name="chevron-right" size={22} color={colors.textMuted} />
    </Pressable>
  );
}

// ─────────────────────────────────────────────────────────────
// Resultados da busca
// ─────────────────────────────────────────────────────────────
function SearchResults({
  results,
  query,
  completed,
  onOpen,
}: {
  results: Lesson[];
  query: string;
  completed: Set<string>;
  onOpen: (id: string) => void;
}) {
  if (results.length === 0) {
    return (
      <View style={styles.emptyState}>
        <View style={styles.emptyIcon}>
          <MaterialIcons name="search-off" size={32} color={colors.primary} />
        </View>
        <Text style={styles.emptyTitle}>Nada encontrado para “{query}”</Text>
        <Text style={styles.emptyBody}>
          Tente outra palavra, como Tesouro, dividendos ou imposto, ou escolha uma trilha acima.
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.section}>
      <Text style={styles.resultsCount}>
        {results.length === 1 ? '1 aula encontrada' : `${results.length} aulas encontradas`}
      </Text>
      <View style={styles.rowsCard}>
        {results.map((lesson, index) => (
          <LessonRow
            key={lesson.id}
            lesson={lesson}
            trackName={getTrack(lesson.trackId)?.title}
            done={completed.has(lesson.id)}
            isLast={index === results.length - 1}
            onPress={() => onOpen(lesson.id)}
          />
        ))}
      </View>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Linha de aula
// ─────────────────────────────────────────────────────────────
function LessonRow({
  lesson,
  leading,
  trackName,
  done,
  isLast,
  onPress,
}: {
  lesson: Lesson;
  /** Número da aula na trilha. Na busca, sem trilha na tela, fica vazio. */
  leading?: string;
  trackName?: string;
  done: boolean;
  isLast: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.row, !isLast && styles.rowDivider, pressed && styles.pressed]}
      accessibilityRole="button"
      accessibilityLabel={`${lesson.title}, ${lesson.minutes} minutos de leitura${
        done ? ', concluída' : ''
      }`}
    >
      <View style={[styles.badge, done && styles.badgeDone]}>
        {done ? (
          <MaterialIcons name="check" size={16} color="#FFFFFF" />
        ) : (
          <Text style={styles.badgeText}>{leading ?? '•'}</Text>
        )}
      </View>

      <View style={styles.rowText}>
        <Text style={styles.rowTitle}>{lesson.title}</Text>
        <Text style={styles.rowSummary} numberOfLines={2}>
          {lesson.summary}
        </Text>
        <Text style={styles.rowMeta}>
          {trackName ? `${trackName}, ` : ''}
          {lesson.minutes} min de leitura
        </Text>
      </View>

      <MaterialIcons name="chevron-right" size={20} color={colors.textMuted} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  pressed: { backgroundColor: colors.surfacePressed },

  // Cabeçalho
  header: {
    paddingHorizontal: 20,
    paddingBottom: 28,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerTitle: { color: colors.textOnBlue, fontSize: 22, fontWeight: '800' },
  headerSubtitle: { marginTop: 4, marginBottom: 20, color: colors.textOnBlueDim, fontSize: 13 },

  progressCard: {
    padding: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  progressTopRow: { flexDirection: 'row', justifyContent: 'space-between' },
  progressLabel: { color: colors.textOnBlueDim, fontSize: 13 },
  progressPercent: { color: colors.textOnBlue, fontSize: 15, fontWeight: '700' },
  progressTrack: {
    height: 8,
    marginTop: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  progressFill: { height: 8, borderRadius: radius.pill },
  progressBottomRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 12 },
  progressSmallLabel: { color: colors.textOnBlueDim, fontSize: 11 },
  progressStrong: { marginTop: 2, color: colors.textOnBlue, fontSize: 15, fontWeight: '700' },
  progressDim: { marginTop: 2, color: colors.textOnBlueDim, fontSize: 15, fontWeight: '600' },
  alignEnd: { alignItems: 'flex-end' },

  // Corpo
  body: { paddingHorizontal: 20, paddingTop: 20, paddingBottom: 32 },

  searchBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 14,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  searchInput: { flex: 1, paddingVertical: 13, color: colors.textPrimary, fontSize: 14 },

  filters: { flexGrow: 0, marginTop: 14, marginHorizontal: -20 },
  filtersContent: { paddingHorizontal: 20, gap: 8, alignItems: 'center' },
  chip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: colors.bg2,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipSelected: {
    backgroundColor: alpha(colors.primary, 0.15),
    borderColor: alpha(colors.primary, 0.35),
  },
  chipText: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },
  chipTextSelected: { color: colors.primary },

  // Próxima aula
  nextCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 14,
    marginTop: 20,
    padding: 16,
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.25),
    boxShadow: shadows.card,
  },
  nextIcon: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.primary,
    borderRadius: radius.pill,
  },
  nextText: { flex: 1 },
  nextLabel: { color: colors.primary, fontSize: 12, fontWeight: '700' },
  nextTitle: { marginTop: 2, color: colors.textPrimary, fontSize: 16, fontWeight: '700' },
  nextMeta: { marginTop: 3, color: colors.textSecondary, fontSize: 12 },

  doneCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginTop: 20,
    padding: 16,
    backgroundColor: alpha(colors.profit, 0.08),
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: alpha(colors.profit, 0.2),
  },
  doneText: { flex: 1, color: colors.textPrimary, fontSize: 13, lineHeight: 13 * 1.45 },

  // Trilhas
  section: { marginTop: 24 },
  sectionHeader: { flexDirection: 'row', alignItems: 'center', gap: 12, marginBottom: 12 },
  sectionIcon: {
    width: 38,
    height: 38,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: alpha(colors.primary, 0.1),
    borderRadius: radius.md,
  },
  sectionText: { flex: 1 },
  sectionTitle: { color: colors.textPrimary, fontSize: 16, fontWeight: '700' },
  sectionDescription: {
    marginTop: 2,
    color: colors.textSecondary,
    fontSize: 12,
    lineHeight: 12 * 1.4,
  },
  sectionCount: { color: colors.textMuted, fontSize: 12, fontWeight: '700' },

  rowsCard: {
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
    overflow: 'hidden',
  },
  row: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 14 },
  rowDivider: { borderBottomWidth: 1, borderBottomColor: colors.borderLight },
  badge: {
    width: 32,
    height: 32,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg3,
    borderRadius: radius.pill,
  },
  badgeDone: { backgroundColor: colors.profit },
  badgeText: { color: colors.textSecondary, fontSize: 13, fontWeight: '700' },
  rowText: { flex: 1 },
  rowTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '700' },
  rowSummary: { marginTop: 3, color: colors.textSecondary, fontSize: 12, lineHeight: 12 * 1.4 },
  rowMeta: { marginTop: 5, color: colors.textMuted, fontSize: 11 },

  // Busca sem resultado
  resultsCount: { marginBottom: 12, color: colors.textSecondary, fontSize: 12, fontWeight: '600' },
  emptyState: { paddingVertical: 40, alignItems: 'center' },
  emptyIcon: {
    padding: 20,
    backgroundColor: alpha(colors.primary, 0.08),
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.18),
  },
  emptyTitle: {
    marginTop: 18,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '700',
    textAlign: 'center',
  },
  emptyBody: {
    marginTop: 6,
    paddingHorizontal: 12,
    color: colors.textSecondary,
    fontSize: 13,
    lineHeight: 13 * 1.5,
    textAlign: 'center',
  },

  disclaimer: {
    marginTop: 28,
    color: colors.textMuted,
    fontSize: 11,
    lineHeight: 11 * 1.5,
    textAlign: 'center',
  },
});
