import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// Extension methods for Request and Response objects.
extension RequestExtension on Request {
  /// Parse request body as JSON Map.
  Future<Map<String, dynamic>> bodyAsJson() async {
    final body = await this.body();
    if (body.isEmpty) return {};
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Get the authenticated user ID from the request context.
  String get userId {
    final id = headers['X-User-Id'];
    if (id == null) throw StateError('User ID not found in request context');
    return id;
  }

  /// Get query parameter as int.
  int? queryParamAsInt(String key) {
    final value = uri.queryParameters[key];
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Get query parameter with default.
  String queryParam(String key, [String defaultValue = '']) {
    return uri.queryParameters[key] ?? defaultValue;
  }
}

/// Helper to create JSON responses.
class JsonResponse {
  /// Create a success response with data.
  static Response ok(dynamic data, {String? message}) {
    return Response.json(
      body: {
        'success': true,
        if (message != null) 'message': message,
        'data': data,
      },
    );
  }

  /// Create a created response (201).
  static Response created(dynamic data, {String? message}) {
    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'success': true,
        'message': message ?? 'Criado com sucesso',
        'data': data,
      },
    );
  }

  /// Create a paginated response.
  static Response paginated({
    required List<dynamic> data,
    required int total,
    required int page,
    required int limit,
  }) {
    return Response.json(
      body: {
        'success': true,
        'data': data,
        'pagination': {
          'total': total,
          'page': page,
          'limit': limit,
          'totalPages': (total / limit).ceil(),
        },
      },
    );
  }

  /// Create an error response.
  static Response error(
    String message, {
    int statusCode = 500,
    Map<String, dynamic>? errors,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': false,
        'error': message,
        if (errors != null) 'errors': errors,
      },
    );
  }

  /// 400 - Bad Request.
  static Response badRequest(String message) =>
      error(message, statusCode: 400);

  /// 401 - Unauthorized.
  static Response unauthorized([String message = 'Não autorizado']) =>
      error(message, statusCode: 401);

  /// 404 - Not Found.
  static Response notFound([String message = 'Recurso não encontrado']) =>
      error(message, statusCode: 404);

  /// 422 - Validation Error.
  static Response validationError(
    String message, {
    Map<String, dynamic>? errors,
  }) =>
      error(message, statusCode: 422, errors: errors);
}
