import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/portfolio_position.dart';
import '../utils/formatters.dart';

class AssetCard extends StatelessWidget {
  final PortfolioPosition position;
  final VoidCallback? onDelete;

  const AssetCard({
    super.key,
    required this.position,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Using avg price as current price (no live API)
    // P&L is 0 until live prices are integrated
    final currentPrice = position.avgPrice;
    final pnl = position.profitLoss(currentPrice);
    final pnlPercent = position.profitLossPercent(currentPrice);
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset avatar
              _AssetAvatar(asset: position.asset, category: position.category),
              const SizedBox(width: 14),

              // Asset info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position.asset,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _categoryLabel(position.category),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // P&L
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.currency(pnl),
                    style: TextStyle(
                      color: isProfit ? AppColors.profit : AppColors.loss,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _PnlBadge(percent: pnlPercent, isProfit: isProfit),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: 'Qtd',
                  value: position.quantity % 1 == 0
                      ? position.quantity.toInt().toString()
                      : position.quantity.toStringAsFixed(4),
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: 'Preço Médio',
                  value: AppFormatters.currency(position.avgPrice),
                ),
              ),
              Expanded(
                child: _MetricCell(
                  label: 'Total',
                  value: AppFormatters.currency(position.totalInvested),
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'stocks':
        return 'Ações';
      case 'crypto':
        return 'Criptomoedas';
      case 'fixed_income':
        return 'Renda Fixa';
      default:
        return 'Outros';
    }
  }
}

class _AssetAvatar extends StatelessWidget {
  final String asset;
  final String category;

  const _AssetAvatar({required this.asset, required this.category});

  Color get _color {
    switch (category) {
      case 'stocks':
        return AppColors.accent;
      case 'crypto':
        return AppColors.warning;
      case 'fixed_income':
        return AppColors.profit;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          asset.length > 2 ? asset.substring(0, 2) : asset,
          style: TextStyle(
            color: _color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PnlBadge extends StatelessWidget {
  final double percent;
  final bool isProfit;

  const _PnlBadge({required this.percent, required this.isProfit});

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? AppColors.profit : AppColors.loss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppFormatters.percentSimple(percent),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;

  const _MetricCell({
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
