import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/goal_model.dart';

class GoalService {
  final _db = Supabase.instance.client;

  String get _userId {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    return user.id;
  }

  Future<List<GoalModel>> getGoals() async {
    final res = await _db
        .from('goals')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((row) => GoalModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addGoal({
    required String title,
    required double targetValue,
    double currentValue = 0,
    DateTime? deadline,
  }) async {
    final payload = <String, dynamic>{
      'user_id': _userId,
      'name': title,
      'target': targetValue,
      'current': currentValue,
    };
    if (deadline != null) {
      payload['deadline'] = deadline.toIso8601String();
    }
    await _db.from('goals').insert(payload);
  }

  Future<void> updateGoalProgress(String id, double currentValue) async {
    await _db
        .from('goals')
        .update({'current': currentValue}).eq('id', id);
  }

  Future<void> deleteGoal(String id) async {
    await _db.from('goals').delete().eq('id', id);
  }
}
