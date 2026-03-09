import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for calculators API.
class CalculatorDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> simulateCompoundInterest(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.compoundInterest, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> compareCDBs(List<Map<String, dynamic>> options) async {
    final response = await _dio.post(ApiEndpoints.cdbCompare, data: {'options': options});
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> estimateIncomeTax(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.incomeTax, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }
}
