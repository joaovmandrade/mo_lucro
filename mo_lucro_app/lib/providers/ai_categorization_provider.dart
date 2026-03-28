import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AiCategorizationNotifier extends StateNotifier<String?> {
  AiCategorizationNotifier() : super(null);

  final String _baseUrl = 'http://localhost:8080/api/v1';

  Future<String?> suggestCategory(String description) async {
    if (description.isEmpty || description.length < 3) return null;
    
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/ai/categorize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'description': description}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final category = data['category'] as String?;
        if (category != null) {
          state = category; // update state with suggestion
          return category;
        }
      }
    } catch (_) {
      // Ignore network errors or if backend is offline
    }
    return null;
  }
}

final aiCategorizationProvider = StateNotifierProvider<AiCategorizationNotifier, String?>((ref) {
  return AiCategorizationNotifier();
});
