import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';
import '../utils/api_config.dart';

class AuthServiceException implements Exception {
  final String message;
  final int? statusCode;

  const AuthServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Handles authentication requests, token persistence, and protected API access.
class AuthService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() => TokenStorage.read(_accessTokenKey);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.apiV1BaseUrl}/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final payload = _extractAuthPayload(response);
    await _persistSession(payload);
    return payload;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.apiV1BaseUrl}/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final payload = _extractAuthPayload(response);
    await _persistSession(payload);
    return payload;
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await TokenStorage.read(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthServiceException(
        'Sessao expirada. Faca login novamente.',
        statusCode: 401,
      );
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.apiV1BaseUrl}/auth/refresh'),
      headers: _jsonHeaders,
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final payload = _extractAuthPayload(response);
    await _persistSession(payload);
    return payload;
  }

  Future<Map<String, dynamic>> fetchProtectedIndex() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw const AuthServiceException(
        'Sessao expirada. Faca login novamente.',
        statusCode: 401,
      );
    }

    final response = await _client.get(
      Uri.parse(ApiConfig.apiV1BaseUrl),
      headers: {
        ..._jsonHeaders,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      await logout();
      throw AuthServiceException(
        _extractErrorMessage(response) ?? 'Sessao expirada. Faca login novamente.',
        statusCode: 401,
      );
    }

    if (!_isSuccess(response.statusCode)) {
      throw AuthServiceException(
        _extractErrorMessage(response) ?? 'Nao foi possivel carregar a area protegida.',
        statusCode: response.statusCode,
      );
    }

    return _decodeMap(response);
  }

  Future<void> logout() => TokenStorage.deleteAll();

  Future<void> _persistSession(Map<String, dynamic> payload) async {
    final accessToken = _extractToken(payload);
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthServiceException('Token nao retornado pelo servidor.');
    }

    await TokenStorage.write(_accessTokenKey, accessToken);

    final refreshToken = payload['refreshToken'] as String?;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await TokenStorage.write(_refreshTokenKey, refreshToken);
    } else {
      await TokenStorage.delete(_refreshTokenKey);
    }
  }

  Map<String, dynamic> _extractAuthPayload(http.Response response) {
    final body = _decodeMap(response);

    if (!_isSuccess(response.statusCode)) {
      throw AuthServiceException(
        _extractErrorFromBody(body) ?? 'Falha ao autenticar.',
        statusCode: response.statusCode,
      );
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return body;
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.body.isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw AuthServiceException(
      'Resposta inesperada do servidor.',
      statusCode: response.statusCode,
    );
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final token = payload['token'] ?? payload['accessToken'];
    return token is String ? token : null;
  }

  String? _extractErrorMessage(http.Response response) {
    try {
      final body = _decodeMap(response);
      return _extractErrorFromBody(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractErrorFromBody(Map<String, dynamic> body) {
    final candidates = [
      body['error'],
      body['message'],
      body['detail'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate;
      }
    }

    return null;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, String> get _jsonHeaders => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
