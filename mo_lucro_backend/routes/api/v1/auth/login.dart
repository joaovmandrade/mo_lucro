import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/auth_service.dart';

/// POST /api/v1/auth/login
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final authService = context.read<AuthService>();

    final result = await authService.login(
      email: body['email'] as String? ?? '',
      password: body['password'] as String? ?? '',
    );

    return JsonResponse.ok(result, message: 'Login realizado com sucesso');
  } catch (e) {
    if (e.toString().contains('incorretos')) {
      return JsonResponse.unauthorized('Email ou senha incorretos');
    }
    return JsonResponse.error(e.toString());
  }
}
