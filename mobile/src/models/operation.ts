/** Porte de lib/models/operation_model.dart. */

export type OperationType = 'buy' | 'sell' | 'dividend';

export type AssetCategory = 'stocks' | 'crypto' | 'fixed_income' | 'fiis' | 'others';

export type Operation = {
  id: string;
  userId: string;
  type: OperationType;
  asset: string;
  category: AssetCategory;
  quantity: number;
  price: number;
  total: number;
  date: Date;
};

export const isBuy = (op: Operation) => op.type === 'buy';
export const isSell = (op: Operation) => op.type === 'sell';
export const isDividend = (op: Operation) => op.type === 'dividend';

export function operationFromRow(row: Record<string, any>): Operation {
  return {
    id: row.id as string,
    userId: row.user_id as string,
    type: row.type as OperationType,
    asset: String(row.asset).toUpperCase(),
    category: (row.category ?? 'others') as AssetCategory,
    quantity: Number(row.quantity),
    price: Number(row.price),
    total: Number(row.total),
    date: new Date(row.date as string),
  };
}

export function operationToRow(op: Omit<Operation, 'id'>): Record<string, any> {
  return {
    user_id: op.userId,
    type: op.type,
    asset: op.asset.toUpperCase(),
    category: op.category,
    quantity: op.quantity,
    price: op.price,
    total: op.total,
    date: op.date.toISOString(),
  };
}
