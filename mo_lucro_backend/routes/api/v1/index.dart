import 'package:dart_frog/dart_frog.dart';

/// GET /api/v1 - API index for quick discovery.
Response onRequest(RequestContext _) {
  return Response.json(
    body: {
      'service': 'Mo Lucro API v1',
      'status': 'ok',
      'publicEndpoints': [
        '/health',
        '/api/v1/auth/login',
        '/api/v1/auth/register',
        '/api/v1/auth/refresh',
        '/api/v1/news',
        '/api/v1/ai/categorize',
        '/api/v1/economy/selic',
        '/api/v1/market/stock/:symbol',
        '/api/v1/market/crypto/:id',
        '/api/v1/market/history/:symbol',
      ],
      'authenticatedEndpoints': [
        '/api/v1/dashboard',
        '/api/v1/investments',
        '/api/v1/expenses',
        '/api/v1/goals',
        '/api/v1/profile/result',
        '/api/v1/reports/risk',
      ],
    },
  );
}
