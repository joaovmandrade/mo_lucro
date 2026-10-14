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
 * Totais de entrada e saída do mês, usando a mesma data exibida na lista.
 * Linhas antigas sem 'date' usam created_at por meio de transactionFromRow.
 *
 * Nunca propaga erro: uma falha aqui não pode travar o carregamento das operações.
 */
export async function getMonthSummary(year: number, month: number): Promise<MonthSummary> {
  try {
    const userId = await requireUserId();

    const { data, error } = await supabase
      .from('transactions')
      .select()
      .eq('user_id', userId);

    if (error) throw error;

    let income = 0;
    let expense = 0;

    for (const row of data ?? []) {
      const transaction = transactionFromRow(row);
      if (transaction.date.getFullYear() !== year || transaction.date.getMonth() !== month - 1) {
        continue;
      }

      if (transaction.type === 'income') income += transaction.amount;
      else expense += transaction.amount;
    }

    return { income, expense };
  } catch (error) {
    console.warn('[transactionService.getMonthSummary]', error);
    return { income: 0, expense: 0 };
  }
}
