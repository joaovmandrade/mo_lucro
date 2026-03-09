import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/calculator_service.dart';

/// POST /api/v1/calculators/compound_interest — Simulate compound interest
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<CalculatorService>();

    final result = service.simulateCompoundInterest(
      initialAmount: (body['initialAmount'] as num?)?.toDouble() ?? 0,
      monthlyContribution: (body['monthlyContribution'] as num?)?.toDouble() ?? 0,
      months: body['months'] as int? ?? 12,
      annualRate: (body['annualRate'] as num?)?.toDouble() ?? 10,
      inflationRate: (body['inflationRate'] as num?)?.toDouble(),
    );

    return JsonResponse.ok(result.toJson());
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
