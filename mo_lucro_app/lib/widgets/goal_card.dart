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
    final color = goal.isCompleted ? AppColors.profit : AppColors.warning;
    final icon = _goalIcon(goal.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (goal.deadline != null)
                        Text(
                          'Prazo: ${AppFormatters.dateFull(goal.deadline!)}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.profit.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.profit.withOpacity(0.3),
                      ),
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
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  color: AppColors.bg3,
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Adicionar valor',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: AppColors.loss,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Excluir',
                            style: TextStyle(
                              color: AppColors.loss,
                              fontSize: 14,
                            ),
                          ),
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

            // Progress bar — gradient
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: goal.progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: goal.isCompleted
                            ? [AppColors.profit, const Color(0xFF00A882)]
                            : [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Values row
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
      ),
    );
  }

  IconData _goalIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('emergência') || t.contains('reserva'))
      return Icons.shield_outlined;
    if (t.contains('viagem') || t.contains('férias'))
      return Icons.flight_rounded;
    if (t.contains('casa') ||
        t.contains('imóvel') ||
        t.contains('apartamento')) {
      return Icons.home_outlined;
    }
    if (t.contains('carro') || t.contains('veículo'))
      return Icons.directions_car_outlined;
    if (t.contains('aposentadoria') || t.contains('poupança'))
      return Icons.savings_outlined;
    if (t.contains('educação') || t.contains('curso') || t.contains('estudo')) {
      return Icons.school_outlined;
    }
    return Icons.flag_outlined;
  }
}
