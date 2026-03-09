import '../core/exceptions.dart';
import '../repositories/expense_repository.dart';
import '../models/expense.dart';

/// Service for expense business logic.
class ExpenseService {
  final ExpenseRepository _repository;

  ExpenseService(this._repository);

  /// Get paginated expenses with filters.
  Future<Map<String, dynamic>> getExpenses(
    String userId, {
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final offset = (page - 1) * limit;
    final expenses = await _repository.findByUserId(
      userId,
      type: type,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );

    return {
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'pagination': {
        'total': expenses.length,
        'page': page,
        'limit': limit,
      },
    };
  }

  /// Create a new expense.
  Future<Expense> createExpense(String userId, Map<String, dynamic> data) async {
    final categoryId = data['categoryId'] as String?;
    final type = data['type'] as String?;
    final description = data['description'] as String?;
    final amount = (data['amount'] as num?)?.toDouble();
    final date = data['date'] as String?;

    if (categoryId == null || categoryId.isEmpty) {
      throw const ValidationException('Categoria é obrigatória');
    }
    if (type == null || (type != 'RECEITA' && type != 'DESPESA')) {
      throw const ValidationException('Tipo deve ser RECEITA ou DESPESA');
    }
    if (description == null || description.trim().isEmpty) {
      throw const ValidationException('Descrição é obrigatória');
    }
    if (amount == null || amount <= 0) {
      throw const ValidationException('Valor deve ser maior que zero');
    }
    if (date == null) {
      throw const ValidationException('Data é obrigatória');
    }

    return _repository.create(
      userId: userId,
      categoryId: categoryId,
      type: type,
      description: description.trim(),
      amount: amount,
      date: DateTime.parse(date),
      isRecurring: data['isRecurring'] as bool? ?? false,
      recurrenceDay: data['recurrenceDay'] as int?,
      notes: data['notes'] as String?,
    );
  }

  /// Update an expense.
  Future<Expense> updateExpense(
    String id,
    String userId,
    Map<String, dynamic> data,
  ) async {
    return _repository.update(id, userId, data);
  }

  /// Delete an expense.
  Future<void> deleteExpense(String id, String userId) async {
    return _repository.delete(id, userId);
  }

  /// Get monthly summary.
  Future<Map<String, dynamic>> getMonthlySummary(
    String userId, {
    int? year,
    int? month,
  }) async {
    final summary = await _repository.getMonthlySummary(
      userId,
      year: year,
      month: month,
    );
    final byCategory = await _repository.getByCategory(
      userId,
      year: year,
      month: month,
    );

    return {
      ...summary,
      'byCategory': byCategory,
    };
  }

  /// Get available categories.
  Future<List<Map<String, dynamic>>> getCategories({
    String? userId,
    String? type,
  }) async {
    final categories = await _repository.getCategories(
      userId: userId,
      type: type,
    );
    return categories.map((c) => c.toJson()).toList();
  }
}
