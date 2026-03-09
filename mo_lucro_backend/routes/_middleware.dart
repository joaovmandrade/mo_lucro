import 'package:dart_frog/dart_frog.dart';
import 'package:mo_lucro_backend/core/config.dart';
import 'package:mo_lucro_backend/core/database.dart';
import 'package:mo_lucro_backend/repositories/user_repository.dart';
import 'package:mo_lucro_backend/repositories/investment_repository.dart';
import 'package:mo_lucro_backend/repositories/expense_repository.dart';
import 'package:mo_lucro_backend/repositories/goal_repository.dart';
import 'package:mo_lucro_backend/services/auth_service.dart';
import 'package:mo_lucro_backend/services/investment_service.dart';
import 'package:mo_lucro_backend/services/expense_service.dart';
import 'package:mo_lucro_backend/services/goal_service.dart';
import 'package:mo_lucro_backend/services/dashboard_service.dart';
import 'package:mo_lucro_backend/services/calculator_service.dart';
import 'package:mo_lucro_backend/services/risk_analyzer_service.dart';
import 'package:mo_lucro_backend/services/profile_quiz_service.dart';

/// Global middleware — runs on every request.
/// Sets up CORS, logging, and dependency injection.
Handler middleware(Handler handler) {
  // Initialize config on first request
  AppConfig.initialize();

  return handler
      .use(_corsMiddleware())
      .use(_loggingMiddleware())
      .use(_dependencyInjection());
}

/// CORS middleware for cross-origin requests.
Middleware _corsMiddleware() {
  return (handler) {
    return (context) async {
      // Handle preflight OPTIONS requests
      if (context.request.method == HttpMethod.options) {
        return Response(
          statusCode: 204,
          headers: _corsHeaders,
        );
      }

      final response = await handler(context);
      return response.copyWith(
        headers: {...response.headers, ..._corsHeaders},
      );
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

/// Logging middleware.
Middleware _loggingMiddleware() {
  return (handler) {
    return (context) async {
      final stopwatch = Stopwatch()..start();
      final method = context.request.method.value;
      final path = context.request.uri.path;

      print('[${DateTime.now().toIso8601String()}] $method $path');

      try {
        final response = await handler(context);
        stopwatch.stop();
        print('[${DateTime.now().toIso8601String()}] $method $path → '
            '${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
        return response;
      } catch (e) {
        stopwatch.stop();
        print('[${DateTime.now().toIso8601String()}] $method $path → '
            'ERROR (${stopwatch.elapsedMilliseconds}ms): $e');
        rethrow;
      }
    };
  };
}

/// Dependency injection middleware.
Middleware _dependencyInjection() {
  // Create repository instances
  final userRepo = UserRepository();
  final investmentRepo = InvestmentRepository();
  final expenseRepo = ExpenseRepository();
  final goalRepo = GoalRepository();

  // Create service instances
  final authService = AuthService(userRepo);
  final investmentService = InvestmentService(investmentRepo);
  final expenseService = ExpenseService(expenseRepo);
  final goalService = GoalService(goalRepo);
  final dashboardService = DashboardService(investmentRepo, expenseRepo, goalRepo);
  final calculatorService = CalculatorService();
  final riskAnalyzerService = RiskAnalyzerService(investmentRepo);
  final profileQuizService = ProfileQuizService();

  return (handler) {
    return handler
        .use(provider<AuthService>((_) => authService))
        .use(provider<InvestmentService>((_) => investmentService))
        .use(provider<ExpenseService>((_) => expenseService))
        .use(provider<GoalService>((_) => goalService))
        .use(provider<DashboardService>((_) => dashboardService))
        .use(provider<CalculatorService>((_) => calculatorService))
        .use(provider<RiskAnalyzerService>((_) => riskAnalyzerService))
        .use(provider<ProfileQuizService>((_) => profileQuizService));
  };
}
