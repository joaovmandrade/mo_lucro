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
      final ops = await _opService.getOperations();
      final summary = await _txService.getMonthSummary(now.year, now.month);
      if (mounted)
        setState(() {
          _operations = ops;
          _monthSummary = summary;
          _loading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString();
          _loading = false;
        });
    }
  }

  Future<void> _push(Widget page) async {
    final ok = await Navigator.push<bool>(
        context, MaterialPageRoute(builder: (_) => page));
    if (ok == true) _loadData();
  }

  String get _username {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = calculatePortfolio(_operations);
    final distribution = categoryDistribution(portfolio);
    final invested = totalInvested(portfolio);
    final income = _monthSummary['income'] ?? 0;
    final expense = _monthSummary['expense'] ?? 0;
    final available = income - expense;
    final total = invested + available;
    final growth = income > 0 ? ((income - expense) / income * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      // ── FAB: ícone circular no canto inferior esquerdo ──────
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_dashboard',
        onPressed: () => _push(const AddOperationPage()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.bg0,
              titleSpacing: 20,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mo Lucro',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      Text('Olá, $_username 👋',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.textSecondary, size: 22),
                  onPressed: _loadData,
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.textSecondary, size: 22),
                  onPressed: () => Supabase.instance.client.auth.signOut(),
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BalanceCard(
                    totalBalance: total,
                    totalInvested: invested,
                    availableCash: available,
                    monthlyGrowthPercent: growth,
                    isLoading: _loading,
                  ),
                  const SizedBox(height: 24),

                  // ── Ações Rápidas ────────────────────────────
                  _QuickActionsSection(
                    onAportar: () => _push(const AddOperationPage()),
                    onReceita: () =>
                        _push(const AddTransactionPage(initialType: 'income')),
                    onDespesa: () =>
                        _push(const AddTransactionPage(initialType: 'expense')),
                    onMeta: () => _push(const AddGoalPage()),
                  ),
                  const SizedBox(height: 24),

                  // ── Dica do Dia ──────────────────────────────
                  const _DicaCard(),
                  const SizedBox(height: 24),

                  // ── Distribuição ─────────────────────────────
                  _SectionTitle(
                      title: 'Distribuição', subtitle: 'por categoria'),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary, strokeWidth: 2),
                            ),
                          )
                        : PortfolioDonutChart(distribution: distribution),
                  ),
                  const SizedBox(height: 24),

                  // ── Minhas Posições ──────────────────────────
                  _SectionTitle(
                    title: 'Minhas Posições',
                    subtitle: '${portfolio.length} ativos',
                    action: portfolio.isNotEmpty
                        ? TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            child: const Text('Ver detalhes',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),

                  if (_error != null)
                    _ErrorBanner(message: _error!)
                  else if (_loading) ...[
                    _SkeletonCard(),
                    const SizedBox(height: 10),
                    _SkeletonCard()
                  ] else if (portfolio.isEmpty)
                    _EmptyState(onAdd: () => _push(const AddOperationPage()))
                  else
                    ...portfolio.values.map((pos) => AssetCard(position: pos)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onAportar;
  final VoidCallback onReceita;
  final VoidCallback onDespesa;
  final VoidCallback onMeta;

  const _QuickActionsSection({
    required this.onAportar,
    required this.onReceita,
    required this.onDespesa,
    required this.onMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ações Rápidas',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QBtn(
                icon: Icons.add_chart_rounded,
                label: 'Aportar',
                color: AppColors.accentBlue,
                onTap: onAportar),
            _QBtn(
                icon: Icons.arrow_upward_rounded,
                label: 'Receita',
                color: AppColors.accentGreen,
                onTap: onReceita),
            _QBtn(
                icon: Icons.arrow_downward_rounded,
                label: 'Despesa',
                color: AppColors.accentRed,
                onTap: onDespesa),
            _QBtn(
                icon: Icons.flag_rounded,
                label: 'Meta',
                color: AppColors.accentOrange,
                onTap: onMeta),
            _QBtn(
                icon: Icons.newspaper_rounded,
                label: 'Notícias',
                color: AppColors.accentTeal,
                onTap: () {}),
            _QBtn(
                icon: Icons.calculate_rounded,
                label: 'Simulador',
                color: AppColors.accentPurple,
                onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Dica do Dia ───────────────────────────────────────────────
class _DicaCard extends StatelessWidget {
  const _DicaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Dica do Dia',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text(
                  'Reserve 6 meses de gastos como reserva de emergência antes de investir.',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

// ── Section title ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const _SectionTitle(
      {required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Text(subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 88,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text(
              'Nenhum ativo ainda.\nAdicione sua primeira operação!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Text('Adicionar +',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.loss.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.loss.withOpacity(0.3)),
        ),
        child: Text(message,
            style: const TextStyle(color: AppColors.loss, fontSize: 13)),
      );
}
