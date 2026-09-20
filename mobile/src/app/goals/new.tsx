import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { KeyboardAvoidingView, Platform, ScrollView, StyleSheet, View } from 'react-native';

import { FieldLabel, Input, PrimaryButton, ScreenHeader } from '@/components/form';
import { Snackbar, useSnackbar } from '@/components/Snackbar';
import { goalService } from '@/services';
import { alpha, colors, radius } from '@/theme';

/** Porte de lib/pages/add_goal_page.dart. */
export default function AddGoalScreen() {
  const router = useRouter();
  const { message, show } = useSnackbar();

  const [title, setTitle] = useState('');
  const [target, setTarget] = useState('');
  const [current, setCurrent] = useState('');
  const [errors, setErrors] = useState<Record<string, string | null>>({});
  const [loading, setLoading] = useState(false);

  function validate(): boolean {
    const next: Record<string, string | null> = {};

    if (title.trim().length === 0) next.title = 'Informe o nome da meta';

    if (target.trim().length === 0) {
      next.target = 'Informe o valor alvo';
    } else {
      const parsed = Number.parseFloat(target.replace(',', '.'));
      if (!Number.isFinite(parsed) || parsed <= 0) next.target = 'Valor inválido';
    }

    if (current.trim().length > 0) {
      const parsed = Number.parseFloat(current.replace(',', '.'));
      if (!Number.isFinite(parsed)) next.current = 'Valor inválido';
    }

    setErrors(next);
    return Object.values(next).every((value) => !value);
  }

  async function save() {
    if (!validate()) return;

    const targetValue = Number.parseFloat(target.trim().replace(',', '.'));
    const currentRaw = current.trim().replace(',', '.');
    const currentValue = currentRaw.length === 0 ? 0 : Number.parseFloat(currentRaw);

    if (!Number.isFinite(targetValue) || targetValue <= 0) {
      show('Valor alvo inválido', { isError: true });
      return;
    }

    setLoading(true);
    try {
      await goalService.addGoal({
        title: title.trim(),
        targetValue,
        currentValue: Number.isFinite(currentValue) ? currentValue : 0,
      });
      show('Meta criada!');
      router.back();
    } catch (err) {
      show(`Erro: ${err instanceof Error ? err.message : String(err)}`, { isError: true });
    } finally {
      setLoading(false);
    }
  }

  return (
    <View style={styles.screen}>
      <ScreenHeader title="Nova Meta" />

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.content} keyboardShouldPersistTaps="handled">
          <View style={styles.iconWrapper}>
            <View style={styles.icon}>
              <MaterialIcons name="flag" size={36} color={colors.warning} />
            </View>
          </View>

          <FieldLabel>Nome da meta</FieldLabel>
          <View style={styles.field}>
            <Input
              value={title}
              onChangeText={setTitle}
              placeholder="Ex: Reserva de emergência, Viagem..."
              icon="flag"
              error={errors.title}
            />
          </View>

          <FieldLabel>Valor alvo (R$)</FieldLabel>
          <View style={styles.field}>
            <Input
              value={target}
              onChangeText={setTarget}
              placeholder="10000"
              keyboardType="decimal-pad"
              prefix="R$ "
              prefixStyle={styles.targetPrefix}
              inputStyle={styles.targetInput}
              error={errors.target}
            />
          </View>

          <FieldLabel>Valor atual (R$) — opcional</FieldLabel>
          <View style={styles.field}>
            <Input
              value={current}
              onChangeText={setCurrent}
              placeholder="0"
              keyboardType="decimal-pad"
              prefix="R$ "
              error={errors.current}
            />
          </View>

          <View style={styles.submit}>
            <PrimaryButton label="Criar meta" onPress={save} loading={loading} />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>

      <Snackbar message={message} />
    </View>
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, backgroundColor: colors.bg0 },
  flex: { flex: 1 },
  content: { padding: 20, paddingBottom: 40 },
  iconWrapper: { alignItems: 'center', marginBottom: 24 },
  icon: {
    padding: 20,
    backgroundColor: alpha(colors.warning, 0.12),
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: alpha(colors.warning, 0.3),
  },
  field: { marginTop: 8, marginBottom: 16 },
  targetPrefix: { color: colors.warning, fontWeight: '700', fontSize: 18 },
  targetInput: { color: colors.warning, fontSize: 18, fontWeight: '700' },
  submit: { marginTop: 16 },
});
