import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalInvested;
  final double availableCash;
  final double monthlyGrowthPercent;
  final bool isLoading;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalInvested,
    required this.availableCash,
    required this.monthlyGrowthPercent,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppShadows.card,
      ),
      child: isLoading
          ? const _Skeleton()
          : _Body(
              totalBalance: totalBalance,
              totalInvested: totalInvested,
              availableCash: availableCash,
              monthlyGrowthPercent: monthlyGrowthPercent,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  final double totalBalance;
  final double totalInvested;
  final double availableCash;
  final double monthlyGrowthPercent;

  const _Body({
    required this.totalBalance,
    required this.totalInvested,
    required this.availableCash,
    required this.monthlyGrowthPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = monthlyGrowthPercent >= 0;
    final availableColor =
        availableCash >= 0 ? AppColors.profit : AppColors.loss;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Patrimônio Total',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            _GrowthBadge(percent: monthlyGrowthPercent, isPositive: isPositive),
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppFormatters.currency(totalBalance),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            _Pill(icon: Icons.shield_outlined, label: 'Carteira consolidada'),
            SizedBox(width: 8),
            _Pill(icon: Icons.sync_rounded, label: 'Atualizado'),
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: Colors.white.withOpacity(0.08)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'Investido',
                value: AppFormatters.currency(totalInvested),
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Metric(
                label: 'Disponível',
                value: AppFormatters.currency(availableCash),
                color: availableColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  final double percent;
  final bool isPositive;

  const _GrowthBadge({required this.percent, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.profit : AppColors.loss;
    final icon =
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 12),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  Widget _box(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(120, 14),
        const SizedBox(height: 12),
        _box(220, 32),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(child: _box(double.infinity, 60)),
            const SizedBox(width: 12),
            Expanded(child: _box(double.infinity, 60)),
          ],
        ),
      ],
    );
  }
}
