import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/auth_service.dart';

/// Auth state model.
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth state notifier backed by the real AuthService.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuth() async {
    final isAuthenticated = await _authService.hasActiveSession();
    state = state.copyWith(isAuthenticated: isAuthenticated);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: result['user'] as Map<String, dynamic>?,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: result['user'] as Map<String, dynamic>?,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    if (e is AuthServiceException) {
      return e.message;
    }

    final message = e.toString().replaceFirst('Exception: ', '').trim();
    if (message.contains('incorretos')) return 'Email ou senha incorretos';
    if (message.contains('ja cadastrado')) return 'Email ja cadastrado';
    if (message.contains('cadastro')) return message;
    if (message.contains('invalido')) return message;
    if (message.isNotEmpty) return message;
    return 'Erro ao conectar com o servidor.';
  }
}

final authServiceProvider = Provider((_) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});
