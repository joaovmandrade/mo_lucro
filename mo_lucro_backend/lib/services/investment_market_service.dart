import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:mo_lucro_backend/core/config.dart';
import '../repositories/market_cache_repository.dart';

/// Service to integrate with Alpha Vantage API.
class InvestmentMarketService {
  final MarketCacheRepository _cacheRepository;
  final String _baseUrl = 'https://www.alphavantage.co/query';

  InvestmentMarketService(this._cacheRepository);

  String get _apiKey => AppConfig.alphaVantageApiKey;

  /// Get real-time stock quote.
  Future<Map<String, dynamic>> getStockData(String symbol) async {
    final cacheKey = 'stock_quote_$symbol';
    final cached = await _cacheRepository.get(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse('$_baseUrl?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$_apiKey');
    developer.log('Fetching stock quote for $symbol', name: 'InvestmentMarketService');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Handle rate limits or invalid keys
        if (jsonResponse.containsKey('Information') || jsonResponse.containsKey('Note')) {
          developer.log('Alpha Vantage API limit/note: ${jsonResponse}', name: 'InvestmentMarketService', level: 900);
          throw Exception('API limit reached or invalid key');
        }

        if (jsonResponse.containsKey('Global Quote') && jsonResponse['Global Quote'].isNotEmpty) {
          final quote = jsonResponse['Global Quote'];
          final data = {
            'symbol': quote['01. symbol'],
            'price': double.tryParse(quote['05. price'] ?? '0'),
            'change': double.tryParse(quote['09. change'] ?? '0'),
            'changePercent': quote['10. change percent'],
          };
          // Cache for 15 minutes to respect rate limits
          await _cacheRepository.set(cacheKey, data, const Duration(minutes: 15));
          developer.log('Successfully fetched quote for $symbol', name: 'InvestmentMarketService');
          return data;
        }
      }
      throw Exception('Failed to load stock data for $symbol: ${response.statusCode}');
    } catch (e) {
      developer.log('Error fetching stock quote for $symbol: $e', name: 'InvestmentMarketService', error: e);
      throw Exception('Error loading stock quote: $e');
    }
  }

  /// Get historical stock data.
  Future<Map<String, dynamic>> getStockHistory(String symbol) async {
    final cacheKey = 'stock_history_$symbol';
    final cached = await _cacheRepository.get(cacheKey);
    if (cached != null) return cached;

    final url = Uri.parse('$_baseUrl?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$_apiKey');
    developer.log('Fetching stock history for $symbol', name: 'InvestmentMarketService');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse.containsKey('Information') || jsonResponse.containsKey('Note')) {
          developer.log('Alpha Vantage API limit/note: ${jsonResponse}', name: 'InvestmentMarketService', level: 900);
          throw Exception('API limit reached or invalid key');
        }

        if (jsonResponse.containsKey('Time Series (Daily)')) {
          final data = jsonResponse['Time Series (Daily)'];
          // Cache history for 12 hours since daily doesn't change often
          await _cacheRepository.set(cacheKey, data as Map<String, dynamic>, const Duration(hours: 12));
          developer.log('Successfully fetched history for $symbol', name: 'InvestmentMarketService');
          return data;
        }
      }
      throw Exception('Failed to load stock history for $symbol: ${response.statusCode}');
    } catch (e) {
      developer.log('Error fetching stock history for $symbol: $e', name: 'InvestmentMarketService', error: e);
      throw Exception('Error loading stock history: $e');
    }
  }
}
