import { operationFromRow, type AssetCategory, type Operation, type OperationType } from '@/models';
import { requireUserId, supabase } from '@/lib/supabase';

/** Porte de lib/services/operation_service.dart. */

export async function getOperations(): Promise<Operation[]> {
  const userId = await requireUserId();

  const { data, error } = await supabase
    .from('operations')
    .select()
    .eq('user_id', userId)
    .order('date', { ascending: false });

  if (error) throw error;

  return (data ?? []).map((row) =>
    // Linhas antigas podem não ter 'category'.
    operationFromRow({ category: 'stocks', ...row }),
  );
}

export async function addOperation(params: {
  type: OperationType;
  asset: string;
  category: AssetCategory;
  quantity: number;
  price: number;
  date: Date;
}): Promise<void> {
  const userId = await requireUserId();
  const total = params.quantity * params.price;

  const payload: Record<string, any> = {
    user_id: userId,
    type: params.type,
    asset: params.asset.toUpperCase().trim(),
    quantity: params.quantity,
    price: params.price,
    total,
    date: params.date.toISOString(),
    category: params.category,
  };

  const { error } = await supabase.from('operations').insert(payload);

  if (error) {
    // Bancos sem a coluna 'category' ainda aceitam o insert sem ela.
    delete payload.category;
    const retry = await supabase.from('operations').insert(payload);
    if (retry.error) throw retry.error;
  }
}

export async function deleteOperation(id: string): Promise<void> {
  const { error } = await supabase.from('operations').delete().eq('id', id);
  if (error) throw error;
}
