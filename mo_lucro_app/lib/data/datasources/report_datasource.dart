import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for reports API.
class ReportDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getRiskAnalysis() async {
    final response = await _dio.get(ApiEndpoints.riskAnalysis);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDiversification() async {
    final response = await _dio.get(ApiEndpoints.diversification);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMaturities() async {
    final response = await _dio.get(ApiEndpoints.maturities);
    return response.data['data'] as List<dynamic>;
  }
}
