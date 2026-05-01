import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/portfolio_position.dart';
import '../utils/formatters.dart';

class AssetCard extends StatelessWidget {
  final PortfolioPosition position;
  final VoidCallback? onDelete;

  const AssetCard({super.key, required this.position, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final currentPrice = position.avgPrice;
    final pnl = position.profitLoss(currentPrice);
    final pnlPct = position.profitLossPercent(currentPrice);
    final isProfit = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // ── Top row ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _Avatar(asset: position.asset, category: position.category),
              const SizedBox(width: 12),

              // Name + category tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            position.asset,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryTag(category: position.category),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _categoryLabel(position.category),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // P&L + delete button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Delete button
                  if (onDelete != null)
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.loss.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.loss.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.loss,
                          size: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.currency(pnl),
                    style: TextStyle(
                      color: isProfit ? AppColors.profit : AppColors.loss,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _PnlBadge(percent: pnlPct, isProfit: isProfit),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),

          // ── Metrics ──────────────────────────────────────────
          Row(
            children: [
              _Metric(
                label: 'Qtd',
                value: position.quantity % 1 == 0
                    ? position.quantity.toInt().toString()
                    : position.quantity.toStringAsFixed(4),
              ),
              _Metric(
                label: 'Preço Médio',
                value: AppFormatters.currency(position.avgPrice),
              ),
              _Metric(
                label: 'Total',
                value: AppFormatters.currency(position.totalInvested),
                align: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(String cat) {
    const map = {
      'stocks': 'Ações',
      'crypto': 'Criptomoedas',
      'fixed_income': 'Renda Fixa',
      'others': 'Outros',
    };
    return map[cat] ?? 'Outros';
  }
}

// ── Avatar ────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String asset;
  final String category;
  const _Avatar({required this.asset, required this.category});

  Color get _color {
    switch (category) {
      case 'stocks':
        return AppColors.primary;
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
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.24), _color.withOpacity(0.09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _color.withOpacity(0.28)),
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

// ── Category tag ─────────────────────────────────────────────
class _CategoryTag extends StatelessWidget {
  final String category;
  const _CategoryTag({required this.category});

  Color get _color {
    switch (category) {
      case 'stocks':
        return AppColors.primary;
      case 'crypto':
        return AppColors.warning;
      case 'fixed_income':
        return AppColors.profit;
      default:
        return AppColors.textMuted;
    }
  }

  String get _label {
    switch (category) {
      case 'stocks':
        return 'Ações';
      case 'crypto':
        return 'Cripto';
      case 'fixed_income':
        return 'Renda Fixa';
      default:
        return 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── P&L Badge ─────────────────────────────────────────────────
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
        '${isProfit ? '+' : ''}${AppFormatters.percentSimple(percent)}%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Metric cell ───────────────────────────────────────────────
class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;

  const _Metric({
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
      ),
    );
  }
}
