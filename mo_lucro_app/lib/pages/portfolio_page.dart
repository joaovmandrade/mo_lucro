import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../utils/portfolio_utils.dart';
import '../utils/formatters.dart';
import '../widgets/asset_card.dart';
import '../widgets/portfolio_donut_chart.dart';
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

  Future<void> _deleteOperation(String id) async {
    final confirm = await _confirmDelete();
    if (confirm != true) return;
    await _service.deleteOperation(id);
    _load();
  }

  Future<bool?> _confirmDelete() => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bg2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Excluir operação',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          content: const Text(
              'Todas as operações deste ativo serão excluídas.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(
                      color: AppColors.loss,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final portfolio = calculatePortfolio(_operations);
    final distribution = categoryDistribution(portfolio);
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
          final result = await Navigator.push<bool>(context,
              MaterialPageRoute(builder: (_) => const AddOperationPage()));
          if (result == true) _load();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ─────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bg0,
              titleSpacing: 20,
              title: const Text('Portfólio',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary, size: 22),
                  onPressed: _load,
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Summary card ────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Total investido
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Total Investido',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                AppFormatters.currency(invested),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: AppColors.border),
                        // Posições
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Posições',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  '${portfolio.length}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 36,
                            color: AppColors.border),
                        // Operações
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Operações',
                                    style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(
                                  '${_operations.length}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Donut chart ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2),
                            ),
                          )
                        : PortfolioDonutChart(
                            distribution: distribution),
                  ),
                  const SizedBox(height: 16),

                  // ── Category filter chips ───────────────────
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categoryLabels.entries.map((e) {
                        final isSelected =
                            _selectedCategory == e.key;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategory = e.key),
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                      .withOpacity(0.15)
                                  : AppColors.bg2,
                              borderRadius:
                                  BorderRadius.circular(20),
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
                  const SizedBox(height: 16),

                  // ── Asset list com botão deletar ────────────
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                      ),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.inbox_outlined,
                                color: AppColors.textMuted, size: 40),
                            SizedBox(height: 12),
                            Text('Nenhum ativo nesta categoria',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filtered.map((pos) => AssetCard(
                          position: pos,
                          onDelete: () {
                            // Encontra a primeira operação do asset para deletar
                            final op = _operations.firstWhere(
                              (o) => o.asset == pos.asset,
                              orElse: () => _operations.first,
                            );
                            _deleteOperation(op.id);
                          },
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}