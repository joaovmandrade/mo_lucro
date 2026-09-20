/** Porte de lib/models/goal_model.dart. */

export type Goal = {
  id: string;
  userId: string;
  title: string;
  targetValue: number;
  currentValue: number;
  deadline: Date | null;
  createdAt: Date;
};

/** Progresso entre 0 e 1. */
export function goalProgress(goal: Goal): number {
  if (goal.targetValue <= 0) return 0;
  return Math.min(Math.max(goal.currentValue / goal.targetValue, 0), 1);
}

export function goalProgressPercent(goal: Goal): number {
  return goalProgress(goal) * 100;
}

export function isGoalCompleted(goal: Goal): boolean {
  return goal.currentValue >= goal.targetValue;
}

export function goalRemaining(goal: Goal): number {
  return Math.max(goal.targetValue - goal.currentValue, 0);
}

/** As colunas reais no banco são name / target / current (veja supabase/schema.sql). */
export function goalFromRow(row: Record<string, any>): Goal {
  const rawDeadline = row.deadline as string | null | undefined;

  return {
    id: row.id as string,
    userId: row.user_id as string,
    title: (row.name ?? row.title ?? '') as string,
    targetValue: Number(row.target ?? row.target_value ?? 0),
    currentValue: Number(row.current ?? row.current_value ?? 0),
    deadline: rawDeadline ? new Date(rawDeadline) : null,
    createdAt: new Date(row.created_at as string),
  };
}

export function goalToRow(goal: Omit<Goal, 'id' | 'createdAt'>): Record<string, any> {
  return {
    user_id: goal.userId,
    name: goal.title,
    target: goal.targetValue,
    current: goal.currentValue,
    ...(goal.deadline ? { deadline: goal.deadline.toISOString() } : {}),
  };
}
