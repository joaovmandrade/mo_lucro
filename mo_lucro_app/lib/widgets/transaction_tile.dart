import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;

  const TransactionTile({super.key, required this.transaction, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? AppColors.profit : AppColors.loss;
    final icon = _categoryIcon(transaction.category, isIncome);
    final categoryLabel = _categoryLabel(transaction.category);

    Widget tile = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.isNotEmpty
                      ? transaction.description
                      : categoryLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _CategoryChip(label: categoryLabel, color: color),
                    const SizedBox(width: 6),
                    Text(
                      AppFormatters.dateShort(transaction.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${AppFormatters.currency(transaction.amount)}',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.loss.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.loss.withOpacity(0.25)),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.loss,
            size: 20,
          ),
        ),
        child: tile,
      );
    }

    return tile;
  }

  IconData _categoryIcon(String category, bool isIncome) {
    if (isIncome) {
      switch (category) {
        case 'salary':
          return Icons.work_outline_rounded;
        case 'investment':
          return Icons.trending_up_rounded;
        case 'bonus':
          return Icons.stars_rounded;
        default:
          return Icons.arrow_upward_rounded;
      }
    }
    switch (category) {
      case 'food':
        return Icons.restaurant_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'entertainment':
        return Icons.movie_outlined;
      case 'housing':
        return Icons.home_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
      case 'salary':
        return 'Salário';
      case 'investment':
        return 'Investimento';
      case 'bonus':
        return 'Bônus';
      case 'food':
        return 'Alimentação';
      case 'transport':
        return 'Transporte';
      case 'health':
        return 'Saúde';
      case 'education':
        return 'Educação';
      case 'entertainment':
        return 'Lazer';
      case 'housing':
        return 'Moradia';
      case 'utilities':
        return 'Utilidades';
      case 'shopping':
        return 'Compras';
      default:
        return 'Outros';
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
