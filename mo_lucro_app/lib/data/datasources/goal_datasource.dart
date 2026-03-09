import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for goals API.
class GoalDataSource {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getGoals() async {
    final response = await _dio.get(ApiEndpoints.goals);
    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getGoalDetails(String id) async {
    final response = await _dio.get(ApiEndpoints.goalById(id));
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createGoal(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.goals, data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateGoal(String id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiEndpoints.goalById(id), data: data);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteGoal(String id) async {
    await _dio.delete(ApiEndpoints.goalById(id));
  }
}
