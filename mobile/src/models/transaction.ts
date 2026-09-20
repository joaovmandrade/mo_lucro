/** Porte de lib/models/transaction_model.dart. */

export type TransactionType = 'income' | 'expense';

export type Transaction = {
  id: string;
  userId: string;
  type: TransactionType;
  amount: number;
  category: string;
  description: string;
  date: Date;
};

export const isIncome = (tx: Transaction) => tx.type === 'income';

export function transactionFromRow(row: Record<string, any>): Transaction {
  // A tabela em produção usa created_at — cai nele quando 'date' não existe.
  const rawDate = (row.date ?? row.created_at) as string | undefined;

  return {
    id: row.id as string,
    userId: row.user_id as string,
    type: row.type as TransactionType,
    amount: Number(row.amount),
    category: (row.category ?? 'others') as string,
    // A coluna 'description' pode não existir em tabelas antigas.
    description: (row.description ?? '') as string,
    date: rawDate ? new Date(rawDate) : new Date(),
  };
}

export function transactionToRow(tx: Omit<Transaction, 'id'>): Record<string, any> {
  return {
    user_id: tx.userId,
    type: tx.type,
    amount: tx.amount,
    category: tx.category,
    description: tx.description,
  };
}
