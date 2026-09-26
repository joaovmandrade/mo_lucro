import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

import { DateField } from '@/components/DateField';
import { FieldLabel, PrimaryButton, ScreenHeader } from '@/components/form';
import { Snackbar, useSnackbar } from '@/components/Snackbar';
import type { AssetCategory, OperationType, PortfolioPosition } from '@/models';
import { marketDataService, operationService } from '@/services';
import { alpha, colors, radius, shadows } from '@/theme';
import { assetHintFor, suggestAssets, type AssetOption } from '@/utils/assetCatalog';
import { quantityLabel } from '@/utils/categories';
import { currency } from '@/utils/formatters';
import { calculatePortfolio } from '@/utils/portfolio';

/** Porte de lib/pages/add_operation_page.dart. */

const CATEGORIES: { key: AssetCategory; label: string }[] = [
  { key: 'stocks', label: 'Ações' },
  { key: 'crypto', label: 'Criptomoedas' },
  { key: 'fixed_income', label: 'Renda Fixa' },
  { key: 'others', label: 'Outros' },
];

export default function AddOperationScreen() {
  const router = useRouter();
  const { message, show } = useSnackbar();

  const [type, setType] = useState<OperationType>('buy');
  const [category, setCategory] = useState<AssetCategory>('stocks');
  const [asset, setAsset] = useState('');
  const [quantity, setQuantity] = useState('');
  const [price, setPrice] = useState('');
  const [date, setDate] = useState(new Date());

  const [suggestions, setSuggestions] = useState<AssetOption[]>([]);
  const [fetchingPrice, setFetchingPrice] = useState(false);
  const [priceIsAuto, setPriceIsAuto] = useState(false);
  const [categoryOpen, setCategoryOpen] = useState(false);
  const [errors, setErrors] = useState<Record<string, string | null>>({});
  const [loading, setLoading] = useState(false);

  // Posições atuais, para saber o que a pessoa tem quando ela for vender.
  const [holdings, setHoldings] = useState<Record<string, PortfolioPosition>>({});
  const [holdingsLoaded, setHoldingsLoaded] = useState(false);

  useEffect(() => {
    let active = true;
    operationService
      .getOperations()
      .then((operations) => {
        if (active) setHoldings(calculatePortfolio(operations));
      })
      .catch(() => {
        // Sem posições carregadas, a venda cai no fluxo antigo (digitação livre).
      })
      .finally(() => {
        if (active) setHoldingsLoaded(true);
      });
    return () => {
      active = false;
    };
  }, []);

  // O que a pessoa possui na categoria escolhida, para listar na hora da venda.
  const ownedInCategory = useMemo(
    () =>
      Object.values(holdings)
        .filter((position) => position.category === category)
        .sort((a, b) => a.asset.localeCompare(b.asset)),
    [holdings, category],
  );

  function ownedSuggestions(query: string): AssetOption[] {
    const trimmed = query.trim().toLowerCase();
    return ownedInCategory
      .filter((position) => trimmed.length === 0 || position.asset.toLowerCase().includes(trimmed))
      .slice(0, 8)
      .map((position) => ({
        ticker: position.asset,
        name: `Você tem ${quantityLabel(position.quantity)} disponível`,
      }));
  }

  const assetUpper = asset.trim().toUpperCase();
  const matchingHolding =
    type === 'sell' ? ownedInCategory.find((position) => position.asset === assetUpper) : undefined;

  const total =
    (Number.parseFloat(quantity.replace(',', '.')) || 0) *
    (Number.parseFloat(price.replace(',', '.')) || 0);

  function onAssetChanged(text: string) {
    setAsset(text);
    setSuggestions(type === 'sell' ? ownedSuggestions(text) : suggestAssets(category, text));
  }

  function onAssetFocused() {
    // Em venda, mostra de cara os ativos que a pessoa tem nessa categoria,
    // sem precisar digitar nada — é o que faltava para "achar" o ativo.
    if (type === 'sell' && asset.length === 0) setSuggestions(ownedSuggestions(''));
  }

  function clearAsset() {
    setAsset('');
    setPrice('');
    setPriceIsAuto(false);
    setSuggestions([]);
  }

  async function selectAsset(option: AssetOption) {
    setSuggestions([]);
    setAsset(option.ticker);
    setPrice('');
    setPriceIsAuto(false);
    await fetchPrice(option.ticker);
  }

  async function fetchPrice(ticker: string) {
    // Renda fixa não tem cotação: o preço é digitado.
    if (category === 'fixed_income') return;

    setFetchingPrice(true);
    try {
      const quote = await marketDataService.getQuote(ticker, category);
      if (quote.success && quote.price > 0) {
        setPrice(quote.price.toFixed(2));
        setPriceIsAuto(true);
      }
    } finally {
      setFetchingPrice(false);
    }
  }

  function onCategoryChanged(next: AssetCategory) {
    setCategory(next);
    setCategoryOpen(false);
    setAsset('');
    setPrice('');
    setPriceIsAuto(false);
    setFetchingPrice(false);
    setSuggestions([]);
  }

  function onTypeChanged(next: OperationType) {
    setType(next);
    // O catálogo de sugestões muda entre "o que existe" (compra) e
    // "o que você tem" (venda), então o que já estava digitado não vale mais.
    setAsset('');
    setPrice('');
    setPriceIsAuto(false);
    setSuggestions([]);
  }

  function validate(): boolean {
    const next: Record<string, string | null> = {};

    if (asset.trim().length === 0) next.asset = 'Informe o código';

    if (quantity.length === 0) next.quantity = 'Obrigatório';
    else if (!Number.isFinite(Number.parseFloat(quantity.replace(',', '.'))))
      next.quantity = 'Inválido';

    if (price.length === 0) next.price = 'Obrigatório';
    else if (!Number.isFinite(Number.parseFloat(price.replace(',', '.'))))
      next.price = 'Inválido';

    if (type === 'sell' && asset.trim().length > 0 && holdingsLoaded) {
      if (!matchingHolding) {
        next.asset = `Você não tem ${assetUpper} nesta categoria`;
      } else if (!next.quantity) {
        const qty = Number.parseFloat(quantity.replace(',', '.'));
        if (Number.isFinite(qty) && qty > matchingHolding.quantity + 0.0001) {
          next.quantity = `Você só tem ${quantityLabel(matchingHolding.quantity)} disponível`;
        }
      }
    }

    setErrors(next);
    return Object.values(next).every((value) => !value);
  }

  async function save() {
    if (!validate()) return;

    const qty = Number.parseFloat(quantity.replace(',', '.'));
    const unitPrice = Number.parseFloat(price.replace(',', '.'));

    if (!Number.isFinite(qty) || !Number.isFinite(unitPrice)) {
      show('Valores inválidos', { isError: true });
      return;
    }

    setLoading(true);
    try {
      await operationService.addOperation({
        type,
        asset: asset.trim().toUpperCase(),
        category,
        quantity: qty,
        price: unitPrice,
        date,
      });
      show('Operação registrada!');
      router.back();
    } catch (err) {
      show(`Erro: ${err instanceof Error ? err.message : String(err)}`, { isError: true });
    } finally {
      setLoading(false);
    }
  }

  const categoryLabel = CATEGORIES.find((item) => item.key === category)?.label ?? '';

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Nova Operação" />

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
          <FieldLabel>Tipo de operação</FieldLabel>
          <View style={styles.typeRow}>
            <TypeButton
              label="Compra"
              color={colors.profit}
              selected={type === 'buy'}
              onPress={() => onTypeChanged('buy')}
            />
            <TypeButton
              label="Venda"
              color={colors.loss}
              selected={type === 'sell'}
              onPress={() => onTypeChanged('sell')}
            />
          </View>

          <FieldLabel>Categoria</FieldLabel>
          <Pressable style={styles.select} onPress={() => setCategoryOpen(true)}>
            <Text style={styles.selectText}>{categoryLabel}</Text>
            <MaterialIcons name="arrow-drop-down" size={24} color={colors.textMuted} />
          </Pressable>

          <FieldLabel>Código do ativo</FieldLabel>
          <View style={styles.assetWrapper}>
            <View style={[styles.inputBox, errors.asset ? styles.inputBoxError : null]}>
              <MaterialIcons name="bar-chart" size={20} color={colors.textMuted} />
              <TextInput
                value={asset}
                onChangeText={onAssetChanged}
                onFocus={onAssetFocused}
                placeholder={type === 'sell' ? 'Toque para ver seus ativos' : assetHintFor(category)}
                placeholderTextColor={colors.textMuted}
                autoCapitalize="characters"
                style={styles.assetInput}
              />
              {asset.length > 0 ? (
                <Pressable onPress={clearAsset} accessibilityLabel="Limpar">
                  <MaterialIcons name="close" size={18} color={colors.textMuted} />
                </Pressable>
              ) : null}
            </View>

            {errors.asset ? (
              <Text style={styles.errorText}>{errors.asset}</Text>
            ) : type === 'sell' && asset.trim().length > 0 ? (
              matchingHolding ? (
                <Text style={styles.helperText}>
                  Você tem {quantityLabel(matchingHolding.quantity)} {assetUpper} disponível
                </Text>
              ) : holdingsLoaded ? (
                <Text style={styles.errorText}>Você não tem {assetUpper} nesta categoria</Text>
              ) : null
            ) : null}

            {suggestions.length > 0 ? (
              <View style={styles.suggestions}>
                {suggestions.map((option, index) => (
                  <Pressable
                    key={option.ticker}
                    onPress={() => selectAsset(option)}
                    style={[
                      styles.suggestionItem,
                      index < suggestions.length - 1 && styles.suggestionDivider,
                    ]}
                  >
                    <View style={styles.suggestionBadge}>
                      <Text style={styles.suggestionBadgeText}>
                        {option.ticker.length > 3 ? option.ticker.slice(0, 3) : option.ticker}
                      </Text>
                    </View>
                    <View style={styles.flex}>
                      <Text style={styles.suggestionTicker}>{option.ticker}</Text>
                      <Text style={styles.suggestionName}>{option.name}</Text>
                    </View>
                    <MaterialIcons name="north-west" size={14} color={colors.textMuted} />
                  </Pressable>
                ))}
              </View>
            ) : null}
          </View>

          <View style={styles.row}>
            <View style={styles.flex}>
              <FieldLabel>Quantidade</FieldLabel>
              <View style={[styles.inputBox, styles.spaced, errors.quantity ? styles.inputBoxError : null]}>
                <TextInput
                  value={quantity}
                  onChangeText={setQuantity}
                  placeholder="100"
                  placeholderTextColor={colors.textMuted}
                  keyboardType="decimal-pad"
                  style={styles.plainInput}
                />
              </View>
              {errors.quantity ? <Text style={styles.errorText}>{errors.quantity}</Text> : null}
            </View>

            <View style={styles.flex}>
              <View style={styles.priceLabelRow}>
                <FieldLabel>Preço (R$)</FieldLabel>
                {priceIsAuto ? (
                  <View style={styles.autoBadge}>
                    <Text style={styles.autoBadgeText}>Auto</Text>
                  </View>
                ) : null}
              </View>

              <View
                style={[
                  styles.inputBox,
                  styles.spaced,
                  priceIsAuto && styles.inputBoxAuto,
                  errors.price ? styles.inputBoxError : null,
                ]}
              >
                <TextInput
                  value={price}
                  onChangeText={setPrice}
                  placeholder="0,00"
                  placeholderTextColor={colors.textMuted}
                  keyboardType="decimal-pad"
                  readOnly={priceIsAuto}
                  style={[styles.plainInput, priceIsAuto && styles.priceInputAuto]}
                />
                {fetchingPrice ? <ActivityIndicator size="small" color={colors.primary} /> : null}
              </View>
              {errors.price ? <Text style={styles.errorText}>{errors.price}</Text> : null}
            </View>
          </View>

          <FieldLabel>Data</FieldLabel>
          <View style={styles.spaced}>
            <DateField value={date} onChange={setDate} />
          </View>

          {total > 0 ? (
            <View style={styles.totalCard}>
              <Text style={styles.totalLabel}>Total da operação</Text>
              <Text style={styles.totalValue}>{currency(total)}</Text>
            </View>
          ) : null}

          <PrimaryButton label="Salvar operação" onPress={save} loading={loading} />
        </ScrollView>
      </KeyboardAvoidingView>

      <Modal transparent visible={categoryOpen} animationType="fade" onRequestClose={() => setCategoryOpen(false)}>
        <Pressable style={styles.modalBackdrop} onPress={() => setCategoryOpen(false)}>
          <View style={styles.modalCard}>
            {CATEGORIES.map((item) => (
              <Pressable
                key={item.key}
                style={styles.modalItem}
                onPress={() => onCategoryChanged(item.key)}
              >
                <Text style={[styles.modalItemText, item.key === category && styles.modalItemActive]}>
                  {item.label}
                </Text>
                {item.key === category ? (
                  <MaterialIcons name="check" size={18} color={colors.primary} />
                ) : null}
              </Pressable>
            ))}
          </View>
        </Pressable>
      </Modal>

      <Snackbar message={message} />
    </View>
  );
}

function TypeButton({
  label,
  color,
  selected,
  onPress,
}: {
  label: string;
  color: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.typeButton,
        selected && { backgroundColor: alpha(color, 0.12), borderColor: color, borderWidth: 1.5 },
      ]}
    >
      <Text style={[styles.typeLabel, selected && { color }]}>{label}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },
  content: { padding: 20, paddingBottom: 40 },

  typeRow: { flexDirection: 'row', gap: 10, marginTop: 8, marginBottom: 20 },
  typeButton: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 13,
    backgroundColor: colors.bg1,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.border,
  },
  typeLabel: { color: colors.textSecondary, fontSize: 13, fontWeight: '700' },

  select: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 8,
    marginBottom: 16,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: colors.bg1,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.border,
  },
  selectText: { color: colors.textPrimary, fontSize: 14 },

  assetWrapper: { marginTop: 8, marginBottom: 16, zIndex: 10 },
  inputBox: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 16,
    backgroundColor: colors.bg3,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
  },
  inputBoxError: { borderColor: colors.loss },
  inputBoxAuto: { backgroundColor: alpha(colors.profit, 0.06) },
  spaced: { marginTop: 8 },
  assetInput: {
    flex: 1,
    paddingVertical: 16,
    color: colors.textPrimary,
    fontSize: 15,
    fontWeight: '700',
  },
  plainInput: { flex: 1, paddingVertical: 16, color: colors.textPrimary, fontSize: 14 },
  priceInputAuto: { color: colors.profitDark, fontWeight: '700' },
  errorText: { marginTop: 6, color: colors.loss, fontSize: 12 },
  helperText: { marginTop: 6, color: colors.textSecondary, fontSize: 12 },

  suggestions: {
    position: 'absolute',
    top: 60,
    left: 0,
    right: 0,
    backgroundColor: colors.bg1,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  suggestionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  suggestionDivider: { borderBottomWidth: 1, borderBottomColor: colors.border },
  suggestionBadge: {
    width: 36,
    height: 36,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: alpha(colors.primary, 0.08),
    borderRadius: 8,
  },
  suggestionBadgeText: { color: colors.primary, fontSize: 10, fontWeight: '800' },
  suggestionTicker: { color: colors.textPrimary, fontSize: 14, fontWeight: '700' },
  suggestionName: { color: colors.textSecondary, fontSize: 12 },

  row: { flexDirection: 'row', gap: 12, marginBottom: 16 },
  priceLabelRow: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  autoBadge: {
    paddingHorizontal: 6,
    paddingVertical: 2,
    backgroundColor: alpha(colors.profit, 0.12),
    borderRadius: 4,
  },
  autoBadgeText: { color: colors.profitDark, fontSize: 9, fontWeight: '700' },

  totalCard: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 24,
    marginBottom: 24,
    padding: 16,
    backgroundColor: alpha(colors.primary, 0.06),
    borderRadius: 14,
    borderWidth: 1,
    borderColor: alpha(colors.primary, 0.2),
  },
  totalLabel: { color: colors.textSecondary, fontSize: 13 },
  totalValue: { color: colors.primary, fontSize: 16, fontWeight: '700' },

  modalBackdrop: {
    flex: 1,
    justifyContent: 'center',
    padding: 40,
    backgroundColor: 'rgba(0, 0, 0, 0.35)',
  },
  modalCard: {
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    overflow: 'hidden',
  },
  modalItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  modalItemText: { color: colors.textPrimary, fontSize: 14 },
  modalItemActive: { color: colors.primary, fontWeight: '700' },
});