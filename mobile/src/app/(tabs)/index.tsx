import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import { Pressable, RefreshControl, ScrollView, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AssetCard } from '@/components/AssetCard';
import { PatrimonioLineChart } from '@/components/PatrimonioLineChart';
import type { Operation } from '@/models';
import { operationService, profileService, transactionService } from '@/services';
import type { InvestorProfile } from '@/services/profileService';
import { alpha, makeStyles, radius, shadows } from '@/theme';
import { motion } from '@/theme/motion';
import { patrimonyHistory, type PatrimonyPoint } from '@/utils/finance';
import { currency } from '@/utils/formatters';
import { calculatePortfolio, totalInvested } from '@/utils/portfolio';
import { useTheme } from '@/contexts/ThemeContext';

/** Porte de lib/pages/home_page.dart (DashboardPage). */
export default function DashboardScreen() {
  const styles = useStyles();
  const { colors } = useTheme();
  const router = useRouter();

  const [operations, setOperations] = useState<Operation[]>([]);
  const [monthSummary, setMonthSummary] = useState({ income: 0, expense: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [profile, setProfile] = useState<InvestorProfile | null>(null);

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
      profileService.getProfile().then(setProfile).catch(() => setProfile(null));
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
        monthBalance={available}
        assetCount={positions.length}
        operationCount={operations.length}
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

        <ProfileCard profile={profile} onPress={() => router.push('/profile')} />

        <DicaCard />

        <ChartSection isLoading={loading} points={patrimonyHistory(operations)} />

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
  monthBalance,
  assetCount,
  operationCount,
  isLoading,
  onRefresh,
}: {
  total: number;
  invested: number;
  monthBalance: number;
  assetCount: number;
  operationCount: number;
  isLoading: boolean;
  onRefresh: () => void;
}) {
  const styles = useStyles();
  const { gradients } = useTheme();
  const router = useRouter();
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={gradients.header.colors}
      start={gradients.header.start}
      end={gradients.header.end}
      style={[styles.header, { paddingTop: insets.top + 16 }]}
    >
      <View style={styles.headerTop}>
        <View style={styles.logoRow}>
          <View style={styles.logoBox}>
            <MaterialIcons name="bar-chart" size={20} color="#FFFFFF" />
          </View>
          <Text style={styles.logoText}>
            Mo<Text style={styles.logoTextAccent}>Lucro</Text>
          </Text>
        </View>

        <View style={styles.headerActions}>
          <HeaderIconButton icon="refresh" onPress={onRefresh} label="Atualizar" />
          <HeaderIconButton
            icon="settings"
            onPress={() => router.push('/settings')}
            label="Configurações"
          />
        </View>
      </View>

      <View style={styles.patrimonioCard}>
        {isLoading ? (
          <PatrimonioSkeleton />
        ) : (
          <PatrimonioBody
            total={total}
            invested={invested}
            monthBalance={monthBalance}
          />
        )}
      </View>

      <View style={styles.miniStats}>
        <MiniStat label="Operações" value={`${operationCount} ${operationCount === 1 ? 'registrada' : 'registradas'}`} />
        <MiniStat label="Ativos" value={`${assetCount} ${assetCount === 1 ? 'ativo' : 'ativos'}`} />
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
  const styles = useStyles();
  return (
    <Pressable style={styles.headerIconButton} onPress={onPress} accessibilityLabel={label}>
      <MaterialIcons name={icon} size={18} color="#FFFFFF" />
    </Pressable>
  );
}

function PatrimonioBody({
  total,
  invested,
  monthBalance,
}: {
  total: number;
  invested: number;
  /** Receitas menos despesas do mês corrente (aba Transações). */
  monthBalance: number;
}) {
  const styles = useStyles();
  const { colors } = useTheme();

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

        <View style={styles.balanceColumn}>
          <Text style={styles.investedLabel}>Saldo do mês</Text>
          <Text
            style={[
              styles.investedValue,
              { color: monthBalance < 0 ? '#FCA5A5' : colors.textOnBlueReturn },
            ]}
          >
            {currency(monthBalance)}
          </Text>
        </View>
      </View>
    </View>
  );
}

function PatrimonioSkeleton() {
  const styles = useStyles();
  return (
    <View>
      <View style={[styles.skeletonBox, { width: 112, height: 12 }]} />
      <View style={[styles.skeletonBox, { width: 200, height: 32, marginTop: 8 }]} />
      <View style={styles.skeletonRow}>
        <View style={[styles.skeletonBox, { width: 100, height: 36 }]} />
        <View style={[styles.skeletonBox, { width: 72, height: 28 }]} />
      </View>
    </View>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  const styles = useStyles();
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
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <View style={styles.quickActions}>
      <QuickButton
        icon="add-chart"
        label="Aportar"
        color={colors.primary}
        onPress={onAportar}
      />
      <QuickButton
        icon="calculate"
        label="Simular"
        color={colors.primary}
        onPress={onSimular}
      />
      <QuickButton
        icon="newspaper"
        label="Notícias"
        color={colors.primary}
        onPress={onNoticias}
      />
      <QuickButton icon="flag" label="Metas" color={colors.primary} onPress={onMeta} />
    </View>
  );
}

function QuickButton({
  icon,
  label,
  color,
  onPress,
}: {
  icon: keyof typeof MaterialIcons.glyphMap;
  label: string;
  color: string;
  onPress: () => void;
}) {
  const styles = useStyles();
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [styles.quickButton, pressed && styles.quickButtonPressed]}
    >
      <View style={styles.quickButtonBox}>
        <MaterialIcons name={icon} size={24} color={color} />
      </View>
      <Text style={styles.quickButtonLabel}>{label}</Text>
    </Pressable>
  );
}

// ── Perfil do investidor ─────────────────────────────────────
const PROFILE_TITLES: Record<InvestorProfile['profile'], string> = {
  conservative: 'Conservador',
  moderate: 'Moderado',
  aggressive: 'Arrojado',
};

function ProfileCard({
  profile,
  onPress,
}: {
  profile: InvestorProfile | null;
  onPress: () => void;
}) {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <Pressable
      style={({ pressed }) => [styles.profileCard, pressed && styles.cardPressed]}
      onPress={onPress}
    >
      <View style={[styles.profileIcon, { backgroundColor: alpha(colors.primary, 0.12) }]}>
        <MaterialIcons name="person-search" size={20} color={colors.primary} />
      </View>
      <View style={styles.dicaBody}>
        <Text style={styles.profileTitle}>
          {profile ? `Perfil ${PROFILE_TITLES[profile.profile]}` : 'Qual é o seu perfil de investidor?'}
        </Text>
        <Text style={styles.profileText}>
          {profile
            ? 'Veja a alocação recomendada ou refaça o questionário'
            : 'Responda 6 perguntas e receba uma alocação de referência'}
        </Text>
      </View>
      <MaterialIcons name="chevron-right" size={20} color={colors.textMuted} />
    </Pressable>
  );
}

// ── Dica do dia ──────────────────────────────────────────────
function DicaCard() {
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <View style={styles.dicaCard}>
      <View style={styles.dicaIcon}>
        <MaterialIcons name="lightbulb-outline" size={20} color={colors.textSecondary} />
      </View>

      <View style={styles.dicaBody}>
        <View style={styles.dicaTitleRow}>
          <Text style={styles.dicaTitle}>Dica do Dia</Text>
          <View style={styles.dicaTag}>
            <Text style={styles.dicaTagText}>Risco</Text>
          </View>
        </View>
        <Text style={styles.dicaText}>
          Distribuir o dinheiro entre classes de ativos reduz o impacto de uma queda isolada
        </Text>
      </View>
    </View>
  );
}

// ── Gráfico ──────────────────────────────────────────────────
function ChartSection({ isLoading, points }: { isLoading: boolean; points: PatrimonyPoint[] }) {
  const styles = useStyles();
  return (
    <View style={styles.chartCard}>
      <View style={styles.chartHeader}>
        <Text style={styles.chartTitle}>Evolução do Patrimônio</Text>
        <Text style={styles.chartAction}>Valor investido nos últimos 6 meses</Text>
      </View>
      <PatrimonioLineChart isLoading={isLoading} points={points} />
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
  const styles = useStyles();
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
  const styles = useStyles();
  const { colors } = useTheme();
  return (
    <Pressable style={styles.emptyState} onPress={onAdd}>
      <MaterialIcons name="account-balance-wallet" size={40} color={colors.textMuted} />
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
  const styles = useStyles();
  return (
    <View style={styles.errorBanner}>
      <Text style={styles.errorText}>{message}</Text>
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
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
  logoText: { marginLeft: 8, color: '#FFFFFF', fontSize: 18, fontWeight: '600' },
  logoTextAccent: { color: '#BFDBFE' },
  headerActions: { flexDirection: 'row', gap: 8 },
  headerIconButton: {
    width: 40,
    height: 40,
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
    fontWeight: '600',
  },
  balanceColumn: { alignItems: 'flex-end' },
  patrimonioRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 12,
  },
  investedLabel: { color: colors.textOnBlueDim, fontSize: 12 },
  investedValue: { marginTop: 2, color: colors.textOnBlue, fontSize: 16, fontWeight: '600' },

  skeletonBox: { backgroundColor: 'rgba(255, 255, 255, 0.10)', borderRadius: 6 },
  skeletonRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 16,
  },

  miniStats: { flexDirection: 'row', gap: 12, marginTop: 12 },
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
  miniStatValue: { marginTop: 4, color: colors.textOnBlue, fontSize: 17, fontWeight: '600' },

  // Corpo branco
  body: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 20 },

  quickActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  quickButton: { alignItems: 'center' },
  quickButtonBox: {
    width: 64,
    height: 64,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  quickButtonLabel: {
    marginTop: 8,
    color: colors.textSecondary,
    fontSize: 11,
    fontWeight: '500',
  },

  profileCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    marginBottom: 12,
    padding: 20,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  cardPressed: { backgroundColor: colors.surfacePressed },
  quickButtonPressed: { opacity: 0.8, transform: [{ scale: motion.pressScale }] },
  profileIcon: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.md,
  },
  profileTitle: { color: colors.textPrimary, fontSize: 14, fontWeight: '500' },
  profileText: { marginTop: 2, color: colors.textSecondary, fontSize: 12 },

  dicaCard: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 20,
    padding: 20,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  dicaIcon: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.bg3,
    borderRadius: 12,
  },
  dicaBody: { flex: 1, marginLeft: 12 },
  dicaTitleRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  dicaTitle: { color: colors.textPrimary, fontSize: 14, fontWeight: '500' },
  dicaTag: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    backgroundColor: alpha(colors.primary, 0.12),
    borderRadius: radius.pill,
  },
  dicaTagText: { color: colors.primary, fontSize: 10, fontWeight: '500' },
  dicaText: { marginTop: 4, color: colors.textSecondary, fontSize: 12, lineHeight: 12 * 1.4 },

  chartCard: {
    marginBottom: 20,
    padding: 20,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  chartHeader: { gap: 2, marginBottom: 12 },
  chartTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '600' },
  chartAction: { color: colors.textMuted, fontSize: 11, fontWeight: '500' },

  sectionTitle: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  sectionTitleText: { color: colors.textPrimary, fontSize: 17, fontWeight: '600' },
  sectionSubtitle: { marginLeft: 8, color: colors.textMuted, fontSize: 12 },
  spacer: { flex: 1 },
  sectionAction: { color: colors.primary, fontSize: 13, fontWeight: '500' },

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
    paddingVertical: 12,
    backgroundColor: alpha(colors.primary, 0.08),
    borderRadius: 20,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.2),
  },
  emptyButtonText: { color: colors.primary, fontSize: 13, fontWeight: '500' },

  errorBanner: {
    padding: 16,
    backgroundColor: alpha(colors.loss, 0.06),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.loss, 0.2),
  },
  errorText: { color: colors.loss, fontSize: 13 },

}));
