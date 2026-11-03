import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import * as WebBrowser from 'expo-web-browser';
import { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Modal,
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { newsService } from '@/services';
import type { NewsItem } from '@/services/newsService';
import { alpha, makeStyles, radius, spacing } from '@/theme';
import { useTheme } from '@/contexts/ThemeContext';
import { goBack } from '@/lib/navigation';

/** Porte de lib/pages/market_news_page.dart. */

const FILTERS: { key: string; label: string }[] = [
  { key: 'all', label: 'Todos' },
  { key: 'geo', label: 'Geopolítica' },
  { key: 'fiis', label: 'FIIs' },
  { key: 'dividends', label: 'Dividendos' },
  { key: 'economy', label: 'Economia' },
];

function categoryLabel(category: string): string {
  switch (category) {
    case 'fiis':
      return 'FIIs';
    case 'geo':
      return 'Geopolítica';
    case 'dividends':
      return 'Dividendos';
    case 'economy':
      return 'Economia';
    default:
      return 'Mercado';
  }
}

export default function NewsScreen() {
  const styles = useStyles();
  const { colors, gradients } = useTheme();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [filter, setFilter] = useState('all');
  const [news, setNews] = useState<NewsItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [detail, setDetail] = useState<NewsItem | null>(null);

  const load = useCallback(async (category: string) => {
    setLoading(true);
    setError(null);
    try {
      setNews(await newsService.fetchNews(category));
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load(filter);
  }, [filter, load]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await load(filter);
    setRefreshing(false);
  }, [filter, load]);

  const featured = news.find((item) => item.isFeatured) ?? news[0] ?? null;
  const regular = featured ? news.filter((item) => item !== featured) : [];

  return (
    <View style={styles.screen}>
      <LinearGradient
        colors={gradients.header.colors}
        start={gradients.header.start}
        end={gradients.header.end}
        style={[styles.header, { paddingTop: insets.top + 16 }]}
      >
        <View style={styles.headerCard}>
          <Pressable
            style={styles.circleButton}
            onPress={() => goBack(router)}
            accessibilityLabel="Voltar"
          >
            <MaterialIcons name="arrow-back-ios-new" size={16} color={colors.textOnBlue} />
          </Pressable>

          <Text style={styles.headerTitle}>Notícias do Mercado</Text>

          <Pressable
            style={styles.circleButton}
            onPress={() => load(filter)}
            accessibilityLabel="Atualizar"
          >
            <MaterialIcons name="refresh" size={18} color={colors.textOnBlue} />
          </Pressable>
        </View>
      </LinearGradient>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.filters}
        contentContainerStyle={styles.filtersContent}
      >
        {FILTERS.map((item) => {
          const selected = filter === item.key;
          return (
            <Pressable
              key={item.key}
              onPress={() => setFilter(item.key)}
              style={[styles.chip, selected && styles.chipSelected]}
            >
              <Text style={[styles.chipText, selected && styles.chipTextSelected]}>
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </ScrollView>

      <ScrollView
        contentContainerStyle={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            tintColor={colors.primary}
            colors={[colors.primary]}
            progressBackgroundColor={colors.bg2}
          />
        }
      >
        {loading ? (
          <LoadingState />
        ) : error ? (
          <ErrorState message={error} onRetry={() => load(filter)} />
        ) : news.length === 0 ? (
          <EmptyState onRetry={() => load(filter)} />
        ) : (
          <>
            {news.some((item) => item.isSample) ? (
              <View style={styles.sampleBanner}>
                <MaterialIcons name="info-outline" size={16} color={colors.warning} />
                <Text style={styles.sampleText}>
                  Sem conexão com a fonte de notícias. Exibindo exemplos
                </Text>
              </View>
            ) : null}

            {featured ? (
              <FeaturedCard item={featured} onPress={() => setDetail(featured)} />
            ) : null}

            {regular.map((item, index) => (
              <NewsTile
                key={`${item.headline}-${index}`}
                item={item}
                onPress={() => setDetail(item)}
              />
            ))}

            <Pressable style={styles.reloadButton} onPress={() => load(filter)}>
              <MaterialIcons name="refresh" size={16} color={colors.primary} />
              <Text style={styles.reloadText}>Recarregar</Text>
            </Pressable>
          </>
        )}
      </ScrollView>

      <NewsDetailSheet item={detail} onClose={() => setDetail(null)} />
    </View>
  );
}

// ── Destaque ─────────────────────────────────────────────────
function FeaturedCard({ item, onPress }: { item: NewsItem; onPress: () => void }) {
  const styles = useStyles();
  const { colors, gradients } = useTheme();
  return (
    <Pressable onPress={onPress}>
      <LinearGradient
        colors={gradients.primary.colors}
        start={gradients.primary.start}
        end={gradients.primary.end}
        style={styles.featured}
      >
        <View style={styles.tagRow}>
          {item.ticker ? <NewsTag label={item.ticker} color="#FFFFFF" /> : null}
          <NewsTag label={categoryLabel(item.category)} color="#FFFFFF" />
          <View style={styles.spacer} />
          <Text style={styles.featuredTime}>{item.timeAgo}</Text>
        </View>

        <Text style={styles.featuredHeadline}>{item.headline}</Text>
        <Text style={styles.featuredSub} numberOfLines={2}>
          {item.sub}
        </Text>

        <View style={styles.featuredFooter}>
          {item.source ? (
            <>
              <MaterialIcons name="public" size={16} color={colors.textOnBlueDim} />
              <Text style={styles.featuredSource}>{item.source}</Text>
            </>
          ) : null}
          <View style={styles.spacer} />
          <Text style={styles.featuredReadMore}>Ler mais</Text>
          <MaterialIcons name="arrow-forward" size={16} color={colors.textOnBlue} />
        </View>
      </LinearGradient>
    </Pressable>
  );
}

// ── Item da lista ────────────────────────────────────────────
function NewsTile({ item, onPress }: { item: NewsItem; onPress: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <Pressable style={({ pressed }) => [styles.tile, pressed && styles.tilePressed]} onPress={onPress}>
      <View style={styles.tileIcon}>
        <MaterialIcons name="article" size={20} color={colors.textSecondary} />
      </View>

      <View style={styles.tileBody}>
        <View style={styles.tileMeta}>
          {item.ticker ? <NewsTag label={item.ticker} color={colors.primary} /> : null}
          <Text style={styles.tileTime}>{item.timeAgo}</Text>
          <View style={styles.spacer} />
          {item.source ? <Text style={styles.tileTime}>{item.source}</Text> : null}
        </View>

        <Text style={styles.tileHeadline} numberOfLines={2}>
          {item.headline}
        </Text>
      </View>

      <MaterialIcons name="chevron-right" size={18} color={colors.textMuted} />
    </Pressable>
  );
}

// ── Detalhe ──────────────────────────────────────────────────
function NewsDetailSheet({ item, onClose }: { item: NewsItem | null; onClose: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  if (!item) return null;

  return (
    <Modal visible animationType="slide" transparent onRequestClose={onClose}>
      <Pressable style={styles.sheetBackdrop} onPress={onClose} />

      <View style={styles.sheet}>
        <View style={styles.sheetHandle} />

        <ScrollView contentContainerStyle={styles.sheetContent}>
          <View style={styles.tagRow}>
            {item.ticker ? <NewsTag label={item.ticker} color={colors.primary} /> : null}
            <NewsTag label={categoryLabel(item.category)} color={colors.textSecondary} />
            <View style={styles.spacer} />
            <Text style={styles.sheetTime}>{item.timeAgo}</Text>
          </View>

          <Text style={styles.sheetHeadline}>{item.headline}</Text>
          <Text style={styles.sheetSub}>{item.sub}</Text>

          {item.source ? (
            <View style={styles.sheetSourceRow}>
              <MaterialIcons name="public" size={16} color={colors.textMuted} />
              <Text style={styles.sheetSource}>{item.source}</Text>
            </View>
          ) : null}

          <View style={styles.sheetDivider} />

          {item.content ? <Text style={styles.sheetBody}>{item.content}</Text> : null}

          {item.url ? (
            <>
              <Text style={styles.sheetHint}>
                O texto completo está no site do veículo
              </Text>
              <Pressable
                style={styles.outlinedButton}
                onPress={() => WebBrowser.openBrowserAsync(item.url!)}
                accessibilityRole="link"
              >
                <MaterialIcons name="open-in-new" size={16} color={colors.primary} />
                <Text style={styles.outlinedButtonText}>Abrir fonte original</Text>
              </Pressable>
            </>
          ) : item.isSample ? (
            <Text style={styles.sheetHint}>Notícia de exemplo, sem fonte original</Text>
          ) : null}
        </ScrollView>
      </View>
    </Modal>
  );
}

// ── Estados ──────────────────────────────────────────────────
function LoadingState() {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <>
      <View style={styles.loadingFeatured}>
        <ActivityIndicator color={colors.primary} />
      </View>
      {[0, 1, 2, 3].map((index) => (
        <View key={index} style={styles.loadingTile} />
      ))}
    </>
  );
}

function ErrorState({ message, onRetry }: { message: string; onRetry: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <View style={styles.stateBlock}>
      <MaterialIcons name="wifi-off" size={48} color={colors.textMuted} />
      <Text style={styles.stateTitle}>Não foi possível carregar as notícias</Text>
      <Text style={styles.stateMessage}>{message}</Text>
      <Pressable style={styles.retryButton} onPress={onRetry}>
        <MaterialIcons name="refresh" size={16} color="#FFFFFF" />
        <Text style={styles.retryText}>Tentar novamente</Text>
      </Pressable>
    </View>
  );
}

function EmptyState({ onRetry }: { onRetry: () => void }) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <View style={styles.stateBlock}>
      <MaterialIcons name="newspaper" size={48} color={colors.textMuted} />
      <Text style={styles.stateEmptyTitle}>Nenhuma notícia nessa categoria</Text>
      <Pressable style={styles.reloadButton} onPress={onRetry}>
        <MaterialIcons name="refresh" size={16} color={colors.primary} />
        <Text style={styles.reloadText}>Recarregar</Text>
      </Pressable>
    </View>
  );
}

function NewsTag({ label, color }: { label: string; color: string }) {
  const styles = useStyles();
  return (
    <View
      style={[styles.tag, { backgroundColor: alpha(color, 0.12), borderColor: alpha(color, 0.3) }]}
    >
      <Text style={[styles.tagText, { color }]}>{label}</Text>
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  spacer: { flex: 1 },

  header: {
    paddingHorizontal: 20,
    paddingBottom: 20,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  circleButton: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderRadius: 18,
  },
  headerTitle: { flex: 1, color: colors.textOnBlue, fontSize: 18, fontWeight: '600' },

  // Altura fixa como o SizedBox(height: 44) do Flutter: sem ela o ScrollView
  // horizontal encolhe e corta o texto dos chips.
  filters: { height: 44, flexGrow: 0, marginVertical: 12 },
  filtersContent: { paddingHorizontal: 20, gap: 8, alignItems: 'center' },
  chip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: colors.bg2,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipSelected: {
    backgroundColor: alpha(colors.primary, 0.15),
    borderColor: colors.primary,
    borderWidth: 1.5,
  },
  chipText: { color: colors.textSecondary, fontSize: 12, fontWeight: '500' },
  chipTextSelected: { color: colors.primary },

  content: { paddingHorizontal: 20, paddingBottom: 32 },

  featured: {
    padding: spacing.lg,
    marginBottom: 16,
    borderRadius: radius.xxl,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.3),
  },
  tagRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  featuredTime: { color: colors.textOnBlueDim, fontSize: 11 },
  featuredHeadline: {
    marginTop: 8,
    color: colors.textOnBlue,
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 16 * 1.4,
  },
  featuredSub: { marginTop: 8, color: colors.textOnBlueDim, fontSize: 13 },
  featuredFooter: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 12 },
  featuredSource: { color: colors.textOnBlueDim, fontSize: 11 },
  featuredReadMore: { color: colors.textOnBlue, fontSize: 12, fontWeight: '500' },

  tile: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
    marginBottom: 8,
    padding: spacing.base,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  tilePressed: { backgroundColor: colors.surfacePressed },
  tileIcon: {
    width: 48,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg3,
    borderRadius: radius.md,
  },
  tileBody: { flex: 1 },
  tileMeta: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  tileTime: { color: colors.textMuted, fontSize: 10 },
  tileHeadline: {
    marginTop: 4,
    color: colors.textPrimary,
    fontSize: 13,
    fontWeight: '500',
    lineHeight: 13 * 1.4,
  },

  tag: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: radius.sm,
    borderWidth: 1,
  },
  tagText: { fontSize: 10, fontWeight: '500' },

  loadingFeatured: {
    height: 160,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    backgroundColor: colors.bg2,
    borderRadius: radius.xxl,
    borderWidth: 1,
    borderColor: colors.border,
  },
  loadingTile: {
    height: 76,
    marginBottom: 8,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },

  stateBlock: { alignItems: 'center', padding: 32 },
  stateTitle: {
    marginTop: 16,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  stateEmptyTitle: {
    marginTop: 16,
    color: colors.textSecondary,
    fontSize: 15,
    fontWeight: '600',
    textAlign: 'center',
  },
  stateMessage: { marginTop: 8, color: colors.textMuted, fontSize: 12, textAlign: 'center' },
  retryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginTop: 20,
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
  },
  retryText: { color: '#FFFFFF', fontSize: 14, fontWeight: '500' },
  reloadButton: {
    flexDirection: 'row',
    alignSelf: 'center',
    alignItems: 'center',
    gap: 8,
    marginTop: 16,
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  reloadText: { color: colors.primary, fontSize: 14, fontWeight: '500' },

  sheetBackdrop: { flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.35)' },
  sheet: {
    height: '85%',
    backgroundColor: colors.bg1,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
  },
  sheetHandle: {
    width: 40,
    height: 4,
    alignSelf: 'center',
    marginTop: 12,
    backgroundColor: colors.border,
    borderRadius: radius.pill,
  },
  sheetContent: { padding: spacing.xl, paddingBottom: 32 },
  sheetTime: { color: colors.textMuted, fontSize: 12 },
  sheetHeadline: {
    marginTop: 12,
    color: colors.textPrimary,
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 20 * 1.4,
  },
  sheetSub: {
    marginTop: 8,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.6,
  },
  sheetSourceRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 8 },
  sheetSource: { color: colors.textMuted, fontSize: 12 },
  sheetDivider: { height: 1, marginVertical: 20, backgroundColor: colors.border },
  sheetBody: { color: colors.textSecondary, fontSize: 14, lineHeight: 14 * 1.7 },
  sheetHint: { marginTop: 16, color: colors.textMuted, fontSize: 12, textAlign: 'center' },
  sampleBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 12,
    padding: spacing.md,
    backgroundColor: alpha(colors.warning, 0.1),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.warning, 0.3),
  },
  sampleText: { flex: 1, color: colors.textSecondary, fontSize: 12 },
  outlinedButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 52,
    marginTop: 12,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  outlinedButtonText: { color: colors.primary, fontSize: 15, fontWeight: '600' },
}));
