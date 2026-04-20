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
    final isPositive = monthlyGrowthPercent >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1a2340)],
        ),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isLoading
          ? const _BalanceSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Total',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _GrowthBadge(percent: monthlyGrowthPercent),
                  ],
                ),
                const SizedBox(height: 10),

                // Main balance
                Text(
                  AppFormatters.currency(totalBalance),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  color: AppColors.border,
                ),
                const SizedBox(height: 20),

                // Sub-metrics row
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        label: 'Investido',
                        value: AppFormatters.currency(totalInvested),
                        color: AppColors.accent,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _MetricItem(
                        label: 'Disponível',
                        value: AppFormatters.currency(availableCash),
                        color: isPositive ? AppColors.profit : AppColors.loss,
                        align: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  final double percent;
  const _GrowthBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final isPositive = percent >= 0;
    final color = isPositive ? AppColors.profit : AppColors.loss;
    final bg = color.withOpacity(0.12);
    final icon = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            '${percent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final CrossAxisAlignment align;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: align == CrossAxisAlignment.start ? 0 : 16,
        right: align == CrossAxisAlignment.end ? 0 : 16,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _shimmer(width: 80, height: 12),
        const SizedBox(height: 12),
        _shimmer(width: 200, height: 34),
        const SizedBox(height: 24),
        Row(
          children: [
            _shimmer(width: 100, height: 12),
            const Spacer(),
            _shimmer(width: 100, height: 12),
          ],
        ),
      ],
    );
  }

  Widget _shimmer({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
