import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for authentication API calls.
class AuthDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? birthDate,
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      'name': name,
      'email': email,
      'password': password,
      if (birthDate != null) 'birthDate': birthDate,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await _dio.post(ApiEndpoints.refresh, data: {
      'refreshToken': token,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }
}
