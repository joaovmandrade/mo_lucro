import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/repositories/market_cache_repository.dart';
import '../../../../lib/services/economic_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final cacheRepo = MarketCacheRepository();
    final service = EconomicService(cacheRepo);

    final data = await service.getSelicRate();
    return Response.json(body: data);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
