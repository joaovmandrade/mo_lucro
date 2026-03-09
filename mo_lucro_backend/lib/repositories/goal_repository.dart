import '../core/database.dart';
import '../core/exceptions.dart';
import '../models/goal.dart';

/// Repository for financial goals data access.
class GoalRepository {
  /// Get all goals for a user.
  Future<List<Goal>> findByUserId(String userId) async {
    final result = await Database.query(
      '''
      SELECT * FROM goals
      WHERE user_id = @userId::uuid
      ORDER BY priority DESC, deadline ASC NULLS LAST
      ''',
      parameters: {'userId': userId},
    );
    return result.map((r) => Goal.fromRow(r.toColumnMap())).toList();
  }

  /// Find goal by ID.
  Future<Goal?> findById(String id, String userId) async {
    final result = await Database.query(
      'SELECT * FROM goals WHERE id = @id::uuid AND user_id = @userId::uuid',
      parameters: {'id': id, 'userId': userId},
    );
    if (result.isEmpty) return null;
    return Goal.fromRow(result.first.toColumnMap());
  }

  /// Create a new goal.
  Future<Goal> create({
    required String userId,
    required String name,
    required String type,
    required double targetAmount,
    double currentAmount = 0,
    DateTime? deadline,
    String? priority,
    String? strategy,
  }) async {
    final result = await Database.query(
      '''
      INSERT INTO goals (
        user_id, name, type, target_amount, current_amount,
        deadline, priority, strategy
      ) VALUES (
        @userId::uuid, @name, @type::goal_type, @targetAmount, @currentAmount,
        @deadline, @priority::goal_priority, @strategy
      ) RETURNING *
      ''',
      parameters: {
        'userId': userId,
        'name': name,
        'type': type,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline?.toIso8601String().split('T').first,
        'priority': priority ?? 'MEDIA',
        'strategy': strategy,
      },
    );
    return Goal.fromRow(result.first.toColumnMap());
  }

  /// Update a goal.
  Future<Goal> update(String id, String userId, Map<String, dynamic> fields) async {
    final setClauses = <String>[];
    final params = <String, dynamic>{'id': id, 'userId': userId};

    final fieldMap = {
      'name': 'name = @name',
      'type': 'type = @type::goal_type',
      'targetAmount': 'target_amount = @targetAmount',
      'currentAmount': 'current_amount = @currentAmount',
      'deadline': 'deadline = @deadline',
      'priority': 'priority = @priority::goal_priority',
      'strategy': 'strategy = @strategy',
    };

    for (final entry in fieldMap.entries) {
      if (fields.containsKey(entry.key)) {
        setClauses.add(entry.value);
        params[entry.key] = fields[entry.key];
      }
    }

    // Check if goal is completed
    if (fields.containsKey('currentAmount') && fields.containsKey('targetAmount')) {
      final current = (fields['currentAmount'] as num).toDouble();
      final target = (fields['targetAmount'] as num).toDouble();
      if (current >= target) {
        setClauses.add('is_completed = TRUE');
        setClauses.add('completed_at = CURRENT_TIMESTAMP');
      }
    }

    if (setClauses.isEmpty) {
      throw const ValidationException('Nenhum campo para atualizar');
    }

    setClauses.add('updated_at = CURRENT_TIMESTAMP');

    final result = await Database.query(
      '''
      UPDATE goals SET ${setClauses.join(', ')}
      WHERE id = @id::uuid AND user_id = @userId::uuid
      RETURNING *
      ''',
      parameters: params,
    );

    if (result.isEmpty) {
      throw const NotFoundException('Meta não encontrada');
    }
    return Goal.fromRow(result.first.toColumnMap());
  }

  /// Delete a goal.
  Future<void> delete(String id, String userId) async {
    final result = await Database.query(
      'DELETE FROM goals WHERE id = @id::uuid AND user_id = @userId::uuid RETURNING id',
      parameters: {'id': id, 'userId': userId},
    );
    if (result.isEmpty) {
      throw const NotFoundException('Meta não encontrada');
    }
  }
}
