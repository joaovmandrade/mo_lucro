import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _service = TransactionService();
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String _filter = 'all'; // 'all' | 'income' | 'expense'
  DateTime _month = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getTransactions();
      if (mounted) setState(() => _transactions = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String id) async {
    await _service.deleteTransaction(id);
    _load();
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1);
    if (next.isBefore(DateTime.now().add(const Duration(days: 31)))) {
      setState(() => _month = next);
    }
  }

  List<TransactionModel> get _filtered {
    final inMonth = _transactions.where((t) {
      return t.date.year == _month.year && t.date.month == _month.month;
    }).toList();

    if (_filter == 'all') return inMonth;
    return inMonth.where((t) => t.type == _filter).toList();
  }

  double get _monthIncome => _filtered
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);

  double get _monthExpense => _filtered
      .where((t) => !t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);

  /// Groups transactions by date string.
  Map<String, List<TransactionModel>> get _groupedByDate {
    final Map<String, List<TransactionModel>> groups = {};
    for (final t in _filtered) {
      final key = AppFormatters.dateFull(t.date);
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final net = _monthIncome - _monthExpense;
    final isPositiveNet = net >= 0;
    final groups = _groupedByDate;

    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
          if (ok == true) _load();
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.bg2,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // ── Blue gradient header ─────────────────────────
            SliverToBoxAdapter(
              child: _TransactionsHeader(
                month: _month,
                income: _monthIncome,
                expense: _monthExpense,
                net: net,
                isPositiveNet: isPositiveNet,
                isLoading: _loading,
                onPrevMonth: _prevMonth,
                onNextMonth: _nextMonth,
              ),
            ),

            // ── White body ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Filter chips ────────────────────────────
                  Row(
                    children: [
                      _FilterChip(
                          label: 'Todos',
                          value: 'all',
                          selected: _filter,
                          onTap: () => setState(() => _filter = 'all')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Receitas',
                          value: 'income',
                          selected: _filter,
                          color: AppColors.profit,
                          onTap: () => setState(() => _filter = 'income')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Despesas',
                          value: 'expense',
                          selected: _filter,
                          color: AppColors.loss,
                          onTap: () => setState(() => _filter = 'expense')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── List (grouped by date) ───────────────────
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                      ),
                    )
                  else if (_filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.receipt_long_outlined,
                              color: AppColors.textMuted, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            _filter == 'all'
                                ? 'Nenhuma transação neste mês'
                                : 'Nenhum registro nesta categoria',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    ...groups.entries.expand((entry) => [
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8, top: 4),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          ...entry.value.map(
                            (t) => TransactionTile(
                              transaction: t,
                              onDelete: () => _delete(t.id),
                            ),
                          ),
                        ]),
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
// Blue Header
// ─────────────────────────────────────────────────────────────
class _TransactionsHeader extends StatelessWidget {
  final DateTime month;
  final double income;
  final double expense;
  final double net;
  final bool isPositiveNet;
  final bool isLoading;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const _TransactionsHeader({
    required this.month,
    required this.income,
    required this.expense,
    required this.net,
    required this.isPositiveNet,
    required this.isLoading,
    required this.onPrevMonth,
    required this.onNextMonth,
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar with title + month navigator ──────
              Row(
                children: [
                  const Text(
                    'Transações',
                    style: TextStyle(
                      color: AppColors.textOnBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  // Month navigator
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onPrevMonth,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.20)),
                          ),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppFormatters.month(month),
                        style: const TextStyle(
                          color: AppColors.textOnBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onNextMonth,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.20)),
                          ),
                          child: const Icon(Icons.chevron_right_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Summary glass card ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.18)),
                ),
                child: isLoading
                    ? _HeaderSkeleton()
                    : _HeaderSummaryBody(
                        income: income,
                        expense: expense,
                        net: net,
                        isPositiveNet: isPositiveNet,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSummaryBody extends StatelessWidget {
  final double income;
  final double expense;
  final double net;
  final bool isPositiveNet;

  const _HeaderSummaryBody({
    required this.income,
    required this.expense,
    required this.net,
    required this.isPositiveNet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Receitas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.arrow_upward_rounded,
                          color: Color(0xFF6EE7B7), size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Receitas',
                        style: TextStyle(
                          color: AppColors.textOnBlueDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.currency(income),
                      style: const TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              width: 1,
              height: 36,
              color: Colors.white.withOpacity(0.18),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            // Despesas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.arrow_downward_rounded,
                          color: Color(0xFFFCA5A5), size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Despesas',
                        style: TextStyle(
                          color: AppColors.textOnBlueDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppFormatters.currency(expense),
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Divider
        Container(height: 1, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 14),
        // Saldo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(
                isPositiveNet
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: AppColors.textOnBlueDim,
                size: 15,
              ),
              const SizedBox(width: 6),
              const Text(
                'Saldo do mês',
                style: TextStyle(
                  color: AppColors.textOnBlueDim,
                  fontSize: 13,
                ),
              ),
            ]),
            Text(
              '${isPositiveNet ? '+' : ''}${AppFormatters.currency(net)}',
              style: TextStyle(
                color: isPositiveNet
                    ? const Color(0xFF6EE7B7)
                    : const Color(0xFFFCA5A5),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
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
          Row(children: [
            _box(90, 32),
            const SizedBox(width: 16),
            _box(90, 32),
          ]),
          const SizedBox(height: 14),
          _box(double.infinity, 1),
          const SizedBox(height: 14),
          Row(children: [
            _box(90, 13),
            const Spacer(),
            _box(80, 15),
          ]),
        ],
      );
}

// ─────────────────────────────────────────────────────────────
// Filter Chip
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    final c = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.12) : AppColors.bg1,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
              color: isSelected ? c : AppColors.border,
              width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? c : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
