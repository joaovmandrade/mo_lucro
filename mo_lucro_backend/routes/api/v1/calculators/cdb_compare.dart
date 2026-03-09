import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/calculator_service.dart';

/// POST /api/v1/calculators/cdb_compare — Compare CDB options
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<CalculatorService>();

    final options = (body['options'] as List?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];

    if (options.isEmpty) {
      return JsonResponse.badRequest('Informe pelo menos uma opção de CDB');
    }

    final results = service.compareCDBs(options);
    return JsonResponse.ok({
      'comparison': results,
      'disclaimer': '⚠️ Simulação educativa. Valores reais podem variar.',
    });
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
