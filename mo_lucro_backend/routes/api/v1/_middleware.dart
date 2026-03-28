import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/jwt_helper.dart';
import 'package:mo_lucro_backend/core/extensions.dart';

/// Auth middleware for /api/v1/* routes.
/// Validates JWT and injects userId into the request context.
Handler middleware(Handler handler) {
  return (context) async {
    final path = context.request.uri.path;

    // Skip auth for public routes and market data routes
    if (path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/market/') ||
        path.contains('/economy/') ||
        path.contains('/ai/')) {
      return handler(context);
    }

    // Extract token from Authorization header
    final authHeader = context.request.headers['Authorization'] ?? '';
    if (!authHeader.startsWith('Bearer ')) {
      return JsonResponse.unauthorized('Token não fornecido');
    }

    final token = authHeader.substring(7);
    final userId = JwtHelper.getUserIdFromToken(token);

    if (userId == null) {
      return JsonResponse.unauthorized('Token inválido ou expirado');
    }

    // Add userId to request headers for downstream use
    // We use a custom header approach since dart_frog context is immutable
    final updatedRequest = context.request.copyWith(
      headers: {
        ...context.request.headers,
        'X-User-Id': userId,
      },
    );

    // Create new context with the user ID
    final updatedContext = context.provide<String>(() => userId);
    return handler(updatedContext);
  };
}
