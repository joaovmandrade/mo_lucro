import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Quick-action icon buttons — Figma spec:
/// • 48×48dp rounded square, border radius 12dp, bg #1C2333
/// • 6 actions with exact icon colors per spec
/// • Label: 11sp, secondary text, centered below icon
class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddInvestment;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onCreateGoal;
  final VoidCallback? onViewNews;
  final VoidCallback? onSimulator;

  const QuickActionsRow({
    super.key,
    required this.onAddInvestment,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onCreateGoal,
    this.onViewNews,
    this.onSimulator,
  });

  @override
  Widget build(BuildContext context) {
    // All 6 actions always rendered, evenly spaced — no horizontal scroll
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          icon: Icons.add_chart_rounded,
          label: 'Aportar',
          color: AppColors.primary,       // blue #3B6EF5
          onTap: onAddInvestment,
        ),
        _ActionButton(
          icon: Icons.arrow_upward_rounded,
          label: 'Receita',
          color: AppColors.profit,        // green #00C896
          onTap: onAddIncome,
        ),
        _ActionButton(
          icon: Icons.arrow_downward_rounded,
          label: 'Despesa',
          color: AppColors.loss,          // red #E84040
          onTap: onAddExpense,
        ),
        _ActionButton(
          icon: Icons.flag_rounded,
          label: 'Meta',
          color: AppColors.warning,       // orange #F5A623
          onTap: onCreateGoal,
        ),
        _ActionButton(
          icon: Icons.calendar_today_rounded, // calendar per Figma (teal)
          label: 'Notícias',
          color: AppColors.profit,        // teal/green #00C896 per Figma
          onTap: onViewNews ?? () {},
        ),
        _ActionButton(
          icon: Icons.bar_chart_rounded,
          label: 'Simulador',
          color: AppColors.purple,        // purple #7C4DFF per Figma
          onTap: onSimulator ?? () {},
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          // 48×48dp icon button, bg #1C2333, radius 12dp per Figma
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bg3, // #1C2333
              borderRadius: BorderRadius.circular(AppRadius.md), // 12dp
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary, // #8A94A6
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
