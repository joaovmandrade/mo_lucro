// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/health.dart' as health;
import '../routes/api/v1/reports/risk.dart' as api_v1_reports_risk;
import '../routes/api/v1/reports/maturities.dart' as api_v1_reports_maturities;
import '../routes/api/v1/reports/diversification.dart' as api_v1_reports_diversification;
import '../routes/api/v1/profile/result.dart' as api_v1_profile_result;
import '../routes/api/v1/profile/recommendations.dart' as api_v1_profile_recommendations;
import '../routes/api/v1/profile/quiz.dart' as api_v1_profile_quiz;
import '../routes/api/v1/investments/index.dart' as api_v1_investments_index;
import '../routes/api/v1/investments/[id].dart' as api_v1_investments_$id;
import '../routes/api/v1/goals/index.dart' as api_v1_goals_index;
import '../routes/api/v1/goals/[id].dart' as api_v1_goals_$id;
import '../routes/api/v1/expenses/summary.dart' as api_v1_expenses_summary;
import '../routes/api/v1/expenses/index.dart' as api_v1_expenses_index;
import '../routes/api/v1/expenses/[id].dart' as api_v1_expenses_$id;
import '../routes/api/v1/dashboard/index.dart' as api_v1_dashboard_index;
import '../routes/api/v1/contributions/index.dart' as api_v1_contributions_index;
import '../routes/api/v1/calculators/income_tax.dart' as api_v1_calculators_income_tax;
import '../routes/api/v1/calculators/compound_interest.dart' as api_v1_calculators_compound_interest;
import '../routes/api/v1/calculators/cdb_compare.dart' as api_v1_calculators_cdb_compare;
import '../routes/api/v1/auth/register.dart' as api_v1_auth_register;
import '../routes/api/v1/auth/refresh.dart' as api_v1_auth_refresh;
import '../routes/api/v1/auth/logout.dart' as api_v1_auth_logout;
import '../routes/api/v1/auth/login.dart' as api_v1_auth_login;

import '../routes/_middleware.dart' as middleware;
import '../routes/api/v1/_middleware.dart' as api_v1_middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/', (context) => buildHandler()(context))
    ..mount('/api/v1/reports', (context) => buildApiV1ReportsHandler()(context))
    ..mount('/api/v1/profile', (context) => buildApiV1ProfileHandler()(context))
    ..mount('/api/v1/investments', (context) => buildApiV1InvestmentsHandler()(context))
    ..mount('/api/v1/goals', (context) => buildApiV1GoalsHandler()(context))
    ..mount('/api/v1/expenses', (context) => buildApiV1ExpensesHandler()(context))
    ..mount('/api/v1/dashboard', (context) => buildApiV1DashboardHandler()(context))
    ..mount('/api/v1/contributions', (context) => buildApiV1ContributionsHandler()(context))
    ..mount('/api/v1/calculators', (context) => buildApiV1CalculatorsHandler()(context))
    ..mount('/api/v1/auth', (context) => buildApiV1AuthHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/health', (context) => health.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1ReportsHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/diversification', (context) => api_v1_reports_diversification.onRequest(context,))..all('/maturities', (context) => api_v1_reports_maturities.onRequest(context,))..all('/risk', (context) => api_v1_reports_risk.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1ProfileHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/quiz', (context) => api_v1_profile_quiz.onRequest(context,))..all('/recommendations', (context) => api_v1_profile_recommendations.onRequest(context,))..all('/result', (context) => api_v1_profile_result.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1InvestmentsHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => api_v1_investments_$id.onRequest(context,id,))..all('/', (context) => api_v1_investments_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1GoalsHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/<id>', (context,id,) => api_v1_goals_$id.onRequest(context,id,))..all('/', (context) => api_v1_goals_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1ExpensesHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/summary', (context) => api_v1_expenses_summary.onRequest(context,))..all('/<id>', (context,id,) => api_v1_expenses_$id.onRequest(context,id,))..all('/', (context) => api_v1_expenses_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1DashboardHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/', (context) => api_v1_dashboard_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1ContributionsHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/', (context) => api_v1_contributions_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1CalculatorsHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/cdb_compare', (context) => api_v1_calculators_cdb_compare.onRequest(context,))..all('/compound_interest', (context) => api_v1_calculators_compound_interest.onRequest(context,))..all('/income_tax', (context) => api_v1_calculators_income_tax.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1AuthHandler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/login', (context) => api_v1_auth_login.onRequest(context,))..all('/logout', (context) => api_v1_auth_logout.onRequest(context,))..all('/refresh', (context) => api_v1_auth_refresh.onRequest(context,))..all('/register', (context) => api_v1_auth_register.onRequest(context,));
  return pipeline.addHandler(router);
}

