import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/goal_service.dart';

/// GET /api/v1/goals — List goals
/// POST /api/v1/goals — Create goal
Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<String>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        final service = context.read<GoalService>();
        final goals = await service.getGoals(userId);
        return JsonResponse.ok(goals);
      } catch (e) {
        return JsonResponse.error(e.toString());
      }
    case HttpMethod.post:
      try {
        final body = await context.request.bodyAsJson();
        final service = context.read<GoalService>();
        final goal = await service.createGoal(userId, body);
        return JsonResponse.created(goal.toJson());
      } catch (e) {
        return JsonResponse.error(e.toString(), statusCode: 422);
      }
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
