class GoalModel {
  final String id;
  final String userId;
  final String title;
  final double targetValue;
  final double currentValue;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    required this.createdAt,
  });

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progress * 100;

  bool get isCompleted => currentValue >= targetValue;

  double get remaining => (targetValue - currentValue).clamp(0.0, double.infinity);

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    // Support both schema variants:
    //   - new schema:  title / target_value / current_value
    //   - live table:  name  / target       / current
    final title =
        map['title'] as String? ?? map['name'] as String? ?? '';

    final targetValue =
        ((map['target_value'] ?? map['target']) as num?)?.toDouble() ?? 0.0;

    final currentValue =
        ((map['current_value'] ?? map['current']) as num?)?.toDouble() ?? 0.0;

    return GoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: title,
      targetValue: targetValue,
      currentValue: currentValue,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Inserts using the live table column names (name / target / current).
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': title,
        'target': targetValue,
        'current': currentValue,
      };

  GoalModel copyWith({double? currentValue}) => GoalModel(
        id: id,
        userId: userId,
        title: title,
        targetValue: targetValue,
        currentValue: currentValue ?? this.currentValue,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'GoalModel(id: $id, title: $title, progress: ${progressPercent.toStringAsFixed(1)}%)';
}
