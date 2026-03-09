import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/dashboard_service.dart';

/// GET /api/v1/dashboard — Get dashboard data
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final userId = context.read<String>();
    final service = context.read<DashboardService>();
    final data = await service.getDashboardData(userId);
    return JsonResponse.ok(data.toJson());
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}
