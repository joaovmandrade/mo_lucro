import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { useEffect, useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import type { PortfolioPosition } from '@/models';
import { profitLoss, profitLossPercent } from '@/models';
import { marketDataService } from '@/services';
import { alpha, colors, radius, shadows } from '@/theme';
import {
  categoryColor,
  categoryTagColor,
  categoryTagLabel,
  companyName,
  quantityLabel,
} from '@/utils/categories';
import { currency, percentSimple } from '@/utils/formatters';

/** Porte de lib/widgets/asset_card.dart. */
export function AssetCard({
  position,
  onDelete,
}: {
  position: PortfolioPosition;
  onDelete?: () => void;
}) {
  const [currentPrice, setCurrentPrice] = useState<number | null>(null);
  const [changePercent, setChangePercent] = useState<number | null>(null);

  useEffect(() => {
    let active = true;

    async function fetchPrice() {
      // Renda fixa e "outros" não têm cotação de mercado.
      if (position.category === 'fixed_income' || position.category === 'others') return;

      const quote = await marketDataService.getQuote(position.asset, position.category);
      if (!active) return;

      setCurrentPrice(quote.success ? quote.price : null);
      setChangePercent(quote.success ? quote.changePercent : null);
    }

    fetchPrice();
    return () => {
      active = false;
    };
  }, [position.asset, position.category]);

  const price = currentPrice ?? position.avgPrice;
  const pnl = profitLoss(position, price);
  const pnlPercent = profitLossPercent(position, price);
  const isProfit = pnl >= 0;
  const hasPriceData = currentPrice !== null;

  return (
    <View style={styles.card}>
      <View style={styles.top}>
        <Avatar asset={position.asset} category={position.category} />

        <View style={styles.info}>
          <View style={styles.assetRow}>
            <Text style={styles.asset}>{position.asset}</Text>
            <CategoryTag category={position.category} />
          </View>
          <Text style={styles.company}>{companyName(position.asset, position.category)}</Text>
          <Text style={styles.quantity}>{quantityLabel(position.quantity)} ações</Text>
        </View>

        <View style={styles.right}>
          {onDelete ? (
            <Pressable onPress={onDelete} style={styles.deleteButton} accessibilityLabel="Excluir">
              <MaterialIcons name="delete-outline" size={15} color={colors.loss} />
            </Pressable>
          ) : null}

          <Text style={styles.value}>{currency(position.quantity * price)}</Text>
          <PnlBadge percent={pnlPercent} isProfit={isProfit} />
        </View>
      </View>

      <View style={styles.metrics}>
        <Metric label="Preço Médio" value={currency(position.avgPrice)} />
        <View style={styles.metricDivider} />
        <Metric
          label={hasPriceData ? 'Preço Atual' : 'Total'}
          value={currency(hasPriceData ? currentPrice : position.totalInvested)}
        />
        <View style={styles.metricDivider} />
        <Metric label="Investido" value={currency(position.totalInvested)} align="flex-end" />
      </View>
    </View>
  );
}

function Avatar({ asset, category }: { asset: string; category: string }) {
  const color = categoryColor(category);

  return (
    <View
      style={[
        styles.avatar,
        { backgroundColor: alpha(color, 0.1), borderColor: alpha(color, 0.22) },
      ]}
    >
      <Text style={[styles.avatarText, { color }]}>
        {asset.length > 2 ? asset.slice(0, 2) : asset}
      </Text>
    </View>
  );
}

function CategoryTag({ category }: { category: string }) {
  const color = categoryTagColor(category);

  return (
    <View
      style={[styles.tag, { backgroundColor: alpha(color, 0.08), borderColor: alpha(color, 0.2) }]}
    >
      <Text style={[styles.tagText, { color }]}>{categoryTagLabel(category)}</Text>
    </View>
  );
}

function PnlBadge({ percent, isProfit }: { percent: number; isProfit: boolean }) {
  const color = isProfit ? colors.profitDark : colors.loss;
  const backgroundColor = isProfit ? alpha(colors.profit, 0.1) : alpha(colors.loss, 0.08);

  return (
    <View style={[styles.pnlBadge, { backgroundColor }]}>
      <Ionicons name={isProfit ? 'caret-up' : 'caret-down'} size={11} color={color} />
      <Text style={[styles.pnlText, { color }]}>{percentSimple(Math.abs(percent))}</Text>
    </View>
  );
}

function Metric({
  label,
  value,
  align = 'flex-start',
}: {
  label: string;
  value: string;
  align?: 'flex-start' | 'flex-end';
}) {
  return (
    <View style={[styles.metric, { alignItems: align }]}>
      <Text style={styles.metricLabel}>{label}</Text>
      <Text style={styles.metricValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    marginBottom: 12,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  top: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  info: { flex: 1, marginLeft: 12 },
  assetRow: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  asset: { color: colors.textPrimary, fontSize: 17, fontWeight: '800' },
  company: { color: colors.textSecondary, fontSize: 13, marginTop: 3 },
  quantity: { color: colors.textMuted, fontSize: 11, marginTop: 2 },
  right: { alignItems: 'flex-end' },
  deleteButton: {
    width: 28,
    height: 28,
    marginBottom: 6,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: alpha(colors.loss, 0.08),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.loss, 0.2),
  },
  value: { color: colors.textPrimary, fontSize: 17, fontWeight: '800' },
  avatar: {
    width: 44,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
    borderWidth: 1,
  },
  avatarText: { fontSize: 13, fontWeight: '800' },
  tag: {
    paddingHorizontal: 7,
    paddingVertical: 2,
    borderRadius: radius.pill,
    borderWidth: 1,
  },
  tagText: { fontSize: 9, fontWeight: '600' },
  pnlBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 4,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: radius.sm,
  },
  pnlText: { fontSize: 11, fontWeight: '700', marginLeft: 2 },
  metrics: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: colors.bg3,
    borderBottomLeftRadius: radius.lg,
    borderBottomRightRadius: radius.lg,
  },
  metric: { flex: 1 },
  metricDivider: {
    width: 1,
    height: 28,
    marginHorizontal: 8,
    backgroundColor: colors.border,
  },
  metricLabel: { color: colors.textMuted, fontSize: 10, fontWeight: '500' },
  metricValue: { color: colors.textPrimary, fontSize: 11, fontWeight: '700', marginTop: 2 },
});
