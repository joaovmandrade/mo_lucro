import { useState } from 'react';
import { Pressable, StyleSheet, Text, TextInput, View } from 'react-native';

import { alpha, colors, radius, shadows } from '@/theme';
import { currency } from '@/utils/formatters';

/**
 * Calculadora da aula “Juros compostos e o tempo”.
 *
 * Aportes mensais iguais, feitos no fim de cada mês, com a taxa anual
 * convertida para a taxa mensal equivalente: (1 + anual)^(1/12) − 1.
 * É uma ilustração didática, não uma projeção de retorno.
 */

const YEAR_SHORTCUTS = [5, 10, 20, 30];

function parseNumber(text: string): number {
  const value = Number.parseFloat(text.replace(',', '.'));
  return Number.isFinite(value) && value > 0 ? value : 0;
}

function project(monthly: number, annualPercent: number, years: number) {
  const months = Math.round(years * 12);
  const monthlyRate = Math.pow(1 + annualPercent / 100, 1 / 12) - 1;

  const contributed = monthly * months;
  const accumulated =
    monthlyRate === 0
      ? contributed
      : monthly * ((Math.pow(1 + monthlyRate, months) - 1) / monthlyRate);

  return {
    monthlyRate,
    contributed,
    accumulated,
    earnings: accumulated - contributed,
  };
}

export function CompoundCalculator() {
  const [monthlyText, setMonthlyText] = useState('500');
  const [rateText, setRateText] = useState('10');
  const [yearsText, setYearsText] = useState('10');

  const monthly = parseNumber(monthlyText);
  const rate = Math.min(parseNumber(rateText), 100);
  const years = Math.min(parseNumber(yearsText), 60);

  const { monthlyRate, contributed, accumulated, earnings } = project(monthly, rate, years);

  const earningsShare = accumulated > 0 ? earnings / accumulated : 0;
  const hasResult = accumulated > 0;

  return (
    <View style={styles.card}>
      <View style={styles.inputsRow}>
        <Field
          label="Aporte mensal"
          prefix="R$"
          value={monthlyText}
          onChangeText={setMonthlyText}
        />
        <Field label="Taxa ao ano" suffix="%" value={rateText} onChangeText={setRateText} />
        <Field label="Prazo" suffix="anos" value={yearsText} onChangeText={setYearsText} />
      </View>

      <View style={styles.shortcuts}>
        {YEAR_SHORTCUTS.map((option) => {
          const selected = years === option;
          return (
            <Pressable
              key={option}
              onPress={() => setYearsText(String(option))}
              style={[styles.shortcut, selected && styles.shortcutSelected]}
              accessibilityRole="button"
              accessibilityLabel={`Prazo de ${option} anos`}
              accessibilityState={{ selected }}
            >
              <Text style={[styles.shortcutText, selected && styles.shortcutTextSelected]}>
                {option} anos
              </Text>
            </Pressable>
          );
        })}
      </View>

      <View style={styles.result}>
        <Text style={styles.resultLabel}>Valor acumulado</Text>
        <Text style={styles.resultValue} accessibilityLiveRegion="polite">
          {currency(accumulated)}
        </Text>

        <View style={styles.bar}>
          {hasResult ? (
            <>
              <View style={[styles.barPart, styles.barContributed, { flex: 1 - earningsShare }]} />
              <View style={[styles.barPart, styles.barEarnings, { flex: earningsShare }]} />
            </>
          ) : null}
        </View>

        <View style={styles.legendRow}>
          <View style={styles.legendItem}>
            <View style={[styles.dot, styles.barContributed]} />
            <View>
              <Text style={styles.legendLabel}>Aportado por você</Text>
              <Text style={styles.legendValue}>{currency(contributed)}</Text>
            </View>
          </View>
          <View style={styles.legendItem}>
            <View style={[styles.dot, styles.barEarnings]} />
            <View>
              <Text style={styles.legendLabel}>Gerado pelos juros</Text>
              <Text style={styles.legendValue}>{currency(earnings)}</Text>
            </View>
          </View>
        </View>

        <Text style={styles.note}>
          Taxa mensal equivalente: {(monthlyRate * 100).toFixed(3).replace('.', ',')}%. Valores
          ilustrativos, sem impostos, taxas nem inflação.
        </Text>
      </View>
    </View>
  );
}

function Field({
  label,
  prefix,
  suffix,
  value,
  onChangeText,
}: {
  label: string;
  prefix?: string;
  suffix?: string;
  value: string;
  onChangeText: (text: string) => void;
}) {
  return (
    <View style={styles.field}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <View style={styles.fieldInputRow}>
        {prefix ? <Text style={styles.fieldAffix}>{prefix}</Text> : null}
        <TextInput
          style={styles.fieldInput}
          value={value}
          onChangeText={onChangeText}
          keyboardType="decimal-pad"
          selectTextOnFocus
          accessibilityLabel={label}
          placeholder="0"
          placeholderTextColor={colors.textMuted}
        />
        {suffix ? <Text style={styles.fieldAffix}>{suffix}</Text> : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    padding: 16,
    backgroundColor: colors.bg1,
    borderRadius: radius.xl,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },

  inputsRow: { flexDirection: 'row', gap: 8 },
  field: { flex: 1 },
  fieldLabel: { color: colors.textSecondary, fontSize: 11, fontWeight: '600' },
  fieldInputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginTop: 6,
    paddingHorizontal: 10,
    backgroundColor: colors.bg3,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  fieldAffix: { color: colors.textMuted, fontSize: 12, fontWeight: '600' },
  fieldInput: {
    flex: 1,
    minWidth: 0,
    paddingVertical: 10,
    color: colors.textPrimary,
    fontSize: 15,
    fontWeight: '700',
  },

  shortcuts: { flexDirection: 'row', gap: 8, marginTop: 12 },
  shortcut: {
    paddingHorizontal: 12,
    paddingVertical: 7,
    backgroundColor: colors.bg1,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  shortcutSelected: {
    backgroundColor: alpha(colors.primary, 0.12),
    borderColor: alpha(colors.primary, 0.3),
  },
  shortcutText: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },
  shortcutTextSelected: { color: colors.primary },

  result: {
    marginTop: 16,
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: colors.borderLight,
  },
  resultLabel: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },
  resultValue: {
    marginTop: 4,
    color: colors.textPrimary,
    fontSize: 30,
    fontWeight: '800',
  },

  bar: {
    flexDirection: 'row',
    height: 10,
    marginTop: 14,
    backgroundColor: colors.bg4,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  barPart: { height: 10 },
  barContributed: { backgroundColor: colors.primary },
  barEarnings: { backgroundColor: colors.profit },

  legendRow: { flexDirection: 'row', gap: 12, marginTop: 14 },
  legendItem: { flex: 1, flexDirection: 'row', alignItems: 'flex-start', gap: 8 },
  dot: { width: 10, height: 10, marginTop: 3, borderRadius: radius.pill },
  legendLabel: { color: colors.textSecondary, fontSize: 11 },
  legendValue: { marginTop: 2, color: colors.textPrimary, fontSize: 14, fontWeight: '700' },

  note: {
    marginTop: 14,
    color: colors.textMuted,
    fontSize: 11,
    lineHeight: 11 * 1.45,
  },
});
