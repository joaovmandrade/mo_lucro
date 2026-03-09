import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/investment_service.dart';

/// GET /api/v1/investments/:id — Investment details
/// PUT /api/v1/investments/:id — Update investment
/// DELETE /api/v1/investments/:id — Delete investment
Future<Response> onRequest(RequestContext context, String id) async {
  final userId = context.read<String>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getDetails(context, id, userId);
    case HttpMethod.put:
      return _update(context, id, userId);
    case HttpMethod.delete:
      return _delete(context, id, userId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getDetails(
  RequestContext context, String id, String userId,
) async {
  try {
    final service = context.read<InvestmentService>();
    final result = await service.getInvestmentDetails(id, userId);
    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.notFound('Investimento não encontrado');
  }
}

Future<Response> _update(
  RequestContext context, String id, String userId,
) async {
  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<InvestmentService>();
    final investment = await service.updateInvestment(id, userId, body);
    return JsonResponse.ok(investment.toJson());
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}

Future<Response> _delete(
  RequestContext context, String id, String userId,
) async {
  try {
    final service = context.read<InvestmentService>();
    await service.deleteInvestment(id, userId);
    return JsonResponse.ok(null, message: 'Investimento excluído com sucesso');
  } catch (e) {
    return JsonResponse.notFound('Investimento não encontrado');
  }
}
