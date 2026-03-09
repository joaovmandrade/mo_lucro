import '../core/database.dart';
import '../core/exceptions.dart';
import '../models/expense.dart';

/// Repository for expense data access.
class ExpenseRepository {
  /// Get expenses for a user with filters.
  Future<List<Expense>> findByUserId(
    String userId, {
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    var sql = '''
      SELECT e.*, c.name as category_name, c.type as category_type,
             c.icon as category_icon, c.color as category_color
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = @userId::uuid
    ''';
    final params = <String, dynamic>{
      'userId': userId,
      'limit': limit,
      'offset': offset,
    };

    if (type != null) {
      sql += ' AND e.type = @type::expense_type';
      params['type'] = type;
    }
    if (categoryId != null) {
      sql += ' AND e.category_id = @categoryId::uuid';
      params['categoryId'] = categoryId;
    }
    if (startDate != null) {
      sql += ' AND e.date >= @startDate';
      params['startDate'] = startDate.toIso8601String().split('T').first;
    }
    if (endDate != null) {
      sql += ' AND e.date <= @endDate';
      params['endDate'] = endDate.toIso8601String().split('T').first;
    }

    sql += ' ORDER BY e.date DESC LIMIT @limit OFFSET @offset';

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Expense.fromRow(r.toColumnMap())).toList();
  }

  /// Create a new expense.
  Future<Expense> create({
    required String userId,
    required String categoryId,
    required String type,
    required String description,
    required double amount,
    required DateTime date,
    bool isRecurring = false,
    int? recurrenceDay,
    String? notes,
  }) async {
    final result = await Database.query(
      '''
      INSERT INTO expenses (
        user_id, category_id, type, description, amount,
        date, is_recurring, recurrence_day, notes
      ) VALUES (
        @userId::uuid, @categoryId::uuid, @type::expense_type, @description,
        @amount, @date, @isRecurring, @recurrenceDay, @notes
      ) RETURNING *
      ''',
      parameters: {
        'userId': userId,
        'categoryId': categoryId,
        'type': type,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'isRecurring': isRecurring,
        'recurrenceDay': recurrenceDay,
        'notes': notes,
      },
    );
    return Expense.fromRow(result.first.toColumnMap());
  }

  /// Update an expense.
  Future<Expense> update(String id, String userId, Map<String, dynamic> fields) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'id': id, 'userId': userId};

    final fieldMap = {
      'categoryId': 'category_id = @categoryId::uuid',
      'type': 'type = @type::expense_type',
      'description': 'description = @description',
      'amount': 'amount = @amount',
      'date': 'date = @date',
      'isRecurring': 'is_recurring = @isRecurring',
      'recurrenceDay': 'recurrence_day = @recurrenceDay',
      'notes': 'notes = @notes',
    };

    for (final entry in fieldMap.entries) {
      if (fields.containsKey(entry.key)) {
        setClauses.add(entry.value);
        params[entry.key] = fields[entry.key];
      }
    }

    if (setClauses.isEmpty) {
      throw const ValidationException('Nenhum campo para atualizar');
    }

    setClauses.add('updated_at = CURRENT_TIMESTAMP');

    final result = await Database.query(
      '''
      UPDATE expenses SET ${setClauses.join(', ')}
      WHERE id = @id::uuid AND user_id = @userId::uuid
      RETURNING *
      ''',
      parameters: params,
    );

    if (result.isEmpty) {
      throw const NotFoundException('Lançamento não encontrado');
    }
    return Expense.fromRow(result.first.toColumnMap());
  }

  /// Delete an expense.
  Future<void> delete(String id, String userId) async {
    final result = await Database.query(
      'DELETE FROM expenses WHERE id = @id::uuid AND user_id = @userId::uuid RETURNING id',
      parameters: {'id': id, 'userId': userId},
    );
    if (result.isEmpty) {
      throw const NotFoundException('Lançamento não encontrado');
    }
  }

  /// Get monthly summary (income vs expenses).
  Future<Map<String, dynamic>> getMonthlySummary(
    String userId, {
    int? year,
    int? month,
  }) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    final result = await Database.query(
      '''
      SELECT
        type,
        SUM(amount) as total,
        COUNT(*) as count
      FROM expenses
      WHERE user_id = @userId::uuid
        AND EXTRACT(YEAR FROM date) = @year
        AND EXTRACT(MONTH FROM date) = @month
      GROUP BY type
      ''',
      parameters: {
        'userId': userId,
        'year': targetYear,
        'month': targetMonth,
      },
    );

    double totalIncome = 0;
    double totalExpenses = 0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (final row in result) {
      final map = row.toColumnMap();
      final type = map['type'] as String;
      final total = double.parse(map['total'].toString());
      final count = map['count'] as int;

      if (type == 'RECEITA') {
        totalIncome = total;
        incomeCount = count;
      } else {
        totalExpenses = total;
        expenseCount = count;
      }
    }

    return {
      'year': targetYear,
      'month': targetMonth,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses,
      'incomeCount': incomeCount,
      'expenseCount': expenseCount,
    };
  }

  /// Get expenses by category for a period.
  Future<List<Map<String, dynamic>>> getByCategory(
    String userId, {
    int? year,
    int? month,
  }) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final targetMonth = month ?? now.month;

    final result = await Database.query(
      '''
      SELECT
        c.name as category_name,
        c.color as category_color,
        c.icon as category_icon,
        SUM(e.amount) as total,
        COUNT(*) as count
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = @userId::uuid
        AND e.type = 'DESPESA'
        AND EXTRACT(YEAR FROM e.date) = @year
        AND EXTRACT(MONTH FROM e.date) = @month
      GROUP BY c.name, c.color, c.icon
      ORDER BY total DESC
      ''',
      parameters: {
        'userId': userId,
        'year': targetYear,
        'month': targetMonth,
      },
    );

    return result.map((r) => r.toColumnMap()).toList();
  }

  /// Get categories (default + user custom).
  Future<List<Category>> getCategories({String? userId, String? type}) async {
    var sql = '''
      SELECT * FROM categories
      WHERE (is_default = TRUE OR user_id = @userId::uuid)
    ''';
    final params = <String, dynamic>{'userId': userId};

    if (type != null) {
      sql += ' AND type = @type::category_type';
      params['type'] = type;
    }

    sql += ' ORDER BY is_default DESC, name ASC';

    final result = await Database.query(sql, parameters: params);
    return result.map((r) => Category.fromRow(r.toColumnMap())).toList();
  }
}
