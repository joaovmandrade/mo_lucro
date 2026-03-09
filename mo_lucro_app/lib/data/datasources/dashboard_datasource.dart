import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for dashboard API.
class DashboardDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.dashboard);
    return response.data['data'] as Map<String, dynamic>;
  }
}
