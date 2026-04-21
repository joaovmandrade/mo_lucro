import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final _db = Supabase.instance.client;

  String get _userId {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return user.id;
  }

  Future<List<TransactionModel>> getTransactions() async {
    // Order by created_at — the live table doesn't have a 'date' column
    final res = await _db
        .from('transactions')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((row) => TransactionModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    required String description,
    required DateTime date,
  }) async {
    final payload = <String, dynamic>{
      'user_id': _userId,
      'type': type,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };

    if (description.isNotEmpty) {
      payload['description'] = description;
    }

    await _db.from('transactions').insert(payload);
  }

  Future<void> deleteTransaction(String id) async {
    await _db.from('transactions').delete().eq('id', id);
  }

  /// Returns total income and expense for the current month.
  /// Uses 'created_at' as the date filter since the live table may not have
  /// a separate 'date' column.
  Future<Map<String, double>> getMonthSummary(int year, int month) async {
    try {
      final start = DateTime(year, month, 1);
      final end = DateTime(year, month + 1, 1);

      final res = await _db
          .from('transactions')
          .select()
          .eq('user_id', _userId)
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String());

      double totalIncome = 0;
      double totalExpense = 0;

      for (final row in res as List) {
        final amount = (row['amount'] as num).toDouble();
        if (row['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      return {'income': totalIncome, 'expense': totalExpense};
    } catch (e) {
      // Never let a transaction query failure block the operations load
      debugPrint('[TransactionService.getMonthSummary] error: $e');
      return {'income': 0, 'expense': 0};
    }
  }
}
