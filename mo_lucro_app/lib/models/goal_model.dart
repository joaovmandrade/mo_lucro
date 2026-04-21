class GoalModel {
  final String id;
  final String userId;
  final String title;
  final double targetValue;
  final double currentValue;
  final DateTime? deadline;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    this.deadline,
    required this.createdAt,
  });

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  double get progressPercent => progress * 100;

  bool get isCompleted => currentValue >= targetValue;

  double get remaining =>
      (targetValue - currentValue).clamp(0.0, double.infinity);

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    // Column names in the live DB: name / target / current
    final title =
        map['name'] as String? ?? map['title'] as String? ?? '';

    final targetValue =
        ((map['target'] ?? map['target_value']) as num?)?.toDouble() ?? 0.0;

    final currentValue =
        ((map['current'] ?? map['current_value']) as num?)?.toDouble() ?? 0.0;

    final rawDeadline = map['deadline'] as String?;

    return GoalModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: title,
      targetValue: targetValue,
      currentValue: currentValue,
      deadline: rawDeadline != null ? DateTime.tryParse(rawDeadline) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Write using live DB column names: name / target / current
  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': title,
        'target': targetValue,
        'current': currentValue,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
      };

  GoalModel copyWith({double? currentValue, DateTime? deadline}) => GoalModel(
        id: id,
        userId: userId,
        title: title,
        targetValue: targetValue,
        currentValue: currentValue ?? this.currentValue,
        deadline: deadline ?? this.deadline,
        createdAt: createdAt,
      );

  @override
  String toString() =>
      'GoalModel(id: $id, title: $title, progress: ${progressPercent.toStringAsFixed(1)}%)';
}
