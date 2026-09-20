import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { alpha, colors, gradients, radius, shadows, spacing } from '@/theme';
import { currency } from '@/utils/formatters';

/** Porte de lib/pages/income_simulator_page.dart. */

type BankRate = { name: string; annualRate: number };

// Taxas anuais aproximadas, como no Flutter.
const BANKS: BankRate[] = [
  { name: 'Nubank', annualRate: 0.1375 },
  { name: 'Inter', annualRate: 0.13 },
  { name: 'C6 Bank', annualRate: 0.1125 },
  { name: 'Selic', annualRate: 0.135 },
  { name: 'Poupança', annualRate: 0.077 },
];

export default function SimulatorScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  const [initialText, setInitialText] = useState('1000');
  const [monthlyText, setMonthlyText] = useState('500');
  const [periodText, setPeriodText] = useState('12');

  const initial = Number.parseFloat(initialText.replace(',', '.')) || 0;
  const monthly = Number.parseFloat(monthlyText.replace(',', '.')) || 0;
  const period = Number.parseInt(periodText, 10) || 0;

  const invested = initial + monthly * period;

  /**
   * Mesma conta do _calcFinal do Flutter: juros simples sobre o total aportado,
   * proporcional ao período em anos. (O método Dart também calculava um valor
   * futuro composto, mas descartava o resultado — só esta linha valia.)
   */
  function finalValue(rate: number): number {
    if (period <= 0) return invested;
    return invested + invested * rate * (period / 12);
  }

  function returnValue(rate: number): number {
    return finalValue(rate) - invested;
  }

  return (
    <View style={styles.screen}>
      <LinearGradient
        colors={gradients.header.colors}
        start={gradients.header.start}
        end={gradients.header.end}
        style={[styles.header, { paddingTop: insets.top + 12 }]}
      >
        <View style={styles.headerCard}>
          <Pressable
            style={styles.backButton}
            onPress={() => router.back()}
            accessibilityLabel="Voltar"
          >
            <MaterialIcons name="arrow-back-ios-new" size={16} color={colors.textOnBlue} />
          </Pressable>
          <Text style={styles.headerTitle}>Simulador de Rendimento</Text>
        </View>
      </LinearGradient>

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
          <View style={styles.inputCard}>
            <Text style={styles.cardTitle}>Dados da Simulação</Text>

            <InputRow
              label="Investimento Inicial"
              value={initialText}
              onChangeText={setInitialText}
              prefix="R$ "
            />
            <InputRow
              label="Aporte Mensal"
              value={monthlyText}
              onChangeText={setMonthlyText}
              prefix="R$ "
            />
            <InputRow
              label="Período (meses)"
              value={periodText}
              onChangeText={setPeriodText}
              suffix="meses"
            />
          </View>

          <View style={styles.summary}>
            <StatBox label="Total Investido" value={currency(invested)} color={colors.textSecondary} />
            <View style={styles.summaryDivider} />
            <StatBox label="Período" value={`${period} meses`} color={colors.primary} />
          </View>

          <Text style={styles.sectionTitle}>Comparação entre Bancos</Text>

          {BANKS.map((bank) => (
            <View key={bank.name} style={styles.bankRow}>
              <View style={styles.bankInfo}>
                <Text style={styles.bankName}>{bank.name}</Text>
                <Text style={styles.bankRate}>{(bank.annualRate * 100).toFixed(2)}% a.a.</Text>
              </View>

              <View style={styles.bankValues}>
                <Text style={styles.bankFinal}>{currency(finalValue(bank.annualRate))}</Text>
                <Text style={styles.bankReturn}>+{currency(returnValue(bank.annualRate))}</Text>
              </View>
            </View>
          ))}

          <Text style={styles.disclaimer}>
            * Simulação simplificada baseada em taxa anual fixa. Rendimentos reais variam conforme
            a taxa Selic e condições de cada banco.
          </Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
}

function InputRow({
  label,
  value,
  onChangeText,
  prefix,
  suffix,
}: {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  prefix?: string;
  suffix?: string;
}) {
  return (
    <View style={styles.inputRow}>
      <Text style={styles.inputLabel}>{label}</Text>

      <View style={styles.inputBox}>
        {prefix ? <Text style={styles.inputPrefix}>{prefix}</Text> : null}
        <TextInput
          value={value}
          onChangeText={onChangeText}
          keyboardType="decimal-pad"
          style={styles.input}
        />
        {suffix ? <Text style={styles.inputSuffix}>{suffix}</Text> : null}
      </View>
    </View>
  );
}

function StatBox({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <View style={styles.statBox}>
      <Text style={styles.statLabel}>{label}</Text>
      <Text style={[styles.statValue, { color }]}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },

  header: {
    paddingHorizontal: 16,
    paddingBottom: 20,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  headerCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  backButton: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderRadius: 18,
  },
  headerTitle: { flex: 1, color: colors.textOnBlue, fontSize: 18, fontWeight: '700' },

  content: { padding: spacing.lg, paddingBottom: 40 },

  inputCard: {
    padding: spacing.lg,
    backgroundColor: colors.bg1,
    borderRadius: radius.xxl,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  cardTitle: { color: colors.textPrimary, fontSize: 16, fontWeight: '700', marginBottom: 16 },

  inputRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  inputLabel: { flex: 2, color: colors.textSecondary, fontSize: 13 },
  inputBox: {
    flex: 3,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    backgroundColor: colors.bg4,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  inputPrefix: { color: colors.textSecondary, fontSize: 13 },
  inputSuffix: { color: colors.textMuted, fontSize: 12 },
  input: {
    flex: 1,
    paddingVertical: 10,
    color: colors.textPrimary,
    fontSize: 14,
    fontWeight: '700',
  },

  summary: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    marginTop: 20,
    paddingHorizontal: spacing.base,
    paddingVertical: spacing.md,
    backgroundColor: alpha(colors.accent, 0.08),
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: alpha(colors.accent, 0.2),
  },
  summaryDivider: { width: 1, height: 32, backgroundColor: colors.border },
  statBox: { alignItems: 'center' },
  statLabel: { color: colors.textMuted, fontSize: 11, fontWeight: '500' },
  statValue: { marginTop: 4, fontSize: 14, fontWeight: '700' },

  sectionTitle: {
    marginTop: 20,
    marginBottom: 12,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '700',
  },

  bankRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
    padding: spacing.base,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  bankInfo: { flex: 2 },
  bankName: { color: colors.textPrimary, fontSize: 14, fontWeight: '700' },
  bankRate: { color: colors.textMuted, fontSize: 11 },
  bankValues: { flex: 3, alignItems: 'flex-end' },
  bankFinal: { color: colors.textPrimary, fontSize: 14, fontWeight: '700' },
  bankReturn: { color: colors.profit, fontSize: 12, fontWeight: '600' },

  disclaimer: {
    marginTop: 24,
    color: colors.textMuted,
    fontSize: 11,
    lineHeight: 11 * 1.5,
  },
});
