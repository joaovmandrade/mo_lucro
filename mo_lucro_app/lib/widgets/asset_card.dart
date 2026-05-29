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
  bool _loadingPrice = true;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  Future<void> _fetchPrice() async {
    final cat = widget.position.category;

    // Renda fixa e outros não têm cotação em tempo real
    if (cat == 'fixed_income' || cat == 'others') {
      setState(() => _loadingPrice = false);
      return;
    }

    // Passa a categoria para o serviço usar BRAPI ou CoinGecko
    final quote = await _marketService.getQuote(
      widget.position.asset,
      category: cat,
    );

    if (mounted) {
      setState(() {
        _currentPrice = quote.success ? quote.price : null;
        _changePercent = quote.success ? quote.changePercent : null;
        _loadingPrice = false;
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(asset: widget.position.asset, category: widget.position.category),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.position.asset,
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
                        _CategoryTag(category: widget.position.category),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _PriceRow(
                      loading: _loadingPrice,
                      currentPrice: _currentPrice,
                      changePercent: _changePercent,
                      category: widget.position.category,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.onDelete != null)
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.loss.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.loss.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.loss, size: 16),
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
                  if (hasPriceData) ...[
                    const SizedBox(height: 2),
                    const Text('vs preço médio',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 12),

          Row(
            children: [
              _Metric(
                label: 'Qtd',
                value: widget.position.quantity % 1 == 0
                    ? widget.position.quantity.toInt().toString()
                    : widget.position.quantity.toStringAsFixed(4),
              ),
              _Metric(
                label: 'Preço Médio',
                value: AppFormatters.currency(widget.position.avgPrice),
              ),
              _Metric(
                label: hasPriceData ? 'Valor Atual' : 'Total',
                value: hasPriceData
                    ? AppFormatters.currency(widget.position.quantity * currentPrice)
                    : AppFormatters.currency(widget.position.totalInvested),
                align: CrossAxisAlignment.end,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Price row ─────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final bool loading;
  final double? currentPrice;
  final double? changePercent;
  final String category;

  const _PriceRow({
    required this.loading,
    required this.currentPrice,
    required this.changePercent,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (category == 'fixed_income' || category == 'others') {
      return Text(_categoryLabel(category),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
    }

    if (loading) {
      return Container(
        width: 80, height: 10,
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    if (currentPrice == null) {
      return Text(_categoryLabel(category),
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
    }

    final change = changePercent ?? 0.0;
    final isUp = change >= 0;
    final changeColor = isUp ? AppColors.profit : AppColors.loss;

    return Row(
      children: [
        Text(
          AppFormatters.currency(currentPrice!),
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 6),
        Icon(
          isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
          color: changeColor, size: 16,
        ),
        Text(
          '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
          style: TextStyle(
              color: changeColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        Text(
          category == 'crypto' ? '24h' : 'hoje',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
      ],
    );
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
      case 'stocks': return AppColors.primary;
      case 'crypto':  return AppColors.warning;
      case 'fixed_income': return AppColors.profit;
      case 'fiis': return AppColors.accent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.24), _color.withOpacity(0.09)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _color.withOpacity(0.28)),
      ),
      child: Center(
        child: Text(
          asset.length > 2 ? asset.substring(0, 2) : asset,
          style: TextStyle(color: _color, fontSize: 13, fontWeight: FontWeight.w800),
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
      case 'stocks': return AppColors.primary;
      case 'crypto':  return AppColors.warning;
      case 'fixed_income': return AppColors.profit;
      case 'fiis': return AppColors.accent;
      default: return AppColors.textMuted;
    }
  }

  String get _label {
    switch (category) {
      case 'stocks': return 'Ações';
      case 'crypto':  return 'Cripto';
      case 'fixed_income': return 'Renda Fixa';
      case 'fiis': return 'FIIs';
      default: return 'Outros';
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
      child: Text(_label,
          style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.w600)),
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
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
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
