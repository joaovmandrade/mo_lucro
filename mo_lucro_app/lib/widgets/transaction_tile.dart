import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.profit : AppColors.loss;
    final icon = _categoryIcon(transaction.category);

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.loss.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.loss, size: 22),
      ),
      confirmDismiss: (_) async {
        if (onDelete == null) return false;
        onDelete!();
        return false; // Let the page handle UI update
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isEmpty
                        ? _categoryLabel(transaction.category)
                        : transaction.description,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_categoryLabel(transaction.category)} • ${AppFormatters.dateShort(transaction.date)}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isIncome ? '+' : '-'}${AppFormatters.currency(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'salary':
        return Icons.work_outline;
      case 'investment':
        return Icons.trending_up;
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'health':
        return Icons.favorite_outline;
      case 'education':
        return Icons.school_outlined;
      case 'entertainment':
        return Icons.theater_comedy_outlined;
      case 'housing':
        return Icons.home_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      default:
        return Icons.attach_money;
    }
  }

  String _categoryLabel(String category) {
    const map = {
      'salary': 'Salário',
      'investment': 'Investimento',
      'food': 'Alimentação',
      'transport': 'Transporte',
      'health': 'Saúde',
      'education': 'Educação',
      'entertainment': 'Lazer',
      'housing': 'Moradia',
      'utilities': 'Utilidades',
      'others': 'Outros',
    };
    return map[category] ?? category;
  }
}
