import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import '../models/operation_model.dart';
import '../services/operation_service.dart';
import '../services/transaction_service.dart';
import '../utils/portfolio_utils.dart';
import '../utils/formatters.dart';
import '../widgets/asset_card.dart';
import '../widgets/patrimonio_line_chart.dart';
import 'add_operation_page.dart';
import 'add_goal_page.dart';
import 'market_news_page.dart';
import 'income_simulator_page.dart';

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
      if (mounted) {
        setState(() {
          _operations = ops;
          _monthSummary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
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
    final invested = totalInvested(portfolio);
    final income = _monthSummary['income'] ?? 0;
    final expense = _monthSummary['expense'] ?? 0;
    final available = income - expense;
    final total = invested + available;
    final returnAmt = income > expense ? income - expense : 0.0;
    final growth = invested > 0 ? (returnAmt / invested * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg1,
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // ── Blue gradient header ─────────────────────────
            SliverToBoxAdapter(
              child: _BlueHeader(
                username: _username,
                total: total,
                invested: invested,
                available: available,
                growth: growth,
                returnAmt: returnAmt,
                assetCount: portfolio.length,
                isLoading: _loading,
                onRefresh: _loadData,
              ),
            ),

            // ── White body ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick Actions
                  _QuickActionsSection(
                    onAportar: () => _push(const AddOperationPage()),
                    onSimular: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IncomeSimulatorPage())),
                    onNoticias: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MarketNewsPage())),
                    onMeta: () => _push(const AddGoalPage()),
                  ),
                  const SizedBox(height: 20),

                  // Dica do Dia
                  const _DicaCard(),
                  const SizedBox(height: 20),

                  // Gráfico
                  _ChartSection(
                      isLoading: _loading, totalInvested: invested),
                  const SizedBox(height: 20),

                  // Minhas Posições
                  _SectionTitle(
                    title: 'Minhas Posições',
                    subtitle: '${portfolio.length} ativos',
                    action: portfolio.isNotEmpty
                        ? TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Ver detalhes',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),

                  if (_error != null)
                    _ErrorBanner(message: _error!)
                  else if (_loading) ...[
                    _SkeletonCard(),
                    const SizedBox(height: 10),
                    _SkeletonCard(),
                  ] else if (portfolio.isEmpty)
                    _EmptyState(onAdd: () => _push(const AddOperationPage()))
                  else
                    ...portfolio.values.map((pos) => AssetCard(position: pos)),

                  const SizedBox(height: 16),

                  // Nova Operação button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _push(const AddOperationPage()),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Nova Operação'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
// Blue header
// ─────────────────────────────────────────────────────────────
class _BlueHeader extends StatelessWidget {
  final String username;
  final double total;
  final double invested;
  final double available;
  final double growth;
  final double returnAmt;
  final int assetCount;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _BlueHeader({
    required this.username,
    required this.total,
    required this.invested,
    required this.available,
    required this.growth,
    required this.returnAmt,
    required this.assetCount,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────
              Row(
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Mo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: 'Lucro',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _HeaderIconBtn(
                    icon: Icons.refresh_rounded,
                    onTap: onRefresh,
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconBtn(
                    icon: Icons.logout_rounded,
                    onTap: () =>
                        Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Patrimônio card ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: isLoading
                    ? const _PatrimoniSkeleton()
                    : _PatrimonioBody(
                        total: total,
                        invested: invested,
                        growth: growth,
                        returnAmt: returnAmt,
                      ),
              ),
              const SizedBox(height: 14),

              // ── Mini stats ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Streak',
                      value: '7 dias 🔥',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Ativos',
                      value: '$assetCount ativos',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _PatrimonioBody extends StatelessWidget {
  final double total;
  final double invested;
  final double growth;
  final double returnAmt;

  const _PatrimonioBody({
    required this.total,
    required this.invested,
    required this.growth,
    required this.returnAmt,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = growth >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patrimônio Total',
          style: TextStyle(
            color: AppColors.textOnBlueDim,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            AppFormatters.currency(total),
            style: const TextStyle(
              color: AppColors.textOnBlue,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Investido',
                  style: TextStyle(
                    color: AppColors.textOnBlueDim,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.currency(invested),
                  style: const TextStyle(
                    color: AppColors.textOnBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.profit.withOpacity(0.20),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border:
                    Border.all(color: AppColors.profit.withOpacity(0.35)),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${growth.toStringAsFixed(2)}%',
                style: const TextStyle(
                  color: AppColors.textOnBlueProfit,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (returnAmt > 0) ...[
          const SizedBox(height: 6),
          Text(
            'Retorno: ${AppFormatters.currency(returnAmt)}',
            style: const TextStyle(
              color: AppColors.textOnBlueReturn,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

class _PatrimoniSkeleton extends StatelessWidget {
  const _PatrimoniSkeleton();

  Widget _box(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(110, 13),
          const SizedBox(height: 10),
          _box(200, 30),
          const SizedBox(height: 16),
          Row(children: [
            _box(100, 36),
            const Spacer(),
            _box(70, 28),
          ]),
        ],
      );
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textOnBlueDim,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textOnBlue,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Quick Actions
// ─────────────────────────────────────────────────────────────
class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onAportar;
  final VoidCallback onSimular;
  final VoidCallback onNoticias;
  final VoidCallback onMeta;

  const _QuickActionsSection({
    required this.onAportar,
    required this.onSimular,
    required this.onNoticias,
    required this.onMeta,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QBtn(
          icon: Icons.add_chart_rounded,
          label: 'Aportar',
          color: AppColors.primary,
          onTap: onAportar,
        ),
        _QBtn(
          icon: Icons.calculate_rounded,
          label: 'Simular',
          color: AppColors.purple,
          onTap: onSimular,
        ),
        _QBtn(
          icon: Icons.newspaper_rounded,
          label: 'Notícias',
          color: AppColors.accentTeal,
          onTap: onNoticias,
        ),
        _QBtn(
          icon: Icons.flag_rounded,
          label: 'Metas',
          color: AppColors.warning,
          onTap: onMeta,
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

  const _QBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Dica do Dia',
                      style: TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'Risco',
                        style: TextStyle(
                          color: Color(0xFF1D4ED8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Diversificação é a chave para reduzir riscos no seu portfólio.',
                  style: TextStyle(
                    color: Color(0xFF1E40AF),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart Section ─────────────────────────────────────────────
class _ChartSection extends StatelessWidget {
  final bool isLoading;
  final double totalInvested;

  const _ChartSection(
      {required this.isLoading, required this.totalInvested});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Evolução do Patrimônio',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                'Ver mais',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PatrimonioLineChart(
              isLoading: isLoading, totalInvested: totalInvested),
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
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
        padding:
            const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.bg1,
          borderRadius: BorderRadius.circular(AppRadius.xl),
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
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.20)),
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

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.loss.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: AppColors.loss.withOpacity(0.20)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.loss, fontSize: 13),
        ),
      );
}
