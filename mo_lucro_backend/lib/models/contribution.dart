/// Contribution model representing an investment deposit.
class Contribution {
  final String id;
  final String investmentId;
  final String userId;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const Contribution({
    required this.id,
    required this.investmentId,
    required this.userId,
    required this.amount,
    required this.date,
    this.notes,
    required this.createdAt,
  });

  factory Contribution.fromRow(Map<String, dynamic> row) {
    return Contribution(
      id: row['id'] as String,
      investmentId: row['investment_id'] as String,
      userId: row['user_id'] as String,
      amount: _toDouble(row['amount']),
      date: DateTime.parse(row['date'].toString()),
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investmentId': investmentId,
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.parse(value.toString());
  }
}
