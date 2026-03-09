import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_datasource.dart';

class ProfileState {
  final bool isLoading;
  final List<Map<String, dynamic>> questions;
  final Map<String, dynamic>? result;
  final List<Map<String, dynamic>> recommendations;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.questions = const [],
    this.result,
    this.recommendations = const [],
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? questions,
    Map<String, dynamic>? result,
    List<Map<String, dynamic>>? recommendations,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      result: result ?? this.result,
      recommendations: recommendations ?? this.recommendations,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileDataSource _dataSource;

  ProfileNotifier(this._dataSource) : super(const ProfileState());

  Future<void> loadQuestions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getQuizQuestions();
      final questions = data.map((q) => q as Map<String, dynamic>).toList();
      state = state.copyWith(isLoading: false, questions: questions);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar perguntas');
    }
  }

  Future<bool> submitQuiz(List<Map<String, dynamic>> answers) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.submitQuiz(answers);
      state = state.copyWith(isLoading: false, result: result);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao enviar respostas');
      return false;
    }
  }

  Future<void> loadResult() async {
    try {
      final result = await _dataSource.getResult();
      if (result != null) {
        state = state.copyWith(result: result);
      }
    } catch (_) {}
  }

  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _dataSource.getRecommendations();
      final items = data.map((r) => r as Map<String, dynamic>).toList();
      state = state.copyWith(isLoading: false, recommendations: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar recomendações');
    }
  }
}

final profileDataSourceProvider = Provider((_) => ProfileDataSource());

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(profileDataSourceProvider));
});
