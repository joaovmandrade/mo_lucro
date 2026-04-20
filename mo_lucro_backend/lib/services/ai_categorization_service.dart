import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:mo_lucro_backend/core/config.dart';

/// Service to integrate with OpenAI for expense categorization.
class AiCategorizationService {
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => AppConfig.openAiApiKey;

  /// Automatically categorize an expense based on its description.
  Future<Map<String, dynamic>> categorizeExpense(String description) async {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a financial assistant. Categorize the following expense description using ONE of these basic categories: Transporte, Alimentacao, Saude, Lazer, Educacao, Moradia, Outros. Respond ONLY with a JSON object like {"category": "category_name"}.'
        },
        {
          'role': 'user',
          'content': description
        }
      ],
      'temperature': 0.3,
      'max_tokens': 20,
    });

    developer.log('Categorizing expense with OpenAI', name: 'AiCategorizationService');

    try {
      final response = await http.post(Uri.parse(_baseUrl), headers: headers, body: body).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['choices'] != null && jsonResponse['choices'].isNotEmpty) {
          final content = jsonResponse['choices'][0]['message']['content'];
          developer.log('Successfully categorized expense: $content', name: 'AiCategorizationService');
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
      throw Exception('Failed to categorize expense: ${response.statusCode} - ${response.body}');
    } catch (e) {
      developer.log('Error categorizing expense: $e', name: 'AiCategorizationService', error: e);
      throw Exception('Error loading AI categorization: $e');
    }
  }
}
