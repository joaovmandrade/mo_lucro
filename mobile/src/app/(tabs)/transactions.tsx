import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { TransactionTile } from '@/components/TransactionTile';
import { isIncome, type Transaction } from '@/models';
import { transactionService } from '@/services';
import { alpha, colors, gradients, radius } from '@/theme';
import { currency, dateFull, month as monthLabel } from '@/utils/formatters';

/** Porte de lib/pages/transactions_page.dart. */

type Filter = 'all' | 'income' | 'expense';

export default function TransactionsScreen() {
  const router = useRouter();

  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [filter, setFilter] = useState<Filter>('all');
  const [month, setMonth] = useState(new Date());

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setTransactions(await transactionService.getTransactions());
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

  async function remove(id: string) {
    await transactionService.deleteTransaction(id);
    load();
  }

  function prevMonth() {
    setMonth((current) => new Date(current.getFullYear(), current.getMonth() - 1, 1));
  }

  function nextMonth() {
    setMonth((current) => {
      const next = new Date(current.getFullYear(), current.getMonth() + 1, 1);
      // Mesma trava do Flutter: não avança além de ~1 mês à frente de hoje.
      const limit = new Date();
      limit.setDate(limit.getDate() + 31);
      return next < limit ? next : current;
    });
  }

  const inMonth = transactions.filter(
    (tx) =>
      tx.date.getFullYear() === month.getFullYear() && tx.date.getMonth() === month.getMonth(),
  );
  const filtered = filter === 'all' ? inMonth : inMonth.filter((tx) => tx.type === filter);

  const income = filtered.filter(isIncome).reduce((sum, tx) => sum + tx.amount, 0);
  const expense = filtered.filter((tx) => !isIncome(tx)).reduce((sum, tx) => sum + tx.amount, 0);
  const net = income - expense;
  const isPositiveNet = net >= 0;

  // Agrupa por dia, preservando a ordem em que as transações vieram.
  const groups = new Map<string, Transaction[]>();
  for (const tx of filtered) {
    const key = dateFull(tx.date);
    const group = groups.get(key);
    if (group) group.push(tx);
    else groups.set(key, [tx]);
  }

  return (
    <View style={styles.screen}>
      <ScrollView
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
        <TransactionsHeader
          month={month}
          income={income}
          expense={expense}
          net={net}
          isPositiveNet={isPositiveNet}
          isLoading={loading}
          onPrevMonth={prevMonth}
          onNextMonth={nextMonth}
        />

        <View style={styles.body}>
          <View style={styles.filters}>
            <FilterChip
              label="Todos"
              active={filter === 'all'}
              onPress={() => setFilter('all')}
            />
            <FilterChip
              label="Receitas"
              active={filter === 'income'}
              color={colors.profit}
              onPress={() => setFilter('income')}
            />
            <FilterChip
              label="Despesas"
              active={filter === 'expense'}
              color={colors.loss}
              onPress={() => setFilter('expense')}
            />
          </View>

          {loading ? (
            <View style={styles.centerBlock}>
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : filtered.length === 0 ? (
            <View style={styles.centerBlock}>
              <MaterialIcons name="receipt-long" size={40} color={colors.textMuted} />
              <Text style={styles.emptyText}>
                {filter === 'all'
                  ? 'Nenhuma transação neste mês'
                  : 'Nenhum registro nesta categoria'}
              </Text>
            </View>
          ) : (
            Array.from(groups.entries()).map(([date, items]) => (
              <View key={date}>
                <Text style={styles.groupDate}>{date}</Text>
                {items.map((tx) => (
                  <TransactionTile key={tx.id} transaction={tx} onDelete={() => remove(tx.id)} />
                ))}
              </View>
            ))
          )}
        </View>
      </ScrollView>

      <Pressable
        style={({ pressed }) => [styles.fab, pressed && styles.fabPressed]}
        onPress={() => router.push('/transactions/new')}
        accessibilityLabel="Nova transação"
      >
        <MaterialIcons name="add" size={26} color="#FFFFFF" />
      </Pressable>
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
function TransactionsHeader({
  month,
  income,
  expense,
  net,
  isPositiveNet,
  isLoading,
  onPrevMonth,
  onNextMonth,
}: {
  month: Date;
  income: number;
  expense: number;
  net: number;
  isPositiveNet: boolean;
  isLoading: boolean;
  onPrevMonth: () => void;
  onNextMonth: () => void;
}) {
  const insets = useSafeAreaInsets();

  return (
    <LinearGradient
      colors={gradients.header.colors}
      start={gradients.header.start}
      end={gradients.header.end}
      style={[styles.header, { paddingTop: insets.top + 14 }]}
    >
      <View style={styles.headerTop}>
        <Text style={styles.headerTitle}>Transações</Text>

        <View style={styles.monthNav}>
          <Pressable style={styles.monthButton} onPress={onPrevMonth} accessibilityLabel="Mês anterior">
            <MaterialIcons name="chevron-left" size={18} color="#FFFFFF" />
          </Pressable>
          <Text style={styles.monthLabel}>{monthLabel(month)}</Text>
          <Pressable style={styles.monthButton} onPress={onNextMonth} accessibilityLabel="Próximo mês">
            <MaterialIcons name="chevron-right" size={18} color="#FFFFFF" />
          </Pressable>
        </View>
      </View>

      <View style={styles.summaryCard}>
        {isLoading ? (
          <HeaderSkeleton />
        ) : (
          <>
            <View style={styles.summaryRow}>
              <SummaryColumn
                icon="arrow-upward"
                iconColor="#6EE7B7"
                label="Receitas"
                value={currency(income)}
                valueColor="#6EE7B7"
              />
              <View style={styles.summaryDivider} />
              <SummaryColumn
                icon="arrow-downward"
                iconColor="#FCA5A5"
                label="Despesas"
                value={currency(expense)}
                valueColor="#FCA5A5"
              />
            </View>

            <View style={styles.horizontalDivider} />

            <View style={styles.netRow}>
              <View style={styles.netLabelRow}>
                <MaterialIcons
                  name={isPositiveNet ? 'trending-up' : 'trending-down'}
                  size={15}
                  color={colors.textOnBlueDim}
                />
                <Text style={styles.netLabel}>Saldo do mês</Text>
              </View>
              <Text style={[styles.netValue, { color: isPositiveNet ? '#6EE7B7' : '#FCA5A5' }]}>
                {isPositiveNet ? '+' : ''}
                {currency(net)}
              </Text>
            </View>
          </>
        )}
      </View>
    </LinearGradient>
  );
}

function SummaryColumn({
  icon,
  iconColor,
  label,
  value,
  valueColor,
}: {
  icon: keyof typeof MaterialIcons.glyphMap;
  iconColor: string;
  label: string;
  value: string;
  valueColor: string;
}) {
  return (
    <View style={styles.summaryColumn}>
      <View style={styles.summaryLabelRow}>
        <MaterialIcons name={icon} size={13} color={iconColor} />
        <Text style={styles.summaryLabel}>{label}</Text>
      </View>
      <Text style={[styles.summaryValue, { color: valueColor }]} numberOfLines={1} adjustsFontSizeToFit>
        {value}
      </Text>
    </View>
  );
}

function HeaderSkeleton() {
  return (
    <View>
      <View style={styles.skeletonRow}>
        <View style={[styles.skeletonBox, { width: 90, height: 32 }]} />
        <View style={[styles.skeletonBox, { width: 90, height: 32, marginLeft: 16 }]} />
      </View>
      <View style={[styles.skeletonBox, { width: '100%', height: 1, marginTop: 14 }]} />
      <View style={[styles.skeletonRow, { marginTop: 14, justifyContent: 'space-between' }]}>
        <View style={[styles.skeletonBox, { width: 90, height: 13 }]} />
        <View style={[styles.skeletonBox, { width: 80, height: 15 }]} />
      </View>
    </View>
  );
}

function FilterChip({
  label,
  active,
  color = colors.primary,
  onPress,
}: {
  label: string;
  active: boolean;
  color?: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.chip,
        active && { backgroundColor: alpha(color, 0.12), borderColor: color, borderWidth: 1.5 },
      ]}
    >
      <Text style={[styles.chipText, active && { color }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },

  header: {
    paddingHorizontal: 20,
    paddingBottom: 28,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerTop: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  headerTitle: { color: colors.textOnBlue, fontSize: 22, fontWeight: '800' },
  monthNav: { flexDirection: 'row', alignItems: 'center', gap: 10 },
  monthButton: {
    width: 34,
    height: 34,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.20)',
  },
  monthLabel: {
    color: colors.textOnBlue,
    fontSize: 14,
    fontWeight: '700',
    textTransform: 'capitalize',
  },

  summaryCard: {
    marginTop: 20,
    padding: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  summaryRow: { flexDirection: 'row', alignItems: 'center' },
  summaryColumn: { flex: 1 },
  summaryLabelRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  summaryLabel: { color: colors.textOnBlueDim, fontSize: 12 },
  summaryValue: { marginTop: 4, fontSize: 16, fontWeight: '700' },
  summaryDivider: {
    width: 1,
    height: 36,
    marginHorizontal: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
  },
  horizontalDivider: {
    height: 1,
    marginVertical: 14,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
  },
  netRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  netLabelRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  netLabel: { color: colors.textOnBlueDim, fontSize: 13 },
  netValue: { fontSize: 15, fontWeight: '800' },

  skeletonBox: { backgroundColor: 'rgba(255, 255, 255, 0.10)', borderRadius: 6 },
  skeletonRow: { flexDirection: 'row', alignItems: 'center' },

  body: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 100 },
  filters: { flexDirection: 'row', gap: 8, marginBottom: 16 },
  chip: {
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: colors.bg1,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  chipText: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },

  centerBlock: { paddingVertical: 40, alignItems: 'center' },
  emptyText: { marginTop: 12, color: colors.textSecondary, fontSize: 14, textAlign: 'center' },
  groupDate: {
    marginTop: 4,
    marginBottom: 8,
    color: colors.textMuted,
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 0.3,
  },

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
});
