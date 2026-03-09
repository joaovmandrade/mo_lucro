import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/expense_service.dart';

/// GET /api/v1/expenses — List expenses
/// POST /api/v1/expenses — Create expense
Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<String>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getExpenses(context, userId);
    case HttpMethod.post:
      return _createExpense(context, userId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getExpenses(RequestContext context, String userId) async {
  try {
    final service = context.read<ExpenseService>();
    final type = context.request.queryParam('type');
    final page = context.request.queryParamAsInt('page') ?? 1;
    final limit = context.request.queryParamAsInt('limit') ?? 20;
    final startDate = context.request.queryParam('startDate');
    final endDate = context.request.queryParam('endDate');

    final result = await service.getExpenses(
      userId,
      type: type.isNotEmpty ? type : null,
      startDate: startDate.isNotEmpty ? DateTime.parse(startDate) : null,
      endDate: endDate.isNotEmpty ? DateTime.parse(endDate) : null,
      page: page,
      limit: limit,
    );

    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}

Future<Response> _createExpense(RequestContext context, String userId) async {
  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<ExpenseService>();
    final expense = await service.createExpense(userId, body);
    return JsonResponse.created(expense.toJson());
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
