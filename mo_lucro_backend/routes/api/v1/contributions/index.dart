import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/extensions.dart';
import 'package:mo_lucro_backend/services/investment_service.dart';

/// POST /api/v1/contributions — Add contribution to an investment
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final userId = context.read<String>();
    final body = await context.request.bodyAsJson();
    final service = context.read<InvestmentService>();

    final contribution = await service.addContribution(userId, body);
    return JsonResponse.created(
      contribution.toJson(),
      message: 'Aporte registrado com sucesso',
    );
  } catch (e) {
    return JsonResponse.error(e.toString(), statusCode: 422);
  }
}
