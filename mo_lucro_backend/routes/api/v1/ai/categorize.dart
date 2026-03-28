import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/ai_categorization_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final description = body['description'] as String?;

    if (description == null || description.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing description'},
      );
    }

    final service = AiCategorizationService();
    final result = await service.categorizeExpense(description);
    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
