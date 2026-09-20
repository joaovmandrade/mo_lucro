import { Ionicons, MaterialCommunityIcons, MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import { Pressable, RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AssetCard } from '@/components/AssetCard';
import { PatrimonioLineChart } from '@/components/PatrimonioLineChart';
import { useAuth } from '@/contexts/AuthContext';
import type { Operation } from '@/models';
import { operationService, transactionService } from '@/services';
import { alpha, colors, gradients, radius, shadows } from '@/theme';
import { currency } from '@/utils/formatters';
import { calculatePortfolio, totalInvested } from '@/utils/portfolio';

/** Porte de lib/pages/home_page.dart (DashboardPage). */
export default function DashboardScreen() {
  const router = useRouter();

  const [operations, setOperations] = useState<Operation[]>([]);
  const [monthSummary, setMonthSummary] = useState({ income: 0, expense: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const now = new Date();
      const ops = await operationService.getOperations();
      const summary = await transactionService.getMonthSummary(
        now.getFullYear(),
        now.getMonth() + 1,
      );
      setOperations(ops);
      setMonthSummary(summary);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setLoading(false);
    }
  }, []);

  // No Flutter o reload vinha do `bool` devolvido por Navigator.push; aqui o
  // equivalente é recarregar sempre que a tela volta ao foco.
  useFocusEffect(
    useCallback(() => {
      loadData();
    }, [loadData]),
  );

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  }, [loadData]);

  const portfolio = calculatePortfolio(operations);
  const positions = Object.values(portfolio);
  const invested = totalInvested(portfolio);
  const { income, expense } = monthSummary;
  const available = income - expense;
  const total = invested + available;
  const returnAmount = income > expense ? income - expense : 0;
  const growth = invested > 0 ? (returnAmount / invested) * 100 : 0;

  return (
    <ScrollView
      style={styles.screen}
      contentContainerStyle={styles.scrollContent}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={onRefresh}
          tintColor={colors.primary}
          colors={[colors.primary]}
          progressBackgroundColor={colors.bg1}
        />
      }
    >
      <BlueHeader
        total={total}
        invested={invested}
        growth={growth}
        returnAmount={returnAmount}
        assetCount={positions.length}
        isLoading={loading}
        onRefresh={loadData}
      />

      <View style={styles.body}>
        <QuickActions
          onAportar={() => router.push('/operations/new')}
          onSimular={() => router.push('/simulator')}
          onNoticias={() => router.push('/news')}
          onMeta={() => router.push('/goals/new')}
        />

        <DicaCard />

        <ChartSection isLoading={loading} totalInvested={invested} />

        <SectionTitle
          title="Minhas Posições"
          subtitle={`${positions.length} ativos`}
          action={positions.length > 0 ? 'Ver detalhes' : null}
          onActionPress={() => router.push('/portfolio')}
        />

        {error ? (
          <ErrorBanner message={error} />
        ) : loading ? (
          <>
            <View style={styles.skeletonCard} />
            <View style={styles.skeletonCard} />
          </>
        ) : positions.length === 0 ? (
          <EmptyState onAdd={() => router.push('/operations/new')} />
        ) : (
          positions.map((position) => <AssetCard key={position.asset} position={position} />)
        )}

        <Pressable
          style={({ pressed }) => [styles.primaryButton, pressed && styles.primaryButtonPressed]}
          onPress={() => router.push('/operations/new')}
        >
          <MaterialIcons name="add" size={20} color="#FFFFFF" />
          <Text style={styles.primaryButtonLabel}>Nova Operação</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
}

// ─────────────────────────────────────────────────────────────
// Header azul
// ─────────────────────────────────────────────────────────────
function BlueHeader({
  total,
  invested,
  growth,
  returnAmount,
  assetCount,
  isLoading,
  onRefresh,
}: {
  total: number;
  invested: number;
  growth: number;
  returnAmount: number;
  assetCount: number;
  isLoading: boolean;
  onRefresh: () => void;
}) {
  const { signOut } = useAuth();
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={gradients.header.colors}
      start={gradients.header.start}
      end={gradients.header.end}
      style={[styles.header, { paddingTop: insets.top + 12 }]}
    >
      <View style={styles.headerTop}>
        <View style={styles.logoRow}>
          <View style={styles.logoBox}>
            <MaterialCommunityIcons name="chart-bar" size={20} color="#FFFFFF" />
          </View>
          <Text style={styles.logoText}>
            Mo<Text style={styles.logoTextAccent}>Lucro</Text>
          </Text>
        </View>

        <View style={styles.headerActions}>
          <HeaderIconButton icon="refresh" onPress={onRefresh} label="Atualizar" />
          <HeaderIconButton icon="logout" onPress={signOut} label="Sair" />
        </View>
      </View>

      <View style={styles.patrimonioCard}>
        {isLoading ? (
          <PatrimonioSkeleton />
        ) : (
          <PatrimonioBody
            total={total}
            invested={invested}
            growth={growth}
            returnAmount={returnAmount}
          />
        )}
      </View>

      <View style={styles.miniStats}>
        <MiniStat label="Streak" value="7 dias 🔥" />
        <MiniStat label="Ativos" value={`${assetCount} ativos`} />
      </View>
    </LinearGradient>
  );
}

function HeaderIconButton({
  icon,
  onPress,
  label,
}: {
  icon: keyof typeof MaterialIcons.glyphMap;
  onPress: () => void;
  label: string;
}) {
  return (
    <Pressable style={styles.headerIconButton} onPress={onPress} accessibilityLabel={label}>
      <MaterialIcons name={icon} size={18} color="#FFFFFF" />
    </Pressable>
  );
}

function PatrimonioBody({
  total,
  invested,
  growth,
  returnAmount,
}: {
  total: number;
  invested: number;
  growth: number;
  returnAmount: number;
}) {
  const isPositive = growth >= 0;

  return (
    <View>
      <Text style={styles.patrimonioLabel}>Patrimônio Total</Text>
      <Text style={styles.patrimonioValue} numberOfLines={1} adjustsFontSizeToFit>
        {currency(total)}
      </Text>

      <View style={styles.patrimonioRow}>
        <View>
          <Text style={styles.investedLabel}>Investido</Text>
          <Text style={styles.investedValue}>{currency(invested)}</Text>
        </View>

        <View style={styles.growthBadge}>
          <Text style={styles.growthText}>
            {isPositive ? '+' : ''}
            {growth.toFixed(2)}%
          </Text>
        </View>
      </View>

      {returnAmount > 0 ? (
        <Text style={styles.returnText}>Retorno: {currency(returnAmount)}</Text>
      ) : null}
    </View>
  );
}

function PatrimonioSkeleton() {
  return (
    <View>
      <View style={[styles.skeletonBox, { width: 110, height: 13 }]} />
      <View style={[styles.skeletonBox, { width: 200, height: 30, marginTop: 10 }]} />
      <View style={styles.skeletonRow}>
        <View style={[styles.skeletonBox, { width: 100, height: 36 }]} />
        <View style={[styles.skeletonBox, { width: 70, height: 28 }]} />
      </View>
    </View>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.miniStat}>
      <Text style={styles.miniStatLabel}>{label}</Text>
      <Text style={styles.miniStatValue}>{value}</Text>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Ações rápidas
// ─────────────────────────────────────────────────────────────
function QuickActions({
  onAportar,
  onSimular,
  onNoticias,
  onMeta,
}: {
  onAportar: () => void;
  onSimular: () => void;
  onNoticias: () => void;
  onMeta: () => void;
}) {
  return (
    <View style={styles.quickActions}>
      <QuickButton
        icon="chart-box-plus-outline"
        label="Aportar"
        color={colors.primary}
        onPress={onAportar}
      />
      <QuickButton
        icon="calculator-variant"
        label="Simular"
        color={colors.purple}
        onPress={onSimular}
      />
      <QuickButton
        icon="newspaper-variant"
        label="Notícias"
        color={colors.accentTeal}
        onPress={onNoticias}
      />
      <QuickButton icon="flag" label="Metas" color={colors.warning} onPress={onMeta} />
    </View>
  );
}

function QuickButton({
  icon,
  label,
  color,
  onPress,
}: {
  icon: keyof typeof MaterialCommunityIcons.glyphMap;
  label: string;
  color: string;
  onPress: () => void;
}) {
  return (
    <Pressable onPress={onPress} style={styles.quickButton}>
      <View style={styles.quickButtonBox}>
        <MaterialCommunityIcons name={icon} size={26} color={color} />
      </View>
      <Text style={styles.quickButtonLabel}>{label}</Text>
    </Pressable>
  );
}

// ── Dica do dia ──────────────────────────────────────────────
function DicaCard() {
  return (
    <View style={styles.dicaCard}>
      <View style={styles.dicaIcon}>
        <MaterialCommunityIcons name="lightbulb" size={22} color="#FFFFFF" />
      </View>

      <View style={styles.dicaBody}>
        <View style={styles.dicaTitleRow}>
          <Text style={styles.dicaTitle}>Dica do Dia</Text>
          <View style={styles.dicaTag}>
            <Text style={styles.dicaTagText}>Risco</Text>
          </View>
        </View>
        <Text style={styles.dicaText}>
          Diversificação é a chave para reduzir riscos no seu portfólio.
        </Text>
      </View>
    </View>
  );
}

// ── Gráfico ──────────────────────────────────────────────────
function ChartSection({
  isLoading,
  totalInvested,
}: {
  isLoading: boolean;
  totalInvested: number;
}) {
  return (
    <View style={styles.chartCard}>
      <View style={styles.chartHeader}>
        <Text style={styles.chartTitle}>Evolução do Patrimônio</Text>
        <Text style={styles.chartAction}>Ver mais</Text>
      </View>
      <PatrimonioLineChart isLoading={isLoading} totalInvested={totalInvested} />
    </View>
  );
}

// ── Título de seção ──────────────────────────────────────────
function SectionTitle({
  title,
  subtitle,
  action,
  onActionPress,
}: {
  title: string;
  subtitle: string;
  action?: string | null;
  onActionPress?: () => void;
}) {
  return (
    <View style={styles.sectionTitle}>
      <Text style={styles.sectionTitleText}>{title}</Text>
      <Text style={styles.sectionSubtitle}>{subtitle}</Text>
      <View style={styles.spacer} />
      {action ? (
        <Pressable onPress={onActionPress}>
          <Text style={styles.sectionAction}>{action}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

function EmptyState({ onAdd }: { onAdd: () => void }) {
  return (
    <Pressable style={styles.emptyState} onPress={onAdd}>
      <Ionicons name="wallet-outline" size={40} color={colors.textMuted} />
      <Text style={styles.emptyText}>
        Nenhum ativo ainda.{'\n'}Adicione sua primeira operação!
      </Text>
      <View style={styles.emptyButton}>
        <Text style={styles.emptyButtonText}>Adicionar +</Text>
      </View>
    </Pressable>
  );
}

function ErrorBanner({ message }: { message: string }) {
  return (
    <View style={styles.errorBanner}>
      <Text style={styles.errorText}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  scrollContent: { paddingBottom: 12 },

  // Header
  header: {
    paddingHorizontal: 20,
    paddingBottom: 28,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerTop: { flexDirection: 'row', alignItems: 'center' },
  logoRow: { flexDirection: 'row', alignItems: 'center', flex: 1 },
  logoBox: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.20)',
    borderRadius: 10,
  },
  logoText: { marginLeft: 10, color: '#FFFFFF', fontSize: 18, fontWeight: '800' },
  logoTextAccent: { color: '#BFDBFE' },
  headerActions: { flexDirection: 'row', gap: 8 },
  headerIconButton: {
    width: 38,
    height: 38,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.20)',
  },

  patrimonioCard: {
    marginTop: 20,
    padding: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  patrimonioLabel: { color: colors.textOnBlueDim, fontSize: 14 },
  patrimonioValue: {
    marginTop: 4,
    color: colors.textOnBlue,
    fontSize: 32,
    fontWeight: '800',
  },
  patrimonioRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 14,
  },
  investedLabel: { color: colors.textOnBlueDim, fontSize: 12 },
  investedValue: { marginTop: 2, color: colors.textOnBlue, fontSize: 16, fontWeight: '700' },
  growthBadge: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    backgroundColor: alpha(colors.profit, 0.2),
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: alpha(colors.profit, 0.35),
  },
  growthText: { color: colors.textOnBlueProfit, fontSize: 13, fontWeight: '700' },
  returnText: { marginTop: 6, color: colors.textOnBlueReturn, fontSize: 13 },

  skeletonBox: { backgroundColor: 'rgba(255, 255, 255, 0.10)', borderRadius: 6 },
  skeletonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 16,
  },

  miniStats: { flexDirection: 'row', gap: 12, marginTop: 14 },
  miniStat: {
    flex: 1,
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  miniStatLabel: { color: colors.textOnBlueDim, fontSize: 12 },
  miniStatValue: { marginTop: 4, color: colors.textOnBlue, fontSize: 17, fontWeight: '700' },

  // Corpo branco
  body: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 20 },

  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  quickButton: { alignItems: 'center' },
  quickButtonBox: {
    width: 62,
    height: 62,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  quickButtonLabel: {
    marginTop: 7,
    color: colors.textSecondary,
    fontSize: 11,
    fontWeight: '600',
  },

  dicaCard: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 20,
    padding: 16,
    backgroundColor: '#EFF6FF',
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: '#BFDBFE',
  },
  dicaIcon: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2563EB',
    borderRadius: 12,
  },
  dicaBody: { flex: 1, marginLeft: 12 },
  dicaTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  dicaTitle: { color: '#1E3A8A', fontSize: 14, fontWeight: '700' },
  dicaTag: {
    paddingHorizontal: 7,
    paddingVertical: 2,
    backgroundColor: alpha('#2563EB', 0.12),
    borderRadius: radius.pill,
  },
  dicaTagText: { color: '#1D4ED8', fontSize: 10, fontWeight: '600' },
  dicaText: { marginTop: 4, color: '#1E40AF', fontSize: 12, lineHeight: 12 * 1.4 },

  chartCard: {
    marginBottom: 20,
    padding: 16,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  chartHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  chartTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '700' },
  chartAction: { color: colors.primary, fontSize: 12, fontWeight: '600' },

  sectionTitle: { flexDirection: 'row', alignItems: 'center', marginBottom: 14 },
  sectionTitleText: { color: colors.textPrimary, fontSize: 17, fontWeight: '700' },
  sectionSubtitle: { marginLeft: 8, color: colors.textMuted, fontSize: 12 },
  spacer: { flex: 1 },
  sectionAction: { color: colors.primary, fontSize: 13, fontWeight: '600' },

  skeletonCard: {
    height: 100,
    marginBottom: 12,
    backgroundColor: colors.bg3,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },

  emptyState: {
    alignItems: 'center',
    paddingVertical: 36,
    paddingHorizontal: 24,
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
  },
  emptyText: {
    marginTop: 12,
    color: colors.textSecondary,
    fontSize: 14,
    lineHeight: 14 * 1.5,
    textAlign: 'center',
  },
  emptyButton: {
    marginTop: 16,
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: alpha(colors.primary, 0.08),
    borderRadius: 20,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.2),
  },
  emptyButtonText: { color: colors.primary, fontSize: 13, fontWeight: '700' },

  errorBanner: {
    padding: 14,
    backgroundColor: alpha(colors.loss, 0.06),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.loss, 0.2),
  },
  errorText: { color: colors.loss, fontSize: 13 },

  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    height: 52,
    marginTop: 16,
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
  },
  primaryButtonPressed: { backgroundColor: colors.primaryDim },
  primaryButtonLabel: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },
});
