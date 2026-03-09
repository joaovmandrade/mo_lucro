import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/calculator_service.dart';

/// POST /api/v1/calculators/income_tax — Estimate income tax
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<CalculatorService>();

    final result = service.estimateIncomeTax(
      investedAmount: (body['investedAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (body['currentAmount'] as num?)?.toDouble() ?? 0,
      holdingDays: body['holdingDays'] as int? ?? 365,
    );

    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
