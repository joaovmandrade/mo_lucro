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

  List<TransactionModel> get _filtered {
    if (_filter == 'all') return _transactions;
    return _transactions.where((t) => t.type == _filter).toList();
  }

  double get _totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);

  double get _totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
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
              title: const Text('Transações'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Month summary
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Receitas',
                          value: AppFormatters.currency(_totalIncome),
                          color: AppColors.profit,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Despesas',
                          value: AppFormatters.currency(_totalExpense),
                          color: AppColors.loss,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Filter
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
                          onTap: () =>
                              setState(() => _filter = 'income')),
                      const SizedBox(width: 8),
                      _FilterChip(
                          label: 'Despesas',
                          value: 'expense',
                          selected: _filter,
                          color: AppColors.loss,
                          onTap: () =>
                              setState(() => _filter = 'expense')),
                    ],
                  ),
                  const SizedBox(height: 20),

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
                                ? 'Nenhuma transação ainda'
                                : 'Nenhum registro nesta categoria',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._filtered.map(
                      (t) => TransactionTile(
                        transaction: t,
                        onDelete: () => _delete(t.id),
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 17, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.12) : AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
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
