import 'dart:async';

/// Mock offline data source for dashboard API.
class DashboardDataSource {
  Future<Map<String, dynamic>> getDashboard() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'totalBalance': 15420.50,
      'monthlyIncome': 5000.00,
      'monthlyExpense': 3240.10,
      'recentTransactions': [
        {
          'id': '1',
          'title': 'Mercado Livre',
          'amount': -150.00,
          'date': DateTime.now().toIso8601String(),
          'type': 'EXPENSE',
        },
         {
          'id': '2',
          'title': 'Salário',
          'amount': 5000.00,
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'type': 'INCOME',
        },
      ],
      'goalsProgress': [
        {
          'id': 'g1',
          'title': 'Comprar Carro',
          'targetAmount': 50000.00,
          'currentAmount': 10000.00,
        }
      ]
    };
  }
}
