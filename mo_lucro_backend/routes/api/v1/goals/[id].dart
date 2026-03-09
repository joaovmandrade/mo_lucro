import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/goal_service.dart';

/// GET/PUT/DELETE /api/v1/goals/:id
Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<String>();
  final service = context.read<GoalService>();

  switch (context.request.method) {
    case HttpMethod.get:
      try {
        final goal = await service.getGoalDetails(id, userId);
        return JsonResponse.ok(goal);
      } catch (e) {
        return JsonResponse.notFound();
      }
    case HttpMethod.put:
      try {
        final body = await context.request.bodyAsJson();
        final goal = await service.updateGoal(id, userId, body);
        return JsonResponse.ok(goal.toJson());
      } catch (e) {
        return JsonResponse.error(e.toString(), statusCode: 422);
      }
    case HttpMethod.delete:
      try {
        await service.deleteGoal(id, userId);
        return JsonResponse.ok(null, message: 'Meta excluída');
      } catch (e) {
        return JsonResponse.notFound();
      }
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
