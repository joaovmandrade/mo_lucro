import 'dart:async';

/// Mock offline data source for goals API.
class GoalDataSource {
  final List<Map<String, dynamic>> _mockGoals = [
    {
      'id': 'g1',
      'title': 'Viagem para Europa',
      'targetAmount': 15000.00,
      'currentAmount': 4500.00,
      'deadline': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
    },
    {
      'id': 'g2',
      'title': 'Reserva de Emergência',
      'targetAmount': 20000.00,
      'currentAmount': 18000.00,
      'deadline': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    }
  ];

  Future<List<dynamic>> getGoals() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockGoals;
  }

  Future<Map<String, dynamic>> getGoalDetails(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockGoals.firstWhere((g) => g['id'] == id, orElse: () => throw Exception('Goal not found'));
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final newGoal = {
      ...data,
      'id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      'currentAmount': data['currentAmount'] ?? 0.0,
    };
    _mockGoals.add(newGoal);
    return newGoal;
  }

  Future<Map<String, dynamic>> updateGoal(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockGoals.indexWhere((g) => g['id'] == id);
    if (index != -1) {
      _mockGoals[index] = { ..._mockGoals[index], ...data };
      return _mockGoals[index];
    }
    throw Exception('Goal not found');
  }

  Future<void> deleteGoal(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockGoals.removeWhere((g) => g['id'] == id);
  }
}
