import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/token_storage.dart';
import '../../data/datasources/auth_datasource.dart';

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

/// Auth state notifier using cross-platform TokenStorage.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource _dataSource;

  AuthNotifier(this._dataSource) : super(const AuthState());

  /// Check if user has stored tokens (auto-login).
  Future<void> checkAuth() async {
    final token = await TokenStorage.read('access_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  /// Login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.login(email: email, password: password);
      await TokenStorage.write('access_token', result['accessToken']);
      await TokenStorage.write('refresh_token', result['refreshToken']);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: result['user'] as Map<String, dynamic>?,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// Register a new user.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dataSource.register(
        name: name, email: email, password: password,
      );
      await TokenStorage.write('access_token', result['accessToken']);
      await TokenStorage.write('refresh_token', result['refreshToken']);
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: result['user'] as Map<String, dynamic>?,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    try {
      await _dataSource.logout();
    } catch (_) {}
    await TokenStorage.deleteAll();
    state = const AuthState();
  }

  String _parseError(dynamic e) {
    if (e.toString().contains('incorretos')) return 'Email ou senha incorretos';
    if (e.toString().contains('já cadastrado')) return 'Email já cadastrado';
    if (e.toString().contains('Validação')) return 'Dados inválidos';
    return 'Erro ao conectar com o servidor';
  }
}

/// Providers
final authDataSourceProvider = Provider((_) => AuthDataSource());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authDataSourceProvider));
});
