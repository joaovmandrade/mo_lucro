import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AssetCard } from '@/components/AssetCard';
import { PortfolioDonutChart } from '@/components/PortfolioDonutChart';
import type { Operation } from '@/models';
import { operationService } from '@/services';
import { makeStyles, radius, shadows } from '@/theme';
import { currency } from '@/utils/formatters';
import { calculatePortfolio, categoryDistribution, totalInvested } from '@/utils/portfolio';
import { useTheme } from '@/contexts/ThemeContext';

/** Porte de lib/pages/portfolio_page.dart. */

const CATEGORY_FILTERS: { key: string; label: string }[] = [
  { key: 'all', label: 'Todos' },
  { key: 'stocks', label: 'Ações' },
  { key: 'crypto', label: 'Cripto' },
  { key: 'fixed_income', label: 'Renda Fixa' },
  { key: 'others', label: 'Outros' },
];

export default function PortfolioScreen() {
  const styles = useStyles();
  const { colors } = useTheme();
  const router = useRouter();

  const [operations, setOperations] = useState<Operation[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('all');

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setOperations(await operationService.getOperations());
    } finally {
      setLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  }, [load]);

  function confirmDelete(asset: string) {
    Alert.alert(`Excluir ${asset}`, 'Todas as operações deste ativo serão excluídas', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Excluir',
        style: 'destructive',
        onPress: async () => {
          try {
            await operationService.deleteOperationsForAsset(asset);
          } catch (error) {
            Alert.alert('Não foi possível excluir', error instanceof Error ? error.message : String(error));
          }
          load();
        },
      },
    ]);
  }

  const portfolio = calculatePortfolio(operations);
  const distribution = categoryDistribution(portfolio);
  const invested = totalInvested(portfolio);

  const positions = Object.values(portfolio);
  const filtered =
    selectedCategory === 'all'
      ? positions
      : positions.filter((position) => position.category === selectedCategory);

  return (
    <View style={styles.screen}>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
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
        <PortfolioHeader
          invested={invested}
          positionCount={positions.length}
          operationCount={operations.length}
          isLoading={loading}
          onRefresh={load}
          onCompare={() => router.push('/comparison')}
        />

        <View style={styles.body}>
          <View style={styles.chartCard}>
            {loading ? (
              <View style={styles.chartLoading}>
                <ActivityIndicator color={colors.primary} />
              </View>
            ) : (
              <PortfolioDonutChart distribution={distribution} />
            )}
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            style={styles.filters}
            contentContainerStyle={styles.filtersContent}
          >
            {CATEGORY_FILTERS.map((filter) => {
              const isSelected = selectedCategory === filter.key;
              return (
                <Pressable
                  key={filter.key}
                  onPress={() => setSelectedCategory(filter.key)}
                  style={[styles.chip, isSelected && styles.chipSelected]}
                >
                  <Text style={[styles.chipText, isSelected && styles.chipTextSelected]}>
                    {filter.label}
                  </Text>
                </Pressable>
              );
            })}
          </ScrollView>

          {loading ? (
            <View style={styles.listLoading}>
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : filtered.length === 0 ? (
            <View style={styles.emptyList}>
              <MaterialIcons name="inbox" size={40} color={colors.textMuted} />
              <Text style={styles.emptyText}>Nenhum ativo nesta categoria</Text>
            </View>
          ) : (
            filtered.map((position) => (
              <AssetCard
                key={position.asset}
                position={position}
                onDelete={() => confirmDelete(position.asset)}
              />
            ))
          )}
        </View>
      </ScrollView>

      <Pressable
        style={({ pressed }) => [styles.fab, pressed && styles.fabPressed]}
        onPress={() => router.push('/operations/new')}
        accessibilityLabel="Nova operação"
      >
        <MaterialIcons name="add" size={24} color="#FFFFFF" />
      </Pressable>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
function PortfolioHeader({
  invested,
  positionCount,
  operationCount,
  isLoading,
  onRefresh,
  onCompare,
}: {
  invested: number;
  positionCount: number;
  operationCount: number;
  isLoading: boolean;
  onRefresh: () => void;
  onCompare: () => void;
}) {
  const styles = useStyles();
  const { gradients } = useTheme();
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={gradients.header.colors}
      start={gradients.header.start}
      end={gradients.header.end}
      style={[styles.header, { paddingTop: insets.top + 16 }]}
    >
      <View style={styles.headerTop}>
        <Text style={styles.headerTitle} numberOfLines={1} adjustsFontSizeToFit>
          Portfólio
        </Text>
        <Pressable
          style={styles.compareButton}
          onPress={onCompare}
          accessibilityLabel="Comparar com CDI e IPCA"
        >
          <MaterialIcons name="insights" size={16} color="#FFFFFF" />
          <Text style={styles.compareText}>vs. CDI/IPCA</Text>
        </Pressable>
        <Pressable style={styles.refreshButton} onPress={onRefresh} accessibilityLabel="Atualizar">
          <MaterialIcons name="refresh" size={20} color="#FFFFFF" />
        </Pressable>
      </View>

      <View style={styles.glassCard}>
        {isLoading ? (
          <HeaderSkeleton />
        ) : (
          <>
            <Text style={styles.glassLabel}>Total Investido</Text>
            <Text style={styles.glassValue} numberOfLines={1} adjustsFontSizeToFit>
              {currency(invested)}
            </Text>

            <View style={styles.glassDivider} />

            <View style={styles.statsRow}>
              <StatItem label="Posições" value={String(positionCount)} />
              <View style={styles.statsDivider} />
              <StatItem label="Operações" value={String(operationCount)} />
            </View>
          </>
        )}
      </View>
    </LinearGradient>
  );
}

function StatItem({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  const styles = useStyles();
  return (
    <View style={styles.statItem}>
      <View>
        <Text style={styles.statLabel}>{label}</Text>
        <Text style={styles.statValue}>{value}</Text>
      </View>
    </View>
  );
}

function HeaderSkeleton() {
  const styles = useStyles();
  return (
    <View>
      <View style={[styles.skeletonBox, { width: 120, height: 12 }]} />
      <View style={[styles.skeletonBox, { width: 220, height: 40, marginTop: 8 }]} />
      <View style={[styles.skeletonBox, { width: '100%', height: 1, marginTop: 20 }]} />
      <View style={styles.skeletonRow}>
        <View style={[styles.skeletonBox, { width: 100, height: 36 }]} />
        <View style={[styles.skeletonBox, { width: 100, height: 36, marginLeft: 40 }]} />
      </View>
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  scrollContent: { paddingBottom: 0 },

  header: {
    paddingHorizontal: 20,
    paddingBottom: 32,
    borderBottomLeftRadius: 32,
    borderBottomRightRadius: 32,
  },
  headerTop: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  compareButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    height: 36,
    paddingHorizontal: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    borderRadius: 18,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.28)',
  },
  compareText: { color: '#FFFFFF', fontSize: 12, fontWeight: '500' },
  headerTitle: {
    flex: 1,
    color: '#FFFFFF',
    fontSize: 28,
    fontWeight: '600',
  },
  refreshButton: {
    width: 48,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.14)',
    borderRadius: 24,
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.28)',
    boxShadow: '0px 4px 12px rgba(0, 0, 0, 0.12)',
  },

  glassCard: {
    marginTop: 24,
    paddingHorizontal: 20,
    paddingVertical: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderRadius: 24,
    borderWidth: 1.2,
    borderColor: 'rgba(255, 255, 255, 0.22)',
    boxShadow: '0px 8px 24px rgba(0, 0, 0, 0.18)',
  },
  glassLabel: {
    color: colors.textOnBlueDim,
    fontSize: 13,
    fontWeight: '500',
  },
  glassValue: {
    marginTop: 8,
    color: '#FFFFFF',
    fontSize: 40,
    fontWeight: '600',
    letterSpacing: -1,
  },
  glassDivider: { height: 1, marginTop: 20, backgroundColor: 'rgba(255, 255, 255, 0.15)' },

  statsRow: { flexDirection: 'row', alignItems: 'center', marginTop: 16 },
  statsDivider: {
    width: 1,
    height: 40,
    marginHorizontal: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
  },
  statItem: { flexDirection: 'row', alignItems: 'center' },
  statLabel: { color: colors.textOnBlueDim, fontSize: 11, fontWeight: '500' },
  statValue: { marginTop: 2, color: '#FFFFFF', fontSize: 20, fontWeight: '600' },

  skeletonBox: { backgroundColor: 'rgba(255, 255, 255, 0.10)', borderRadius: 6 },
  skeletonRow: { flexDirection: 'row', marginTop: 16 },

  body: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 100 },
  chartCard: {
    padding: 20,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  chartLoading: { height: 160, alignItems: 'center', justifyContent: 'center' },

  filters: { marginTop: 16, marginBottom: 16 },
  filtersContent: { gap: 8 },
  chip: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: colors.bg1,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipSelected: {
    backgroundColor: 'rgba(37, 99, 235, 0.15)',
    borderWidth: 1.5,
    borderColor: colors.primary,
  },
  chipText: { color: colors.textSecondary, fontSize: 12, fontWeight: '500' },
  chipTextSelected: { color: colors.primary },

  listLoading: { paddingVertical: 40, alignItems: 'center' },
  emptyList: { paddingVertical: 40, alignItems: 'center' },
  emptyText: { marginTop: 12, color: colors.textSecondary, fontSize: 14 },

  fab: {
    position: 'absolute',
    right: 20,
    bottom: 20,
    width: 56,
    height: 56,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.primary,
    borderRadius: radius.pill,
  },
  fabPressed: { backgroundColor: colors.primaryDim },
}));
