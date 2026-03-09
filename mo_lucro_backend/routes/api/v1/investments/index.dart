import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/investment_service.dart';

/// GET /api/v1/investments — List investments
/// POST /api/v1/investments — Create investment
Future<Response> onRequest(RequestContext context) async {
  final userId = context.read<String>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getInvestments(context, userId);
    case HttpMethod.post:
      return _createInvestment(context, userId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getInvestments(RequestContext context, String userId) async {
  try {
    final service = context.read<InvestmentService>();
    final type = context.request.queryParam('type');
    final page = context.request.queryParamAsInt('page') ?? 1;
    final limit = context.request.queryParamAsInt('limit') ?? 20;

    final result = await service.getInvestments(
      userId,
      type: type.isNotEmpty ? type : null,
      page: page,
      limit: limit,
    );

    return JsonResponse.ok(result);
  } catch (e) {
    return JsonResponse.error(e.toString());
  }
}

Future<Response> _createInvestment(RequestContext context, String userId) async {
  try {
    final body = await context.request.bodyAsJson();
    final service = context.read<InvestmentService>();
    final investment = await service.createInvestment(userId, body);
    return JsonResponse.created(investment.toJson());
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
