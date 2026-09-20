import { goalFromRow, type Goal } from '@/models';
import { requireUserId, supabase } from '@/lib/supabase';

/** Porte de lib/services/goal_service.dart. */

export async function getGoals(): Promise<Goal[]> {
  const userId = await requireUserId();

  const { data, error } = await supabase
    .from('goals')
    .select()
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return (data ?? []).map(goalFromRow);
}

export async function addGoal(params: {
  title: string;
  targetValue: number;
  currentValue?: number;
  deadline?: Date | null;
}): Promise<void> {
  const userId = await requireUserId();

  const payload: Record<string, any> = {
    user_id: userId,
    name: params.title,
    target: params.targetValue,
    current: params.currentValue ?? 0,
  };
  if (params.deadline) {
    payload.deadline = params.deadline.toISOString();
  }

  const { error } = await supabase.from('goals').insert(payload);
  if (error) throw error;
}

export async function updateGoalProgress(id: string, currentValue: number): Promise<void> {
  const { error } = await supabase.from('goals').update({ current: currentValue }).eq('id', id);
  if (error) throw error;
}

export async function deleteGoal(id: string): Promise<void> {
  const { error } = await supabase.from('goals').delete().eq('id', id);
  if (error) throw error;
}
