import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

/// Remote data source for investor profile API.
class ProfileDataSource {
  final Dio _dio = ApiClient.instance;

  Future<List<dynamic>> getQuizQuestions() async {
    final response = await _dio.get(ApiEndpoints.profileQuiz);
    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> submitQuiz(List<Map<String, dynamic>> answers) async {
    final response = await _dio.post(ApiEndpoints.profileQuiz, data: {'answers': answers});
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getResult() async {
    try {
      final response = await _dio.get(ApiEndpoints.profileResult);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<dynamic>> getRecommendations() async {
    final response = await _dio.get(ApiEndpoints.recommendations);
    return response.data['data'] as List<dynamic>;
  }
}
