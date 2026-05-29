import 'package:flutter/material.dart';
import '../core/theme.dart';

class QuickActionSheet extends StatelessWidget {
  final VoidCallback onAddInvestment;
  final VoidCallback onAddExpense;
  final VoidCallback onAddIncome;
  final VoidCallback onCreateGoal;

  const QuickActionSheet({
    super.key,
    required this.onAddInvestment,
    required this.onAddExpense,
    required this.onAddIncome,
    required this.onCreateGoal,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAddInvestment,
    required VoidCallback onAddExpense,
    required VoidCallback onAddIncome,
    required VoidCallback onCreateGoal,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => QuickActionSheet(
        onAddInvestment: onAddInvestment,
        onAddExpense: onAddExpense,
        onAddIncome: onAddIncome,
        onCreateGoal: onCreateGoal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Ação Rápida',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'O que você quer registrar?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Action grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _ActionTile(
                icon: Icons.trending_up_rounded,
                label: 'Investimento',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  onAddInvestment();
                },
              ),
              _ActionTile(
                icon: Icons.arrow_downward_rounded,
                label: 'Despesa',
                color: AppColors.loss,
                onTap: () {
                  Navigator.pop(context);
                  onAddExpense();
                },
              ),
              _ActionTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Receita',
                color: AppColors.profit,
                onTap: () {
                  Navigator.pop(context);
                  onAddIncome();
                },
              ),
              _ActionTile(
                icon: Icons.flag_rounded,
                label: 'Criar Meta',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  onCreateGoal();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
