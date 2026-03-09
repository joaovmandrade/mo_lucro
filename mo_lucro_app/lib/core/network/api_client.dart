import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../storage/token_storage.dart';

/// API client configured with auth interceptor, base URL, and error handling.
class ApiClient {
  /// Auto-detect base URL based on platform.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    // Android emulator uses 10.0.2.2 to reach host machine
    return 'http://10.0.2.2:8080';
  }

  static Dio? _instance;

  static Dio get instance {
    _instance ??= Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ))
      ..interceptors.add(AuthInterceptor())
      ..interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => print('[API] $log'),
      ));
    return _instance!;
  }
}

/// Interceptor that adds JWT token and handles refresh.
/// Uses cross-platform TokenStorage (secure on mobile, Hive on web).
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    final token = await TokenStorage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await TokenStorage.read('refresh_token');
        if (refreshToken != null) {
          final response = await Dio().post(
            '${ApiClient.baseUrl}/api/v1/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final data = response.data['data'];
            await TokenStorage.write('access_token', data['accessToken']);
            await TokenStorage.write('refresh_token', data['refreshToken']);

            // Retry original request
            err.requestOptions.headers['Authorization'] =
                'Bearer ${data['accessToken']}';
            final retryResponse = await Dio().fetch(err.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
      } catch (_) {
        // Refresh failed — user needs to re-login
      }
    }
    handler.next(err);
  }
}

/// API endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const register = '/api/v1/auth/register';
  static const login = '/api/v1/auth/login';
  static const refresh = '/api/v1/auth/refresh';
  static const logout = '/api/v1/auth/logout';

  // Dashboard
  static const dashboard = '/api/v1/dashboard';

  // Investments
  static const investments = '/api/v1/investments';
  static String investmentById(String id) => '/api/v1/investments/$id';
  static const contributions = '/api/v1/contributions';

  // Expenses
  static const expenses = '/api/v1/expenses';
  static String expenseById(String id) => '/api/v1/expenses/$id';
  static const expenseSummary = '/api/v1/expenses/summary';

  // Goals
  static const goals = '/api/v1/goals';
  static String goalById(String id) => '/api/v1/goals/$id';

  // Calculators
  static const compoundInterest = '/api/v1/calculators/compound_interest';
  static const cdbCompare = '/api/v1/calculators/cdb_compare';
  static const incomeTax = '/api/v1/calculators/income_tax';

  // Reports
  static const riskAnalysis = '/api/v1/reports/risk';
  static const diversification = '/api/v1/reports/diversification';
  static const maturities = '/api/v1/reports/maturities';

  // Profile
  static const profileQuiz = '/api/v1/profile/quiz';
  static const profileResult = '/api/v1/profile/result';
  static const recommendations = '/api/v1/profile/recommendations';
}
