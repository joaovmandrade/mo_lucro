import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Investments list page with type filter tabs.
class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({super.key});

  @override
  State<InvestmentsPage> createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const ['Todos', 'CDB', 'Tesouro', 'Ações', 'FIIs', 'Cripto', 'Outros'];

  // Mock data
  final _investments = [
    {'name': 'CDB Banco Inter 120%', 'type': 'CDB', 'amount': 15000.0,
     'rate': '120% CDI', 'maturity': '15/03/2026'},
    {'name': 'Tesouro IPCA+ 2029', 'type': 'Tesouro', 'amount': 10000.0,
     'rate': 'IPCA + 6,5%', 'maturity': '15/05/2029'},
    {'name': 'PETR4', 'type': 'Ações', 'amount': 8000.0,
     'rate': 'Variável', 'maturity': '-'},
    {'name': 'XPLG11', 'type': 'FIIs', 'amount': 12000.0,
     'rate': 'Variável', 'maturity': '-'},
    {'name': 'CDB Nubank 100%', 'type': 'CDB', 'amount': 20000.0,
     'rate': '100% CDI', 'maturity': '20/01/2027'},
    {'name': 'Bitcoin', 'type': 'Cripto', 'amount': 5000.0,
     'rate': 'Variável', 'maturity': '-'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Investimentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _investments.length,
        itemBuilder: (context, index) {
          final inv = _investments[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(inv['type'] as String),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${inv['rate']} • Venc: ${inv['maturity']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${(inv['amount'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
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
      case 'CDB': return Icons.account_balance;
      case 'Tesouro': return Icons.flag_rounded;
      case 'Ações': return Icons.show_chart;
      case 'FIIs': return Icons.apartment;
      case 'Cripto': return Icons.currency_bitcoin;
      default: return Icons.more_horiz;
    }
  }
}
