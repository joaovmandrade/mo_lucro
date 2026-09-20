import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { Alert, Pressable, StyleSheet, Text, View } from 'react-native';

import { goalProgress, goalProgressPercent, isGoalCompleted, type Goal } from '@/models';
import { alpha, colors, radius, shadows, spacing } from '@/theme';
import { currency, dateFull } from '@/utils/formatters';

/** Porte de lib/widgets/goal_card.dart. */
export function GoalCard({
  goal,
  onAddProgress,
  onDelete,
}: {
  goal: Goal;
  onAddProgress?: () => void;
  onDelete?: () => void;
}) {
  const completed = isGoalCompleted(goal);
  const color = completed ? colors.profit : colors.warning;
  const progress = goalProgress(goal);

  // O PopupMenuButton do Flutter vira um action sheet nativo.
  function openMenu() {
    Alert.alert(goal.title, undefined, [
      { text: 'Adicionar valor', onPress: onAddProgress },
      { text: 'Excluir', style: 'destructive', onPress: onDelete },
      { text: 'Cancelar', style: 'cancel' },
    ]);
  }

  return (
    <View style={styles.card}>
      <View style={styles.header}>
        <View
          style={[
            styles.icon,
            { backgroundColor: alpha(color, 0.1), borderColor: alpha(color, 0.25) },
          ]}
        >
          <MaterialIcons name={goalIcon(goal.title)} size={20} color={color} />
        </View>

        <View style={styles.titleBlock}>
          <Text style={styles.title}>{goal.title}</Text>
          {goal.deadline ? (
            <Text style={styles.deadline}>Prazo: {dateFull(goal.deadline)}</Text>
          ) : null}
        </View>

        {completed ? (
          <View style={styles.completedBadge}>
            <Text style={styles.completedText}>✓ Concluída</Text>
          </View>
        ) : null}

        <Pressable onPress={openMenu} style={styles.menuButton} accessibilityLabel="Opções da meta">
          <MaterialIcons name="more-vert" size={18} color={colors.textMuted} />
        </Pressable>
      </View>

      <View style={styles.progressTrack}>
        <LinearGradient
          colors={completed ? [colors.profit, '#00A882'] : [color, alpha(color, 0.7)]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={[styles.progressFill, { width: `${progress * 100}%` }]}
        />
      </View>

      <View style={styles.values}>
        <Text style={[styles.currentValue, { color }]}>{currency(goal.currentValue)}</Text>
        <Text style={styles.percent}>{goalProgressPercent(goal).toFixed(1)}%</Text>
        <Text style={styles.targetValue}>{currency(goal.targetValue)}</Text>
      </View>
    </View>
  );
}

/** Porte de GoalCard._goalIcon — escolhe o ícone pelo texto do título. */
function goalIcon(title: string): keyof typeof MaterialIcons.glyphMap {
  const t = title.toLowerCase();
  if (t.includes('emergência') || t.includes('reserva')) return 'shield';
  if (t.includes('viagem') || t.includes('férias')) return 'flight';
  if (t.includes('casa') || t.includes('imóvel') || t.includes('apartamento')) return 'home';
  if (t.includes('carro') || t.includes('veículo')) return 'directions-car';
  if (t.includes('aposentadoria') || t.includes('poupança')) return 'savings';
  if (t.includes('educação') || t.includes('curso') || t.includes('estudo')) return 'school';
  return 'flag';
}

const styles = StyleSheet.create({
  card: {
    marginBottom: 12,
    padding: spacing.lg,
    backgroundColor: colors.bg1,
    borderRadius: radius.lg,
    borderWidth: 1,
    borderColor: colors.border,
    boxShadow: shadows.card,
  },
  header: { flexDirection: 'row', alignItems: 'center' },
  icon: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.md,
    borderWidth: 1,
  },
  titleBlock: { flex: 1, marginLeft: 12 },
  title: { color: colors.textPrimary, fontSize: 15, fontWeight: '700' },
  deadline: { color: colors.textMuted, fontSize: 11 },
  completedBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    backgroundColor: alpha(colors.profit, 0.12),
    borderRadius: radius.pill,
    borderWidth: 1,
    borderColor: alpha(colors.profit, 0.3),
  },
  completedText: { color: colors.profit, fontSize: 11, fontWeight: '700' },
  menuButton: { marginLeft: 4, padding: 4 },

  progressTrack: {
    height: 8,
    marginTop: 16,
    backgroundColor: colors.bg3,
    borderRadius: radius.pill,
    overflow: 'hidden',
  },
  progressFill: { height: 8, borderRadius: radius.pill },

  values: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 10,
  },
  currentValue: { fontSize: 13, fontWeight: '700' },
  percent: { color: colors.textSecondary, fontSize: 12, fontWeight: '600' },
  targetValue: { color: colors.textMuted, fontSize: 13, fontWeight: '600' },
});
