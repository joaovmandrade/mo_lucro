class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'income' | 'expense'
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  bool get isIncome => type == 'income';

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    // The live table uses 'created_at' — fall back gracefully if 'date' is absent
    final rawDate = map['date'] as String? ?? map['created_at'] as String?;

    return TransactionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String? ?? 'others',
      // 'description' column may not exist in existing tables
      description: map['description'] as String? ?? '',
      date: rawDate != null ? DateTime.parse(rawDate) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'type': type,
        'amount': amount,
        'category': category,
        // Only include optional fields if the table supports them
        'description': description,
      };

  @override
  String toString() =>
      'TransactionModel(id: $id, type: $type, amount: $amount, category: $category)';
}
