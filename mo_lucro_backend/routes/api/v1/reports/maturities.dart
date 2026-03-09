import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/risk_analyzer_service.dart';

/// GET /api/v1/reports/maturities
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final userId = context.read<String>();
    final service = context.read<RiskAnalyzerService>();
    final result = await service.getMaturities(userId);
    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}
