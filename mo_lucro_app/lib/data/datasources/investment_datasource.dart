import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for investments API.
class InvestmentDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getInvestments({
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.investments, queryParameters: {
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getInvestmentDetails(String id) async {
    final response = await _dio.get(ApiEndpoints.investmentById(id));
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createInvestment(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.investments, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateInvestment(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.investmentById(id), data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteInvestment(String id) async {
    await _dio.delete(ApiEndpoints.investmentById(id));
  }

  Future<Map<String, dynamic>> addContribution(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.contributions, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }
}
