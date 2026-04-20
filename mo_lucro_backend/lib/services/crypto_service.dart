import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:mo_lucro_backend/core/config.dart';
import '../repositories/market_cache_repository.dart';

/// Service to integrate with CoinGecko API.
class CryptoService {
  final MarketCacheRepository _cacheRepository;
  final String _baseUrl = 'https://api.coingecko.com/api/v3';

  CryptoService(this._cacheRepository);

  String get _apiKey => AppConfig.coinGeckoApiKey;

  /// Get real-time cryptocurrency data.
  Future<Map<String, dynamic>> getCryptoData(String id) async {
    final cacheKey = 'crypto_$id';
    final cached = await _cacheRepository.get(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse('$_baseUrl/simple/price?ids=$id&vs_currencies=usd,brl&include_24hr_change=true');
    final headers = {
      if (_apiKey.isNotEmpty) 'x-cg-demo-api-key': _apiKey,
    };
    
    developer.log('Fetching crypto data for $id', name: 'CryptoService');
    
    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey(id)) {
          final data = jsonResponse[id];
          // Cache crypto price for 5 minutes
          await _cacheRepository.set(cacheKey, data as Map<String, dynamic>, const Duration(minutes: 5));
          developer.log('Successfully fetched crypto for $id', name: 'CryptoService');
          return data;
        }
      }
      throw Exception('Failed to load crypto data for $id: ${response.statusCode}');
    } catch (e) {
      developer.log('Error fetching crypto data for $id: $e', name: 'CryptoService', error: e);
      throw Exception('Error loading crypto data: $e');
    }
  }
}
