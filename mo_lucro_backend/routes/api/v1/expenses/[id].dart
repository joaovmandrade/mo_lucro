import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/expense_service.dart';

/// GET /api/v1/expenses/:id
/// PUT /api/v1/expenses/:id
/// DELETE /api/v1/expenses/:id
Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<String>();
  final service = context.read<ExpenseService>();

  switch (context.request.method) {
    case HttpMethod.put:
      try {
        final body = await context.request.bodyAsJson();
        final expense = await service.updateExpense(id, userId, body);
        return JsonResponse.ok(expense.toJson());
      } catch (e) {
        return JsonResponse.error(e.toString(), statusCode: 422);
      }
    case HttpMethod.delete:
      try {
        await service.deleteExpense(id, userId);
        return JsonResponse.ok(null, message: 'Lançamento excluído');
      } catch (e) {
        return JsonResponse.notFound();
      }
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
