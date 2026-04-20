import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/goal_model.dart';
import '../utils/formatters.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback? onAddProgress;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onAddProgress,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = goal.isCompleted ? AppColors.profit : AppColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.profit.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.profit.withOpacity(0.3)),
                  ),
                  child: const Text(
                    '✓ Concluída',
                    style: TextStyle(
                      color: AppColors.profit,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                color: AppColors.bg3,
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'add',
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Adicionar valor',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline,
                            size: 16, color: AppColors.loss),
                        const SizedBox(width: 8),
                        const Text('Excluir',
                            style: TextStyle(color: AppColors.loss, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onSelected: (val) {
                  if (val == 'add') onAddProgress?.call();
                  if (val == 'delete') onDelete?.call();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppFormatters.currency(goal.currentValue),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${goal.progressPercent.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppFormatters.currency(goal.targetValue),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
