import 'package:dart_frog/dart_frog.dart';

/// GET /health — Health check endpoint.
Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'status': 'ok',
      'service': 'Mo Lucro API',
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
