import { MaterialIcons } from '@expo/vector-icons';
import ReanimatedSwipeable from 'react-native-gesture-handler/ReanimatedSwipeable';
import { StyleSheet, Text, View } from 'react-native';

import { isIncome as isIncomeTx, type Transaction } from '@/models';
import { alpha, colors, radius, shadows } from '@/theme';
import { currency, dateShort } from '@/utils/formatters';
import { transactionCategoryIcon, transactionCategoryLabel } from '@/utils/transactionCategories';

/** Porte de lib/widgets/transaction_tile.dart. */
export function TransactionTile({
  transaction,
  onDelete,
}: {
  transaction: Transaction;
  onDelete?: () => void;
}) {
  const income = isIncomeTx(transaction);
  const color = income ? colors.profit : colors.loss;
  const label = transactionCategoryLabel(transaction.category);

  const tile = (
    <View style={styles.tile}>
      <View
        style={[
          styles.icon,
          { backgroundColor: alpha(color, 0.1), borderColor: alpha(color, 0.2) },
        ]}
      >
        <MaterialIcons
          name={transactionCategoryIcon(transaction.category, income)}
          size={18}
          color={color}
        />
      </View>

      <View style={styles.info}>
        <Text style={styles.description} numberOfLines={1}>
          {transaction.description.length > 0 ? transaction.description : label}
        </Text>

        <View style={styles.metaRow}>
          <View style={[styles.chip, { backgroundColor: alpha(color, 0.08) }]}>
            <Text style={[styles.chipText, { color: alpha(color, 0.8) }]}>{label}</Text>
          </View>
          <Text style={styles.date}>{dateShort(transaction.date)}</Text>
        </View>
      </View>

      <Text style={[styles.amount, { color }]}>
        {income ? '+' : '-'} {currency(transaction.amount)}
      </Text>
    </View>
  );

  if (!onDelete) return tile;

  // Equivale ao Dismissible endToStart: arrasta da direita para a esquerda.
  return (
    <ReanimatedSwipeable
      friction={2}
      rightThreshold={40}
      onSwipeableOpen={(direction) => {
        if (direction === 'right') onDelete();
      }}
      renderRightActions={() => (
        <View style={styles.deleteBackground}>
          <MaterialIcons name="delete-outline" size={20} color={colors.loss} />
        </View>
      )}
    >
      {tile}
    </ReanimatedSwipeable>
  );
}

const styles = StyleSheet.create({
  tile: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  icon: {
    width: 42,
    height: 42,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.md,
    borderWidth: 1,
  },
  info: { flex: 1, marginLeft: 12 },
  description: { color: colors.textPrimary, fontSize: 14, fontWeight: '600' },
  metaRow: { flexDirection: 'row', alignItems: 'center', marginTop: 3, gap: 6 },
  chip: {
    paddingHorizontal: 7,
    paddingVertical: 2,
    borderRadius: radius.sm,
  },
  chipText: { fontSize: 10, fontWeight: '600' },
  date: { color: colors.textMuted, fontSize: 11 },
  amount: { fontSize: 14, fontWeight: '700' },
  deleteBackground: {
    justifyContent: 'center',
    alignItems: 'flex-end',
    paddingRight: 20,
    marginBottom: 10,
    backgroundColor: alpha(colors.loss, 0.12),
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: alpha(colors.loss, 0.25),
  },
});
