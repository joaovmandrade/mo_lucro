/// Goal model for financial goals tracking.
class Goal {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String priority;
  final String? strategy;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.priority = 'MEDIA',
    this.strategy,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progress percentage (0-100).
  double get progressPercent {
    if (targetAmount <= 0) return 0;
    final pct = (currentAmount / targetAmount) * 100;
    return pct > 100 ? 100 : pct;
  }

  factory Goal.fromRow(Map<String, dynamic> row) {
    return Goal(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      name: row['name'] as String,
      type: row['type'] as String,
      targetAmount: _toDouble(row['target_amount']),
      currentAmount: _toDouble(row['current_amount']),
      deadline: row['deadline'] != null
          ? DateTime.parse(row['deadline'].toString())
          : null,
      priority: row['priority'] as String? ?? 'MEDIA',
      strategy: row['strategy'] as String?,
      isCompleted: row['is_completed'] as bool? ?? false,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'].toString())
          : null,
      createdAt: DateTime.parse(row['created_at'].toString()),
      updatedAt: DateTime.parse(row['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'strategy': strategy,
      'progressPercent': progressPercent,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
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
