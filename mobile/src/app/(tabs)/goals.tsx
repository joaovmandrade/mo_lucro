import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useFocusEffect, useRouter } from 'expo-router';
import { useCallback, useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Modal,
  Pressable,
  RefreshControl,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { GoalCard } from '@/components/GoalCard';
import { goalProgressPercent, goalRemaining, isGoalCompleted, type Goal } from '@/models';
import { goalService } from '@/services';
import { alpha, colors, gradients, radius } from '@/theme';
import { currency } from '@/utils/formatters';

/** Porte de lib/pages/goals_page.dart. */
export default function GoalsScreen() {
  const router = useRouter();

  const [goals, setGoals] = useState<Goal[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [progressTarget, setProgressTarget] = useState<Goal | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      setGoals(await goalService.getGoals());
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

  function confirmDelete(id: string) {
    Alert.alert('Excluir meta', 'Tem certeza que deseja excluir esta meta?', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Excluir',
        style: 'destructive',
        onPress: async () => {
          await goalService.deleteGoal(id);
          load();
        },
      },
    ]);
  }

  async function addProgress(goal: Goal, amount: number) {
    const newValue = Math.min(Math.max(goal.currentValue + amount, 0), goal.targetValue);
    await goalService.updateGoalProgress(goal.id, newValue);
    setProgressTarget(null);
    load();
  }

  const completed = goals.filter(isGoalCompleted).length;
  const totalTarget = goals.reduce((sum, goal) => sum + goal.targetValue, 0);
  const totalCurrent = goals.reduce((sum, goal) => sum + goal.currentValue, 0);
  const overallProgress = totalTarget > 0 ? totalCurrent / totalTarget : 0;

  return (
    <View style={styles.screen}>
      <ScrollView
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
        <GoalsHeader
          totalGoals={goals.length}
          completed={completed}
          totalCurrent={totalCurrent}
          totalTarget={totalTarget}
          overallProgress={overallProgress}
          isLoading={loading}
        />

        <View style={styles.body}>
          {loading ? (
            <View style={styles.centerBlock}>
              <ActivityIndicator color={colors.primary} />
            </View>
          ) : goals.length === 0 ? (
            <EmptyState />
          ) : (
            goals.map((goal) => (
              <GoalCard
                key={goal.id}
                goal={goal}
                onAddProgress={() => setProgressTarget(goal)}
                onDelete={() => confirmDelete(goal.id)}
              />
            ))
          )}
        </View>
      </ScrollView>

      <Pressable
        style={({ pressed }) => [styles.fab, pressed && styles.fabPressed]}
        onPress={() => router.push('/goals/new')}
        accessibilityLabel="Nova meta"
      >
        <MaterialIcons name="add" size={26} color="#FFFFFF" />
      </Pressable>

      <AddProgressModal
        goal={progressTarget}
        onCancel={() => setProgressTarget(null)}
        onConfirm={addProgress}
      />
    </View>
  );
}

// ─────────────────────────────────────────────────────────────
// Diálogo de adicionar valor
// ─────────────────────────────────────────────────────────────
function AddProgressModal({
  goal,
  onCancel,
  onConfirm,
}: {
  goal: Goal | null;
  onCancel: () => void;
  onConfirm: (goal: Goal, amount: number) => void;
}) {
  const [text, setText] = useState('');

  if (!goal) return null;

  function submit() {
    if (!goal) return;
    const amount = Number.parseFloat(text.replace(',', '.'));
    if (Number.isFinite(amount) && amount > 0) onConfirm(goal, amount);
    setText('');
  }

  function cancel() {
    setText('');
    onCancel();
  }

  return (
    <Modal transparent animationType="fade" visible onRequestClose={cancel}>
      <Pressable style={styles.modalBackdrop} onPress={cancel}>
        <Pressable style={styles.modalCard} onPress={(event) => event.stopPropagation()}>
          <Text style={styles.modalTitle}>Adicionar valor à &quot;{goal.title}&quot;</Text>
          <Text style={styles.modalHint}>
            Progresso atual: {goalProgressPercent(goal).toFixed(1)}%
          </Text>

          <View style={styles.modalInputRow}>
            <Text style={styles.modalPrefix}>R$ </Text>
            <TextInput
              style={styles.modalInput}
              value={text}
              onChangeText={setText}
              placeholder="0,00"
              placeholderTextColor={colors.textMuted}
              keyboardType="decimal-pad"
              autoFocus
            />
          </View>

          <Text style={styles.modalRemaining}>
            Faltam {currency(goalRemaining(goal))} para a meta
          </Text>

          <View style={styles.modalActions}>
            <Pressable onPress={cancel} style={styles.modalCancel}>
              <Text style={styles.modalCancelText}>Cancelar</Text>
            </Pressable>
            <Pressable onPress={submit} style={styles.modalConfirm}>
              <Text style={styles.modalConfirmText}>Adicionar</Text>
            </Pressable>
          </View>
        </Pressable>
      </Pressable>
    </Modal>
  );
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
function GoalsHeader({
  totalGoals,
  completed,
  totalCurrent,
  totalTarget,
  overallProgress,
  isLoading,
}: {
  totalGoals: number;
  completed: number;
  totalCurrent: number;
  totalTarget: number;
  overallProgress: number;
  isLoading: boolean;
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
        <Text style={styles.headerTitle}>Minhas Metas</Text>
        {totalGoals > 0 ? (
          <View style={styles.headerBadge}>
            <Text style={styles.headerBadgeText}>
              {completed} de {totalGoals} concluídas
            </Text>
          </View>
        ) : null}
      </View>

      {isLoading ? (
        <View style={styles.headerSkeleton} />
      ) : totalGoals > 0 ? (
        <View style={styles.progressCard}>
          <View style={styles.progressTopRow}>
            <Text style={styles.progressLabel}>Progresso Geral</Text>
            <Text style={styles.progressPercent}>{(overallProgress * 100).toFixed(1)}%</Text>
          </View>

          <View style={styles.progressTrack}>
            <LinearGradient
              colors={[colors.warning, '#FBBF24']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={[
                styles.progressFill,
                { width: `${Math.min(Math.max(overallProgress, 0), 1) * 100}%` },
              ]}
            />
          </View>

          <View style={styles.progressBottomRow}>
            <View>
              <Text style={styles.progressSmallLabel}>Acumulado</Text>
              <Text style={styles.progressAccumulated}>{currency(totalCurrent)}</Text>
            </View>
            <View style={styles.alignEnd}>
              <Text style={styles.progressSmallLabel}>Objetivo total</Text>
              <Text style={styles.progressTarget}>{currency(totalTarget)}</Text>
            </View>
          </View>
        </View>
      ) : (
        <View style={styles.hintCard}>
          <MaterialIcons name="lightbulb-outline" size={18} color={colors.textOnBlueDim} />
          <Text style={styles.hintText}>
            Defina metas financeiras e acompanhe seu progresso.
          </Text>
        </View>
      )}
    </LinearGradient>
  );
}

function EmptyState() {
  return (
    <View style={styles.emptyState}>
      <View style={styles.emptyIcon}>
        <MaterialIcons name="flag" size={36} color={colors.warning} />
      </View>
      <Text style={styles.emptyTitle}>Nenhuma meta ainda</Text>
      <Text style={styles.emptyBody}>
        Crie sua primeira meta financeira{'\n'}e acompanhe seu progresso!
      </Text>
    </View>
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
  headerTop: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  headerTitle: { color: colors.textOnBlue, fontSize: 22, fontWeight: '800' },
  headerBadge: {
    paddingHorizontal: 12,
    paddingVertical: 5,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.20)',
  },
  headerBadgeText: { color: colors.textOnBlue, fontSize: 12, fontWeight: '600' },
  headerSkeleton: {
    height: 110,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderRadius: 20,
  },

  progressCard: {
    padding: 20,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  progressTopRow: { flexDirection: 'row', justifyContent: 'space-between' },
  progressLabel: { color: colors.textOnBlueDim, fontSize: 13 },
  progressPercent: { color: colors.textOnBlue, fontSize: 15, fontWeight: '700' },
  progressTrack: {
    height: 8,
    marginTop: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  progressFill: { height: 8, borderRadius: radius.pill },
  progressBottomRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 12,
  },
  progressSmallLabel: { color: colors.textOnBlueDim, fontSize: 11 },
  progressAccumulated: {
    marginTop: 2,
    color: colors.textOnBlue,
    fontSize: 15,
    fontWeight: '700',
  },
  progressTarget: {
    marginTop: 2,
    color: colors.textOnBlueDim,
    fontSize: 15,
    fontWeight: '600',
  },
  alignEnd: { alignItems: 'flex-end' },

  hintCard: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: 'rgba(255, 255, 255, 0.13)',
    borderRadius: 16,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.18)',
  },
  hintText: {
    flex: 1,
    color: colors.textOnBlueDim,
    fontSize: 13,
    lineHeight: 13 * 1.4,
  },

  body: { paddingHorizontal: 20, paddingTop: 24, paddingBottom: 100 },
  centerBlock: { paddingVertical: 40, alignItems: 'center' },

  emptyState: { paddingVertical: 40, alignItems: 'center' },
  emptyIcon: {
    padding: 22,
    backgroundColor: alpha(colors.warning, 0.08),
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: alpha(colors.warning, 0.18),
  },
  emptyTitle: {
    marginTop: 18,
    color: colors.textPrimary,
    fontSize: 16,
    fontWeight: '700',
  },
  emptyBody: {
    marginTop: 6,
    color: colors.textSecondary,
    fontSize: 13,
    lineHeight: 13 * 1.5,
    textAlign: 'center',
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

  modalBackdrop: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: 'rgba(0, 0, 0, 0.35)',
  },
  modalCard: {
    width: '100%',
    padding: 20,
    backgroundColor: colors.bg2,
    borderRadius: radius.xl,
  },
  modalTitle: { color: colors.textPrimary, fontSize: 15, fontWeight: '700' },
  modalHint: { marginTop: 8, color: colors.textMuted, fontSize: 12 },
  modalInputRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 14,
    paddingHorizontal: 14,
    backgroundColor: colors.bg3,
    borderRadius: radius.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  modalPrefix: { color: colors.warning, fontWeight: '700', fontSize: 18 },
  modalInput: {
    flex: 1,
    paddingVertical: 12,
    color: colors.textPrimary,
    fontSize: 18,
    fontWeight: '700',
  },
  modalRemaining: { marginTop: 8, color: colors.textSecondary, fontSize: 12 },
  modalActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
    gap: 8,
    marginTop: 16,
  },
  modalCancel: { paddingHorizontal: 12, paddingVertical: 10 },
  modalCancelText: { color: colors.primary, fontSize: 14, fontWeight: '600' },
  modalConfirm: {
    height: 40,
    justifyContent: 'center',
    paddingHorizontal: 16,
    backgroundColor: colors.primary,
    borderRadius: radius.md,
  },
  modalConfirmText: { color: '#FFFFFF', fontSize: 14, fontWeight: '600' },
});
