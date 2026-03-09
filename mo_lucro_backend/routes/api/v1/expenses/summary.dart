import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/expense_service.dart';

/// GET /api/v1/expenses/summary — Monthly expense summary
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final userId = context.read<String>();
    final service = context.read<ExpenseService>();
    final year = context.request.queryParamAsInt('year');
    final month = context.request.queryParamAsInt('month');

    final summary = await service.getMonthlySummary(
      userId,
      year: year,
      month: month,
    );

    return JsonResponse.ok(summary);
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}
