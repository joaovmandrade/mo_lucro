import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../utils/portfolio_utils.dart';
import '../utils/formatters.dart';
import '../widgets/asset_card.dart';
import 'add_operation_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final _service = OperationService();
  List<OperationModel> _operations = [];
  bool _loading = true;
  String _selectedCategory = 'all';

  static const _categoryLabels = {
    'all': 'Todos',
    'stocks': 'Ações',
    'crypto': 'Cripto',
    'fixed_income': 'Renda Fixa',
    'others': 'Outros',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ops = await _service.getOperations();
      if (mounted) setState(() => _operations = ops);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = calculatePortfolio(_operations);
    final invested = totalInvested(portfolio);

    final filtered = _selectedCategory == 'all'
        ? portfolio.values.toList()
        : portfolio.values
            .where((p) => p.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_portfolio',
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddOperationPage()),
          );
          if (result == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bg0,
              title: const Text('Portfólio'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryMetric(
                            label: 'Total Investido',
                            value: AppFormatters.currency(invested),
                            color: AppColors.accent,
                          ),
                        ),
                        Container(
                            width: 1, height: 40, color: AppColors.border),
                        Expanded(
                          child: _SummaryMetric(
                            label: 'Posições',
                            value: portfolio.length.toString(),
                            color: AppColors.primary,
                            align: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category filter chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categoryLabels.entries.map((e) {
                        final isSelected = _selectedCategory == e.key;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : AppColors.bg2,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              e.value,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Asset list
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.inbox_outlined,
                                color: AppColors.textMuted, size: 40),
                            const SizedBox(height: 12),
                            const Text(
                              'Nenhum ativo nesta categoria',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((pos) => AssetCard(position: pos)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final CrossAxisAlignment align;

  const _SummaryMetric({
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
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
