/// Category model for expense/income categorization.
class Category {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isDefault;
  final String? userId;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.isDefault = false,
    this.userId,
    required this.createdAt,
  });

  factory Category.fromRow(Map<String, dynamic> row) {
    return Category(
      id: row['id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      icon: row['icon'] as String?,
      color: row['color'] as String?,
      isDefault: row['is_default'] as bool? ?? false,
      userId: row['user_id'] as String?,
      createdAt: DateTime.parse(row['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Expense model for income and expense transactions.
class Expense {
  final String id;
  final String userId;
  final String categoryId;
  final String type;
  final String description;
  final double amount;
  final DateTime date;
  final bool isRecurring;
  final int? recurrenceDay;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated field
  final Category? category;

  const Expense({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    this.isRecurring = false,
    this.recurrenceDay,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });

  factory Expense.fromRow(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      categoryId: row['category_id'] as String,
      type: row['type'] as String,
      description: row['description'] as String,
      amount: _toDouble(row['amount']),
      date: DateTime.parse(row['date'].toString()),
      isRecurring: row['is_recurring'] as bool? ?? false,
      recurrenceDay: row['recurrence_day'] as int?,
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'].toString()),
      updatedAt: DateTime.parse(row['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'type': type,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceDay': recurrenceDay,
      'notes': notes,
      'category': category?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }
}
