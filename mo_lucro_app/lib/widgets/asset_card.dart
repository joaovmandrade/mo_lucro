import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/portfolio_position.dart';
import '../services/market_data_service.dart';
import '../utils/formatters.dart';

class AssetCard extends StatefulWidget {
  final PortfolioPosition position;
  final VoidCallback? onDelete;

  const AssetCard({super.key, required this.position, this.onDelete});

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  static final _marketService = MarketDataService();

  double? _currentPrice;
  double? _changePercent;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    final cat = widget.position.category;
    if (cat == 'fixed_income' || cat == 'others') return;
    final quote = await _marketService.getQuote(
      widget.position.asset,
      category: cat,
    );
    if (mounted) {
      setState(() {
        _currentPrice = quote.success ? quote.price : null;
        _changePercent = quote.success ? quote.changePercent : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPrice = _currentPrice ?? widget.position.avgPrice;
    final pnl = widget.position.profitLoss(currentPrice);
    final pnlPct = widget.position.profitLossPercent(currentPrice);
    final isProfit = pnl >= 0;
    final hasPriceData = _currentPrice != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // ── Top section ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(
                    asset: widget.position.asset,
                    category: widget.position.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.position.asset,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _CategoryTag(category: widget.position.category),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _companyName(widget.position.asset,
                            widget.position.category),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_quantityLabel(widget.position.quantity)} ações',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.onDelete != null) ...[
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.loss.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                                color: AppColors.loss.withOpacity(0.20)),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.loss, size: 15),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      AppFormatters.currency(
                          widget.position.quantity * currentPrice),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _PnlBadge(
                      percent: pnlPct,
                      isProfit: isProfit,
                      changePercent: _changePercent,
                      hasPriceData: hasPriceData,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Bottom metrics ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.lg),
                bottomRight: Radius.circular(AppRadius.lg),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _Metric(
                  label: 'Preço Médio',
                  value: AppFormatters.currency(widget.position.avgPrice),
                ),
                _Divider(),
                _Metric(
                  label: hasPriceData ? 'Preço Atual' : 'Total',
                  value: hasPriceData
                      ? AppFormatters.currency(_currentPrice!)
                      : AppFormatters.currency(widget.position.totalInvested),
                ),
                _Divider(),
                _Metric(
                  label: 'Investido',
                  value: AppFormatters.currency(widget.position.totalInvested),
                  align: CrossAxisAlignment.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _quantityLabel(double qty) =>
      qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(2);

  String _companyName(String asset, String category) {
    const names = {
      'PETR4': 'Petrobras',
      'VALE3': 'Vale',
      'ITUB4': 'Itaú Unibanco',
      'BBDC4': 'Bradesco',
      'MGLU3': 'Magazine Luiza',
      'WEGE3': 'Weg',
      'ABEV3': 'Ambev',
    };
    return names[asset] ?? _categoryLabel(category);
  }

  String _categoryLabel(String cat) {
    const map = {
      'stocks': 'Ações',
      'crypto': 'Criptomoedas',
      'fixed_income': 'Renda Fixa',
      'fiis': 'FIIs',
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
      case 'fiis':
        return AppColors.accent;
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
        color: _color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _color.withOpacity(0.22)),
      ),
      child: Center(
        child: Text(
          asset.length > 2 ? asset.substring(0, 2) : asset,
          style: TextStyle(
              color: _color, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

// ── Category tag ──────────────────────────────────────────────
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
      case 'fiis':
        return AppColors.accent;
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
      case 'fiis':
        return 'FIIs';
      default:
        return 'Outros';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: _color.withOpacity(0.20)),
      ),
      child: Text(_label,
          style:
              TextStyle(color: _color, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}

// ── P&L Badge ─────────────────────────────────────────────────
class _PnlBadge extends StatelessWidget {
  final double percent;
  final bool isProfit;
  final double? changePercent;
  final bool hasPriceData;

  const _PnlBadge({
    required this.percent,
    required this.isProfit,
    this.changePercent,
    this.hasPriceData = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? AppColors.profitDark : AppColors.loss;
    final bgColor = isProfit
        ? AppColors.profit.withOpacity(0.10)
        : AppColors.loss.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isProfit ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            color: color,
            size: 14,
          ),
          Text(
            '${isProfit ? '' : ''}${AppFormatters.percentSimple(percent.abs())}%',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
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
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.border,
      );
}
