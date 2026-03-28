import 'dart:async';

/// Mock offline data source for authentication.
class AuthDataSource {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? birthDate,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
    return {
      'accessToken': 'mock_offline_access_token',
      'refreshToken': 'mock_offline_refresh_token',
      'user': {
        'id': 'mock_user_123',
        'name': name,
        'email': email,
        'birthDate': birthDate,
      }
    };
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'error@test.com') {
      throw Exception('Email ou senha incorretos');
    }
    return {
      'accessToken': 'mock_offline_access_token',
      'refreshToken': 'mock_offline_refresh_token',
      'user': {
        'id': 'mock_user_123',
        'name': 'Usuário Mock',
        'email': email,
      }
    };
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'accessToken': 'mock_offline_access_token_v2',
      'refreshToken': 'mock_offline_refresh_token_v2',
    };
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
