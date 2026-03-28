import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../repositories/market_cache_repository.dart';

/// Service to integrate with Banco Central do Brasil API.
class EconomicService {
  final MarketCacheRepository _cacheRepository;

  EconomicService(this._cacheRepository);

  /// Get current Selic target rate.
  Future<Map<String, dynamic>> getSelicRate() async {
    final cacheKey = 'bcb_selic_rate';
    final cached = await _cacheRepository.get(cacheKey);
    if (cached != null) return cached;

    // Series 432 corresponds to Selic Target (% per year)
    final url = Uri.parse('https://api.bcb.gov.br/dados/serie/bcdata.sgs.432/dados/ultimos/1?formato=json');
    developer.log('Fetching BCB Selic rate', name: 'EconomicService');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List && jsonResponse.isNotEmpty) {
          final data = jsonResponse.first;
          // Cache for 24 hours
          await _cacheRepository.set(cacheKey, data as Map<String, dynamic>, const Duration(hours: 24));
          developer.log('Successfully fetched Selic rate: ${data['valor']}', name: 'EconomicService');
          return data;
        }
      }
      throw Exception('Failed to load SELIC rate from BCB: ${response.statusCode}');
    } catch (e) {
      developer.log('Error fetching Selic rate: $e', name: 'EconomicService', error: e);
      throw Exception('Error loading Selic rate: $e');
    }
  }
}
