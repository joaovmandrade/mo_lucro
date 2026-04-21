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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Dark navy card — matches Figma patrimônio card
          colors: [Color(0xFF111827), Color(0xFF162036)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
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
        // ── Row: label + growth badge ──────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Patrimônio Total',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            _GrowthBadge(
                percent: monthlyGrowthPercent,
                isPositive: isPositive),
          ],
        ),
        const SizedBox(height: 8),

        // ── Hero value ─────────────────────────────────────
        Text(
          AppFormatters.currency(totalBalance),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 14),

        // ── Pill chips ─────────────────────────────────────
        Row(
          children: [
            _Chip(
                icon: Icons.calendar_today_outlined, label: '1 dias'),
            const SizedBox(width: 8),
            _Chip(
                icon: Icons.swap_vert_rounded,
                label:
                    '${totalInvested > 0 ? 1 : 0} ativos'),
          ],
        ),
        const SizedBox(height: 16),

        // ── Divider ────────────────────────────────────────
        Container(height: 1, color: AppColors.border),
        const SizedBox(height: 16),

        // ── Sub-metrics row ────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Investido',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.currency(totalInvested),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                width: 1, height: 32, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Disponível',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.currency(availableCash),
                      style: TextStyle(
                        color: availableColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Growth badge ─────────────────────────────────────────────
class _GrowthBadge extends StatelessWidget {
  final double percent;
  final bool isPositive;
  const _GrowthBadge(
      {required this.percent, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.profit : AppColors.loss;
    final icon = isPositive
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
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

// ── Pill chip ─────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading skeleton ─────────────────────────────────────────
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  Widget _box(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _box(90, 12),
        const SizedBox(height: 10),
        _box(200, 32),
        const SizedBox(height: 20),
        Row(children: [
          _box(80, 12),
          const Spacer(),
          _box(80, 12),
        ]),
      ],
    );
  }
}