import 'dart:async';

/// Mock offline data source for expenses API.
class ExpenseDataSource {
  final List<Map<String, dynamic>> _mockExpenses = [
    {
      'id': 'e1',
      'title': 'Alimentação',
      'amount': 45.50,
      'date': DateTime.now().toIso8601String(),
      'category': 'FOOD',
      'type': 'EXPENSE',
    },
    {
      'id': 'e2',
      'title': 'Internet',
      'amount': 120.00,
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'category': 'UTILS',
      'type': 'EXPENSE',
    }
  ];

  Future<Map<String, dynamic>> getExpenses({
    String? type,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'items': _mockExpenses,
      'total': _mockExpenses.length,
      'page': page,
      'totalPages': 1,
    };
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final newExpense = {
      ...data,
      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
    };
    _mockExpenses.add(newExpense);
    return newExpense;
  }

  Future<Map<String, dynamic>> updateExpense(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockExpenses.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      _mockExpenses[index] = { ..._mockExpenses[index], ...data };
      return _mockExpenses[index];
    }
    throw Exception('Expense not found');
  }

  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockExpenses.removeWhere((e) => e['id'] == id);
  }

  Future<Map<String, dynamic>> getSummary({int? year, int? month}) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'totalAmount': 165.50,
      'byCategory': {
        'FOOD': 45.50,
        'UTILS': 120.00,
      }
    };
  }
}
