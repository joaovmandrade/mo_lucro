import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/investment_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Investments list page with type filter tabs.
class InvestmentsPage extends ConsumerStatefulWidget {
  const InvestmentsPage({super.key});

  @override
  ConsumerState<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends ConsumerState<InvestmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const ['Todos', 'FIXED_INCOME', 'REAL_ESTATE', 'ACOES', 'CRIPTO', 'OUTROS'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final type = _tabController.index == 0 ? null : _tabs[_tabController.index];
        ref.read(investmentProvider.notifier).loadInvestments(type: type);
      }
    });
    Future.microtask(() => ref.read(investmentProvider.notifier).loadInvestments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Investimentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(investmentProvider.notifier).loadInvestments(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: _tabs
              .map((t) => Tab(text: t == 'Todos' ? t : t.replaceAll('_', ' ')))
              .toList(),
        ),
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : state.error != null
          ? Center(child: Text(state.error!))
          : state.investments.isEmpty
            ? const Center(child: Text('Nenhum investimento encontrado.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.investments.length,
                itemBuilder: (context, index) {
                  final inv = state.investments[index];
                  final isLast = index == state.investments.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Icon(
                                _getIcon(inv['type'] as String),
                                color: AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${inv['name']} ${inv['symbol'] != null ? '(${inv['symbol']})' : ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Retorno: ${inv['yield'] ?? 0}% • Valor Original: ${(inv['amountInvested'] as num).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'R\$ ${(inv['currentValue'] as num).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        const Divider(height: 1, indent: 56),
                    ],
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/investments/add'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Investimento'),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'FIXED_INCOME': return Icons.account_balance;
      case 'ACOES': return Icons.show_chart;
      case 'REAL_ESTATE': return Icons.apartment;
      case 'CRIPTO': return Icons.currency_bitcoin;
      default: return Icons.more_horiz;
    }
  }
}
