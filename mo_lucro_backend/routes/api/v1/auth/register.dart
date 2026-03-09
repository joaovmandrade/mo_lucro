import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/exceptions.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/auth_service.dart';

/// POST /api/v1/auth/register
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final authService = context.read<AuthService>();

    final result = await authService.register(
      name: body['name'] as String? ?? '',
      email: body['email'] as String? ?? '',
      password: body['password'] as String? ?? '',
      birthDate: body['birthDate'] != null
          ? DateTime.parse(body['birthDate'] as String)
          : null,
      profileType: body['profileType'] as String?,
      mainGoal: body['mainGoal'] as String?,
    );

    return JsonResponse.created(result, message: 'Cadastro realizado com sucesso');
  } on FormatException {
    return JsonResponse.badRequest('Dados inválidos');
  } on ValidationException catch (e) {
    return JsonResponse.validationError(e.message);
  } on ConflictException catch (e) {
    return JsonResponse.error(e.message, statusCode: 409);
  } on AppException catch (e) {
    return JsonResponse.error(e.message, statusCode: e.statusCode);
  } catch (e, stackTrace) {
    print('[REGISTER ERROR] $e');
    print('[REGISTER STACK] $stackTrace');
    return JsonResponse.error('Erro interno do servidor', statusCode: 500);
  }
}
