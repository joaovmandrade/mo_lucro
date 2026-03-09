import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/auth_service.dart';

/// POST /api/v1/auth/refresh
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final refreshToken = body['refreshToken'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      return JsonResponse.badRequest('Refresh token é obrigatório');
    }

    final authService = context.read<AuthService>();
    final result = await authService.refreshToken(refreshToken);

    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.unauthorized('Token inválido ou expirado');
  }
}
