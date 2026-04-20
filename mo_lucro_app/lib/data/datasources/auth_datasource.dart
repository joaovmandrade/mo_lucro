import '../../core/services/auth_service.dart';

/// Backwards-compatible datasource that delegates to the real AuthService.
class AuthDataSource {
  final AuthService _authService;

  AuthDataSource({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? birthDate,
  }) {
    return _authService.register(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _authService.login(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> refreshToken(String token) {
    return _authService.refreshToken();
  }

  Future<void> logout() => _authService.logout();
}
