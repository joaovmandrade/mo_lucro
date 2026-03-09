import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// Expenses list page with category overview.
class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  // Mock data
  static final _expenses = [
    {'desc': 'Supermercado', 'category': 'alimentação', 'amount': -450.0,
     'date': '05/03/2026'},
    {'desc': 'Salário', 'category': 'receita', 'amount': 8500.0,
     'date': '01/03/2026'},
    {'desc': 'Aluguel', 'category': 'moradia', 'amount': -1800.0,
     'date': '01/03/2026'},
    {'desc': 'Uber', 'category': 'transporte', 'amount': -35.0,
     'date': '04/03/2026'},
    {'desc': 'Academia', 'category': 'saúde', 'amount': -120.0,
     'date': '03/03/2026'},
    {'desc': 'Netflix', 'category': 'lazer', 'amount': -55.9,
     'date': '02/03/2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          final exp = _expenses[index];
          final amount = exp['amount'] as double;
          final isIncome = amount >= 0;
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
                    color: (isIncome ? AppColors.profit : AppColors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(exp['category'] as String),
                    color: isIncome ? AppColors.profit : AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp['desc'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(exp['category'] as String)[0].toUpperCase()}${(exp['category'] as String).substring(1)} • ${exp['date']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : ''}R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isIncome ? AppColors.profit : AppColors.error,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Lançamento'),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'alimentação': return Icons.restaurant;
      case 'transporte': return Icons.directions_car;
      case 'moradia': return Icons.home;
      case 'saúde': return Icons.favorite;
      case 'lazer': return Icons.movie;
      case 'estudos': return Icons.school;
      case 'contas fixas': return Icons.receipt_long;
      case 'receita': return Icons.trending_up;
      default: return Icons.more_horiz;
    }
  }
}
