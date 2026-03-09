import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for expenses API.
class ExpenseDataSource {
  final Dio _dio = ApiClient.instance;

  Future<Map<String, dynamic>> getExpenses({
    String? type,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(ApiEndpoints.expenses, queryParameters: {
      'page': page, 'limit': limit,
      if (type != null) 'type': type,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.expenses, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExpense(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.expenseById(id), data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteExpense(String id) async {
    await _dio.delete(ApiEndpoints.expenseById(id));
  }

  Future<Map<String, dynamic>> getSummary({int? year, int? month}) async {
    final response = await _dio.get(ApiEndpoints.expenseSummary, queryParameters: {
      if (year != null) 'year': year,
      if (month != null) 'month': month,
    });
    return response.data['data'] as Map<String, dynamic>;
  }
}
