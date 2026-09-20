import { transactionFromRow, type Transaction, type TransactionType } from '@/models';
import { requireUserId, supabase } from '@/lib/supabase';

/** Porte de lib/services/transaction_service.dart. */

export async function getTransactions(): Promise<Transaction[]> {
  const userId = await requireUserId();

  // Ordena por created_at — a tabela em produção não tem coluna 'date'.
  const { data, error } = await supabase
    .from('transactions')
    .select()
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return (data ?? []).map(transactionFromRow);
}

export async function addTransaction(params: {
  type: TransactionType;
  amount: number;
  category: string;
  description: string;
  date: Date;
}): Promise<void> {
  const userId = await requireUserId();

  const payload: Record<string, any> = {
    user_id: userId,
    type: params.type,
    amount: params.amount,
    category: params.category,
    date: params.date.toISOString(),
  };

  if (params.description.length > 0) {
    payload.description = params.description;
  }

  const { error } = await supabase.from('transactions').insert(payload);
  if (error) throw error;
}

export async function deleteTransaction(id: string): Promise<void> {
  const { error } = await supabase.from('transactions').delete().eq('id', id);
  if (error) throw error;
}

export type MonthSummary = { income: number; expense: number };

/**
 * Totais de entrada e saída do mês. Filtra por created_at porque a tabela em
 * produção pode não ter uma coluna 'date' separada.
 *
 * Nunca propaga erro: uma falha aqui não pode travar o carregamento das operações.
 */
export async function getMonthSummary(year: number, month: number): Promise<MonthSummary> {
  try {
    const userId = await requireUserId();

    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 1);

    const { data, error } = await supabase
      .from('transactions')
      .select()
      .eq('user_id', userId)
      .gte('created_at', start.toISOString())
      .lt('created_at', end.toISOString());

    if (error) throw error;

    let income = 0;
    let expense = 0;

    for (const row of data ?? []) {
      const amount = Number(row.amount);
      if (row.type === 'income') income += amount;
      else expense += amount;
    }

    return { income, expense };
  } catch (error) {
    console.warn('[transactionService.getMonthSummary]', error);
    return { income: 0, expense: 0 };
  }
}
