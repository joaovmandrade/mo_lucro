import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../services/transaction_service.dart';
import '../utils/portfolio_utils.dart';
import '../widgets/balance_card.dart';
import '../widgets/asset_card.dart';
import '../widgets/portfolio_donut_chart.dart';
import '../widgets/quick_action_sheet.dart';
import 'add_operation_page.dart';
import 'add_transaction_page.dart';
import 'add_goal_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _opService = OperationService();
  final _txService = TransactionService();

  List<OperationModel> _operations = [];
  Map<String, double> _monthSummary = {'income': 0, 'expense': 0};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();

      // Run independently so a transaction failure never silences operations
      final ops = await _opService.getOperations();
      debugPrint('[Dashboard] operations fetched: ${ops.length}');

      final summary = await _txService.getMonthSummary(now.year, now.month);
      debugPrint('[Dashboard] month summary: $summary');

      if (mounted) {
        setState(() {
          _operations = ops;
          _monthSummary = summary;
          _loading = false;
        });
        debugPrint('[Dashboard] portfolio positions: ${calculatePortfolio(_operations).length}');
      }
    } catch (e) {
      debugPrint('[Dashboard] _loadData error: $e');
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar dados: ${e.toString()}';
          _loading = false;
        });
      }
    }

  }

  void _openFab() {
    QuickActionSheet.show(
      context,
      onAddInvestment: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const AddOperationPage()),
        );
        if (result == true) _loadData();
      },
      onAddExpense: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionPage(initialType: 'expense')),
        );
        if (result == true) _loadData();
      },
      onAddIncome: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionPage(initialType: 'income')),
        );
        if (result == true) _loadData();
      },
      onCreateGoal: () async {
        await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const AddGoalPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = calculatePortfolio(_operations);
    final distribution = categoryDistribution(portfolio);
    final invested = totalInvested(portfolio);
    final income = _monthSummary['income'] ?? 0;
    final expense = _monthSummary['expense'] ?? 0;
    final availableCash = income - expense;
    final totalBalance = invested + availableCash;

    // Monthly growth (income vs expense as % change)
    final monthlyGrowth =
        income > 0 ? ((income - expense) / income * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard',
        onPressed: _openFab,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bg0,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: AppColors.bg0, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Mo Lucro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary),
                  onPressed: _loadData,
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
              ],
            ),

            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.loss.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(color: AppColors.loss)),
                  ),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Balance card
                  BalanceCard(
                    totalBalance: totalBalance,
                    totalInvested: invested,
                    availableCash: availableCash,
                    monthlyGrowthPercent: monthlyGrowth,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 28),

                  // Chart section
                  _SectionHeader(
                    title: 'Distribuição',
                    subtitle: 'Portfólio por categoria',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 180,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : PortfolioDonutChart(distribution: distribution),
                  ),
                  const SizedBox(height: 28),

                  // Assets section
                  _SectionHeader(
                    title: 'Meus Ativos',
                    subtitle: '${portfolio.length} posições',
                  ),
                  const SizedBox(height: 16),

                  if (!_loading && portfolio.isEmpty)
                    _EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      message: 'Nenhum ativo ainda.\nAdicione sua primeira operação!',
                      onTap: _openFab,
                    )
                  else
                    ...portfolio.values.map(
                      (pos) => AssetCard(
                        position: pos,
                        onDelete: null,
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onTap;

  const _EmptyState({
    required this.icon,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Text(
                'Adicionar +',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}