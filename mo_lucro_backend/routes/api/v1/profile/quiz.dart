import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/profile_quiz_service.dart';

/// POST /api/v1/profile/quiz — Submit quiz answers
/// GET /api/v1/profile/quiz — Get quiz questions
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      final service = context.read<ProfileQuizService>();
      return JsonResponse.ok(service.getQuestions());
    case HttpMethod.post:
      try {
        final userId = context.read<String>();
        final body = await context.request.bodyAsJson();
        final answers = (body['answers'] as List?)
            ?.map((a) => a as Map<String, dynamic>)
            .toList() ?? [];

        final service = context.read<ProfileQuizService>();
        final result = await service.processQuiz(userId, answers);
        return JsonResponse.ok(result);
      } catch (e) {
        return JsonResponse.error(e.toString(), statusCode: 422);
      }
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
