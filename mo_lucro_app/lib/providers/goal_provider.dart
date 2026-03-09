import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/goal_datasource.dart';

class GoalState {
  final bool isLoading;
  final List<Map<String, dynamic>> goals;
  final String? error;

  const GoalState({this.isLoading = false, this.goals = const [], this.error});

  GoalState copyWith({bool? isLoading, List<Map<String, dynamic>>? goals, String? error}) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      error: error,
    );
  }
}

class GoalNotifier extends StateNotifier<GoalState> {
  final GoalDataSource _dataSource;

  GoalNotifier(this._dataSource) : super(const GoalState());

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.getGoals();
      final goals = result.map((g) => g as Map<String, dynamic>).toList();
      state = state.copyWith(isLoading: false, goals: goals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar metas');
    }
  }

  Future<bool> createGoal(Map<String, dynamic> data) async {
    try {
      await _dataSource.createGoal(data);
      await loadGoals();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateGoal(String id, Map<String, dynamic> data) async {
    try {
      await _dataSource.updateGoal(id, data);
      await loadGoals();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteGoal(String id) async {
    try {
      await _dataSource.deleteGoal(id);
      await loadGoals();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final goalDataSourceProvider = Provider((_) => GoalDataSource());

final goalProvider = StateNotifierProvider<GoalNotifier, GoalState>((ref) {
  return GoalNotifier(ref.read(goalDataSourceProvider));
});
