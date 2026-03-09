import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/profile_quiz_service.dart';

/// GET /api/v1/profile/recommendations
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final userId = context.read<String>();
    final service = context.read<ProfileQuizService>();
    final recommendations = await service.getRecommendations(userId);
    return JsonResponse.ok(recommendations);
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}
