import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { DateField } from '@/components/DateField';
import { FieldLabel, Input, ScreenHeader } from '@/components/form';
import { Snackbar, useSnackbar } from '@/components/Snackbar';
import type { TransactionType } from '@/models';
import { transactionService } from '@/services';
import { alpha, colors, radius, spacing } from '@/theme';

/** Porte de lib/pages/add_transaction_page.dart. */

type CategoryDef = { key: string; label: string; icon: keyof typeof MaterialIcons.glyphMap };

const EXPENSE_CATEGORIES: CategoryDef[] = [
  { key: 'food', label: 'Alimentação', icon: 'restaurant' },
  { key: 'transport', label: 'Transporte', icon: 'directions-car' },
  { key: 'health', label: 'Saúde', icon: 'local-hospital' },
  { key: 'education', label: 'Educação', icon: 'school' },
  { key: 'entertainment', label: 'Lazer', icon: 'movie' },
  { key: 'housing', label: 'Moradia', icon: 'home' },
  { key: 'utilities', label: 'Utilidades', icon: 'bolt' },
  { key: 'shopping', label: 'Compras', icon: 'shopping-bag' },
  { key: 'others', label: 'Outros', icon: 'category' },
];

const INCOME_CATEGORIES: CategoryDef[] = [
  { key: 'salary', label: 'Salário', icon: 'work' },
  { key: 'investment', label: 'Investimento', icon: 'trending-up' },
  { key: 'bonus', label: 'Bônus', icon: 'stars' },
  { key: 'others', label: 'Outros', icon: 'category' },
];

export default function AddTransactionScreen() {
  const router = useRouter();
  const { message, show } = useSnackbar();
  const params = useLocalSearchParams<{ type?: string }>();

  const [type, setType] = useState<TransactionType>(
    params.type === 'income' ? 'income' : 'expense',
  );
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('others');
  const [date, setDate] = useState(new Date());
  const [amountError, setAmountError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const isIncome = type === 'income';
  const typeColor = isIncome ? colors.profit : colors.loss;
  const categories = isIncome ? INCOME_CATEGORIES : EXPENSE_CATEGORIES;

  function selectType(next: TransactionType) {
    setType(next);
    setCategory('others');
  }

  function validate(): boolean {
    if (amount.length === 0) {
      setAmountError('Informe o valor');
      return false;
    }
    if (!Number.isFinite(Number.parseFloat(amount.replace(',', '.')))) {
      setAmountError('Valor inválido');
      return false;
    }
    setAmountError(null);
    return true;
  }

  async function save() {
    if (!validate()) return;

    setLoading(true);
    try {
      await transactionService.addTransaction({
        type,
        amount: Number.parseFloat(amount.replace(',', '.')),
        category,
        description: description.trim(),
        date,
      });
      show(isIncome ? 'Receita registrada!' : 'Despesa registrada!');
      router.back();
    } catch (err) {
      show(`Erro: ${err instanceof Error ? err.message : String(err)}`, { isError: true });
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Nova Transação" />

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
          <View style={styles.typeRow}>
            <TypeButton
              label="Receita"
              icon="arrow-upward"
              color={colors.profit}
              selected={isIncome}
              onPress={() => selectType('income')}
            />
            <TypeButton
              label="Despesa"
              icon="arrow-downward"
              color={colors.loss}
              selected={!isIncome}
              onPress={() => selectType('expense')}
            />
          </View>

          <View
            style={[
              styles.amountCard,
              { backgroundColor: alpha(typeColor, 0.06), borderColor: alpha(typeColor, 0.2) },
            ]}
          >
            <Text style={[styles.amountLabel, { color: alpha(typeColor, 0.7) }]}>
              {isIncome ? 'Valor da Receita' : 'Valor da Despesa'}
            </Text>

            <View style={styles.amountInputRow}>
              <Text style={[styles.amountPrefix, { color: typeColor }]}>R$ </Text>
              <TextInput
                value={amount}
                onChangeText={setAmount}
                placeholder="0,00"
                placeholderTextColor={alpha(typeColor, 0.3)}
                keyboardType="decimal-pad"
                style={[styles.amountInput, { color: typeColor }]}
              />
            </View>
          </View>

          {amountError ? <Text style={styles.amountError}>{amountError}</Text> : null}

          <FieldLabel>Categoria</FieldLabel>
          <View style={styles.categories}>
            {categories.map((item) => {
              const selected = category === item.key;
              return (
                <Pressable
                  key={item.key}
                  onPress={() => setCategory(item.key)}
                  style={[
                    styles.categoryChip,
                    selected && {
                      backgroundColor: alpha(typeColor, 0.12),
                      borderColor: typeColor,
                      borderWidth: 1.5,
                    },
                  ]}
                >
                  <MaterialIcons
                    name={item.icon}
                    size={14}
                    color={selected ? typeColor : colors.textMuted}
                  />
                  <Text style={[styles.categoryText, selected && { color: typeColor }]}>
                    {item.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>

          <FieldLabel>Descrição (opcional)</FieldLabel>
          <View style={styles.field}>
            <Input
              value={description}
              onChangeText={setDescription}
              placeholder="Ex: Almoço, Uber, Netflix..."
              icon="edit"
              maxLength={80}
            />
          </View>

          <FieldLabel>Data</FieldLabel>
          <View style={styles.field}>
            <DateField value={date} onChange={setDate} />
          </View>

          <Pressable
            onPress={save}
            disabled={loading}
            style={({ pressed }) => [
              styles.submitButton,
              { backgroundColor: typeColor },
              (pressed || loading) && styles.submitButtonDimmed,
            ]}
          >
            {loading ? (
              <ActivityIndicator color="#FFFFFF" />
            ) : (
              <Text style={styles.submitLabel}>
                {isIncome ? 'Registrar Receita' : 'Registrar Despesa'}
              </Text>
            )}
          </Pressable>
        </ScrollView>
      </KeyboardAvoidingView>

      <Snackbar message={message} />
    </View>
  );
}

function TypeButton({
  label,
  icon,
  color,
  selected,
  onPress,
}: {
  label: string;
  icon: keyof typeof MaterialIcons.glyphMap;
  color: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.typeButton,
        selected && {
          backgroundColor: alpha(color, 0.12),
          borderColor: color,
          borderWidth: 1.5,
        },
      ]}
    >
      <MaterialIcons name={icon} size={16} color={selected ? color : colors.textMuted} />
      <Text style={[styles.typeLabel, selected && { color }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },
  content: { padding: spacing.lg, paddingBottom: 40 },

  typeRow: { flexDirection: 'row', gap: 10, marginBottom: 24 },
  typeButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
    paddingVertical: 14,
    backgroundColor: colors.bg2,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  typeLabel: { color: colors.textSecondary, fontSize: 13, fontWeight: '700' },

  amountCard: {
    alignItems: 'center',
    padding: spacing.xl,
    borderRadius: radius.xxl,
    borderWidth: 1,
  },
  amountLabel: { fontSize: 12, fontWeight: '600' },
  amountInputRow: { flexDirection: 'row', alignItems: 'center', marginTop: 10 },
  amountPrefix: { fontSize: 20, fontWeight: '700' },
  amountInput: {
    minWidth: 140,
    fontSize: 32,
    fontWeight: '800',
    letterSpacing: -1,
    textAlign: 'center',
  },
  amountError: { marginTop: 8, color: colors.loss, fontSize: 12 },

  categories: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 10, marginBottom: 16 },
  categoryChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 5,
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: colors.bg2,
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: colors.border,
  },
  categoryText: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },

  field: { marginTop: 8, marginBottom: 16 },

  submitButton: {
    height: 52,
    marginTop: 12,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.lg,
  },
  submitButtonDimmed: { opacity: 0.8 },
  submitLabel: { color: '#FFFFFF', fontSize: 15, fontWeight: '600' },
});
