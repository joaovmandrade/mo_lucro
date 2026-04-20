import 'package:dart_frog/dart_frog.dart';

/// GET / - Backend entrypoint with quick links.
Response onRequest(RequestContext _) {
  return Response.json(
    body: {
      'service': 'Mo Lucro Backend',
      'status': 'ok',
      'version': '1.0.0',
      'endpoints': {
        'health': '/health',
        'api': '/api/v1',
      },
    },
  );
}
