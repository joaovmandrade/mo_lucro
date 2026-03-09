import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';

/// POST /api/v1/auth/logout
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // In a stateless JWT system, logout is handled client-side
  // by removing the stored tokens. Server-side we just acknowledge.
  return JsonResponse.ok(null, message: 'Logout realizado com sucesso');
}
