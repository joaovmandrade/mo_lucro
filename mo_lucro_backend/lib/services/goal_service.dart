import '../core/exceptions.dart';
import '../repositories/goal_repository.dart';
import '../models/goal.dart';

/// Service for goal business logic.
class GoalService {
  final GoalRepository _repository;

  GoalService(this._repository);

  /// Get all goals for a user.
  Future<List<Map<String, dynamic>>> getGoals(String userId) async {
    final goals = await _repository.findByUserId(userId);
    return goals.map((g) {
      final json = g.toJson();
      json['suggestedStrategy'] = _generateStrategy(g);
      return json;
    }).toList();
  }

  /// Get goal details with strategy.
  Future<Map<String, dynamic>> getGoalDetails(String id, String userId) async {
    final goal = await _repository.findById(id, userId);
    if (goal == null) {
      throw const NotFoundException('Meta não encontrada');
    }
    final json = goal.toJson();
    json['suggestedStrategy'] = _generateStrategy(goal);
    return json;
  }

  /// Create a new goal.
  Future<Goal> createGoal(String userId, Map<String, dynamic> data) async {
    final name = data['name'] as String?;
    final type = data['type'] as String?;
    final targetAmount = (data['targetAmount'] as num?)?.toDouble();

    if (name == null || name.trim().isEmpty) {
      throw const ValidationException('Nome da meta é obrigatório');
    }
    if (type == null || type.isEmpty) {
      throw const ValidationException('Tipo da meta é obrigatório');
    }
    if (targetAmount == null || targetAmount <= 0) {
      throw const ValidationException('Valor alvo deve ser maior que zero');
    }

    return _repository.create(
      userId: userId,
      name: name.trim(),
      type: type,
      targetAmount: targetAmount,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0,
      deadline: data['deadline'] != null
          ? DateTime.parse(data['deadline'] as String)
          : null,
      priority: data['priority'] as String?,
      strategy: data['strategy'] as String?,
    );
  }

  /// Update a goal.
  Future<Goal> updateGoal(
    String id,
    String userId,
    Map<String, dynamic> data,
  ) async {
    return _repository.update(id, userId, data);
  }

  /// Delete a goal.
  Future<void> deleteGoal(String id, String userId) async {
    return _repository.delete(id, userId);
  }

  /// Generate strategy suggestion based on goal.
  String _generateStrategy(Goal goal) {
    final remaining = goal.targetAmount - goal.currentAmount;
    if (remaining <= 0) return 'Parabéns! Meta atingida! 🎉';

    if (goal.deadline != null) {
      final monthsLeft = goal.deadline!.difference(DateTime.now()).inDays / 30;
      if (monthsLeft > 0) {
        final monthlyNeeded = remaining / monthsLeft;
        return 'Para atingir sua meta, você precisa aportar aproximadamente '
            'R\$ ${monthlyNeeded.toStringAsFixed(2)} por mês.';
      } else {
        return 'O prazo da meta já passou. Considere estender o prazo.';
      }
    }

    return 'Defina um prazo para acompanhar melhor o progresso da meta.';
  }
}
