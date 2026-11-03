import { MaterialIcons } from '@expo/vector-icons';
import { useFocusEffect } from 'expo-router';
import { useCallback, useState } from 'react';
import { ActivityIndicator, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { ScreenHeader } from '@/components/form';
import type { Operation, PortfolioPosition } from '@/models';
import { benchmarkService, marketDataService, operationService } from '@/services';
import type { BenchmarkSeries } from '@/services/benchmarkService';
import type { QuoteResult } from '@/services/marketDataService';
import { alpha, makeStyles, radius, spacing } from '@/theme';
import { percentOfBenchmark } from '@/utils/finance';
import { currency, dateShort } from '@/utils/formatters';
import { calculatePortfolio } from '@/utils/portfolio';
import { useTheme } from '@/contexts/ThemeContext';

/**
 * RF-008 — compara o rendimento de cada ativo e da carteira com o CDI e o
 * IPCA acumulados desde a primeira compra. O rendimento usa a cotação atual
 * (BRAPI/CoinGecko); ativos sem cotação, como renda fixa, ficam de fora.
 */

type Row = {
  position: PortfolioPosition;
  since: Date;
  quote: QuoteResult | null;
  returnPercent: number | null;
};

const fmtPct = (value: number) => `${value >= 0 ? '+' : ''}${value.toFixed(2).replace('.', ',')}%`;

function monthYear(date: Date | null): string {
  if (!date) return '—';
  return `${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()}`;
}

/** Data da primeira compra de cada ativo. */
function firstBuyDates(operations: Operation[]): Record<string, Date> {
  const result: Record<string, Date> = {};
  for (const op of operations) {
    if (op.type !== 'buy') continue;
    const current = result[op.asset];
    if (!current || op.date < current) result[op.asset] = op.date;
  }
  return result;
}

export default function ComparisonScreen() {
  const styles = useStyles();
  const { colors } = useTheme();
  const [rows, setRows] = useState<Row[]>([]);
  const [benchmarks, setBenchmarks] = useState<BenchmarkSeries | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const operations = await operationService.getOperations();
      const positions = Object.values(calculatePortfolio(operations)).filter(
        (p) => p.quantity > 0,
      );
      const since = firstBuyDates(operations);

      const quotable = Object.fromEntries(
        positions
          .filter((p) => p.category !== 'fixed_income' && p.category !== 'others')
          .map((p) => [p.asset, p.category]),
      );

      const [quotes, series] = await Promise.all([
        marketDataService.getQuotes(quotable),
        benchmarkService.getBenchmarks(),
      ]);

      setBenchmarks(series);
      setRows(
        positions.map((position) => {
          const quote = quotes[position.asset] ?? null;
          const hasQuote = quote?.success && position.avgPrice > 0;
          return {
            position,
            since: since[position.asset] ?? new Date(),
            quote,
            returnPercent: hasQuote ? ((quote.price - position.avgPrice) / position.avgPrice) * 100 : null,
          };
        }),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setLoading(false);
    }
  }, []);

  useFocusEffect(
    useCallback(() => {
      load();
    }, [load]),
  );

  const priced = rows.filter((r) => r.returnPercent !== null);
  const pricedInvested = priced.reduce((sum, r) => sum + r.position.totalInvested, 0);
  const pricedValue = priced.reduce((sum, r) => sum + r.quote!.price * r.position.quantity, 0);
  const portfolioReturn = pricedInvested > 0 ? (pricedValue / pricedInvested - 1) * 100 : null;
  const portfolioSince = priced.length > 0
    ? new Date(Math.min(...priced.map((r) => r.since.getTime())))
    : null;

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Comparativo CDI e IPCA" />

      {loading ? (
        <View style={styles.centered}>
          <ActivityIndicator color={colors.primary} />
        </View>
      ) : error ? (
        <View style={styles.centered}>
          <MaterialIcons name="wifi-off" size={40} color={colors.textMuted} />
          <Text style={styles.stateTitle}>Não foi possível carregar os indicadores</Text>
          <Text style={styles.stateText}>{error}</Text>
          <Pressable style={styles.retry} onPress={load}>
            <Text style={styles.retryText}>Tentar novamente</Text>
          </Pressable>
        </View>
      ) : rows.length === 0 ? (
        <View style={styles.centered}>
          <MaterialIcons name="insights" size={40} color={colors.textMuted} />
          <Text style={styles.stateTitle}>Nenhum ativo na carteira</Text>
          <Text style={styles.stateText}>Registre uma compra para comparar com CDI e IPCA</Text>
        </View>
      ) : (
        <ScrollView contentContainerStyle={styles.content}>
          {benchmarks && portfolioReturn !== null && portfolioSince ? (
            <ComparisonCard
              title="Sua carteira"
              subtitle={`Ativos com cotação, desde ${dateShort(portfolioSince)}`}
              returnPercent={portfolioReturn}
              since={portfolioSince}
              benchmarks={benchmarks}
              highlight
            />
          ) : null}

          <Text style={styles.sectionTitle}>Por ativo</Text>

          {rows.map((row) =>
            row.returnPercent !== null && benchmarks ? (
              <ComparisonCard
                key={row.position.asset}
                title={row.position.asset}
                subtitle={`Preço médio ${currency(row.position.avgPrice)} · atual ${currency(row.quote!.price)}`}
                returnPercent={row.returnPercent}
                since={row.since}
                benchmarks={benchmarks}
              />
            ) : (
              <View key={row.position.asset} style={styles.card}>
                <Text style={styles.cardTitle}>{row.position.asset}</Text>
                <Text style={styles.cardSubtitle}>
                  Sem cotação, não é possível calcular o rendimento
                </Text>
              </View>
            ),
          )}

          <Text style={styles.footnote}>
            CDI (série 4391) e IPCA (série 433) do Banco Central, acumulados a partir do mês
            seguinte à primeira compra. O rendimento do ativo é a variação entre o preço médio e a
            cotação atual, sem dividendos, taxas ou impostos. Rentabilidade passada não garante
            resultados futuros.
          </Text>
        </ScrollView>
      )}
    </View>
  );
}

function ComparisonCard({
  title,
  subtitle,
  returnPercent,
  since,
  benchmarks,
  highlight = false,
}: {
  title: string;
  subtitle: string;
  returnPercent: number;
  since: Date;
  benchmarks: BenchmarkSeries;
  highlight?: boolean;
}) {
  const styles = useStyles();
  const { colors } = useTheme();
  const cdi = benchmarkService.accumulateSince(benchmarks.cdi, since);
  const ipca = benchmarkService.accumulateSince(benchmarks.ipca, since);
  const ofCdi = percentOfBenchmark(returnPercent, cdi.percent);
  const beatsCdi = returnPercent >= cdi.percent;
  const realReturn = ((1 + returnPercent / 100) / (1 + ipca.percent / 100) - 1) * 100;

  return (
    <View style={[styles.card, highlight && styles.cardHighlight]}>
      <View style={styles.cardHeader}>
        <View style={styles.flex}>
          <Text style={styles.cardTitle}>{title}</Text>
          <Text style={styles.cardSubtitle}>{subtitle}</Text>
        </View>
        <Text style={[styles.returnValue, { color: returnPercent >= 0 ? colors.profit : colors.loss }]}>
          {fmtPct(returnPercent)}
        </Text>
      </View>

      {cdi.months === 0 ? (
        <Text style={styles.cardSubtitle}>
          Comprado no mês atual — ainda não há mês completo de CDI e IPCA para comparar.
        </Text>
      ) : (
        <>
          <BenchmarkBar
            label="CDI"
            value={cdi.percent}
            reference={returnPercent}
            detail={`${cdi.months} meses, até ${monthYear(cdi.lastMonth)}`}
            color={colors.primary}
          />
          <BenchmarkBar
            label="IPCA"
            value={ipca.percent}
            reference={returnPercent}
            detail={`${ipca.months} meses, até ${monthYear(ipca.lastMonth)}`}
            color={colors.warning}
          />

          <View style={styles.verdictRow}>
            <MaterialIcons
              name={beatsCdi ? 'trending-up' : 'trending-down'}
              size={16}
              color={beatsCdi ? colors.profit : colors.loss}
            />
            <Text style={styles.verdictText}>
              {ofCdi !== null
                ? `${ofCdi.toFixed(0)}% do CDI · `
                : ''}
              ganho real (acima da inflação) de {fmtPct(realReturn)}
            </Text>
          </View>
        </>
      )}
    </View>
  );
}

function BenchmarkBar({
  label,
  value,
  reference,
  detail,
  color,
}: {
  label: string;
  value: number;
  reference: number;
  detail: string;
  color: string;
}) {
  const styles = useStyles();
  const max = Math.max(Math.abs(value), Math.abs(reference), 0.01);
  return (
    <View style={styles.bar}>
      <View style={styles.barLabels}>
        <Text style={styles.barLabel}>{label}</Text>
        <Text style={styles.barDetail}>{detail}</Text>
        <View style={styles.flex} />
        <Text style={[styles.barValue, { color }]}>{fmtPct(value)}</Text>
      </View>
      <View style={styles.barTrack}>
        <View
          style={[
            styles.barFill,
            { width: `${(Math.abs(value) / max) * 100}%`, backgroundColor: color },
          ]}
        />
      </View>
    </View>
  );
}

const useStyles = makeStyles((colors) => ({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },
  centered: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 32 },
  stateTitle: {
    marginTop: 12,
    color: colors.textPrimary,
    fontSize: 15,
    fontWeight: '600',
    textAlign: 'center',
  },
  stateText: { marginTop: 8, color: colors.textMuted, fontSize: 12, textAlign: 'center' },
  retry: {
    marginTop: 16,
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: colors.primary,
    borderRadius: radius.lg,
  },
  retryText: { color: '#FFFFFF', fontWeight: '600' },

  content: { padding: spacing.lg, paddingBottom: 40 },
  sectionTitle: {
    marginTop: 8,
    marginBottom: 8,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '600',
  },

  card: {
    marginBottom: 12,
    padding: spacing.lg,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  cardHighlight: { borderColor: alpha(colors.primary, 0.4), borderWidth: 1.5 },
  cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  cardTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '600' },
  cardSubtitle: { marginTop: 2, color: colors.textMuted, fontSize: 11 },
  returnValue: { fontSize: 18, fontWeight: '600' },

  bar: { marginTop: 8 },
  barLabels: { flexDirection: 'row', alignItems: 'baseline', gap: 8 },
  barLabel: { color: colors.textSecondary, fontSize: 12, fontWeight: '500' },
  barDetail: { color: colors.textMuted, fontSize: 10 },
  barValue: { fontSize: 12, fontWeight: '500' },
  barTrack: {
    height: 8,
    marginTop: 4,
    backgroundColor: colors.bg4,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  barFill: { height: 8, borderRadius: radius.pill },

  verdictRow: { flexDirection: 'row', alignItems: 'center', gap: 8, marginTop: 12 },
  verdictText: { flex: 1, color: colors.textSecondary, fontSize: 12 },

  footnote: { marginTop: 12, color: colors.textMuted, fontSize: 11, lineHeight: 16 },
}));
