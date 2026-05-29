import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteResult {
  final String ticker;
  final double price;
  final double changePercent;
  final bool success;

  const QuoteResult({
    required this.ticker,
    required this.price,
    required this.changePercent,
    required this.success,
  });

  factory QuoteResult.empty(String ticker) => QuoteResult(
        ticker: ticker,
        price: 0,
        changePercent: 0,
        success: false,
      );
}

class MarketDataService {
  static const _brapiUrl = 'https://brapi.dev/api';
  static const _geckoUrl = 'https://api.coingecko.com/api/v3';

  static final Map<String, (QuoteResult, DateTime)> _cache = {};
  static const _cacheTtl = Duration(minutes: 5);

  // Mapa de ticker do app → ID do CoinGecko
  static const _cryptoIds = {
    'BTC':  'bitcoin',
    'ETH':  'ethereum',
    'BNB':  'binancecoin',
    'SOL':  'solana',
    'ADA':  'cardano',
    'XRP':  'ripple',
    'DOGE': 'dogecoin',
    'DOT':  'polkadot',
    'MATIC':'matic-network',
    'LTC':  'litecoin',
    'USDT': 'tether',
    'USDC': 'usd-coin',
  };

  /// Busca cotação pelo ticker, detectando automaticamente a fonte correta.
  Future<QuoteResult> getQuote(String ticker, {String category = 'stocks'}) async {
    final upper = ticker.toUpperCase();

    final cached = _cache[upper];
    if (cached != null && DateTime.now().difference(cached.$2) < _cacheTtl) {
      return cached.$1;
    }

    try {
      final result = category == 'crypto'
          ? await _fetchCrypto(upper)
          : await _fetchBrapi(upper);
      _cache[upper] = (result, DateTime.now());
      return result;
    } catch (e) {
      print('[MarketData] erro para $upper: $e');
      return QuoteResult.empty(upper);
    }
  }

  // ── BRAPI — Ações e FIIs da B3 ───────────────────────────
  Future<QuoteResult> _fetchBrapi(String ticker) async {
    final uri = Uri.parse('$_brapiUrl/quote/$ticker?fundamental=false');
    print('[MarketData] BRAPI GET $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    print('[MarketData] BRAPI status ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('BRAPI error ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (decoded['results'] as List?) ?? [];
    if (results.isEmpty) return QuoteResult.empty(ticker);

    final item = results.first as Map<String, dynamic>;
    final price = (item['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
    final change = (item['regularMarketChangePercent'] as num?)?.toDouble() ?? 0.0;

    return QuoteResult(
      ticker: ticker,
      price: price,
      changePercent: change,
      success: price > 0,
    );
  }

  // ── CoinGecko — Criptomoedas ──────────────────────────────
  Future<QuoteResult> _fetchCrypto(String ticker) async {
    // Resolve ID do CoinGecko (ex: BTC → bitcoin)
    final coinId = _cryptoIds[ticker] ?? ticker.toLowerCase();

    final uri = Uri.parse(
      '$_geckoUrl/simple/price?ids=$coinId&vs_currencies=brl&include_24hr_change=true',
    );
    print('[MarketData] CoinGecko GET $uri');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    print('[MarketData] CoinGecko status ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('CoinGecko error ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded[coinId] as Map<String, dynamic>?;

    if (data == null) {
      print('[MarketData] CoinGecko: coin "$coinId" não encontrado');
      return QuoteResult.empty(ticker);
    }

    final price = (data['brl'] as num?)?.toDouble() ?? 0.0;
    final change = (data['brl_24h_change'] as num?)?.toDouble() ?? 0.0;

    return QuoteResult(
      ticker: ticker,
      price: price,
      changePercent: change,
      success: price > 0,
    );
  }

  /// Busca múltiplos tickers de uma vez, separando por categoria.
  Future<Map<String, QuoteResult>> getQuotes(
      Map<String, String> tickerCategories) async {
    if (tickerCategories.isEmpty) return {};

    final result = <String, QuoteResult>{};
    final toFetchBrapi = <String>[];
    final toFetchCrypto = <String>[];

    for (final entry in tickerCategories.entries) {
      final upper = entry.key.toUpperCase();
      final cached = _cache[upper];
      if (cached != null && DateTime.now().difference(cached.$2) < _cacheTtl) {
        result[upper] = cached.$1;
      } else if (entry.value == 'crypto') {
        toFetchCrypto.add(upper);
      } else {
        toFetchBrapi.add(upper);
      }
    }

    // Batch BRAPI
    if (toFetchBrapi.isNotEmpty) {
      try {
        final joined = toFetchBrapi.join(',');
        final uri = Uri.parse('$_brapiUrl/quote/$joined?fundamental=false');
        final response = await http.get(uri).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final results = (decoded['results'] as List?) ?? [];
          for (final item in results) {
            final map = item as Map<String, dynamic>;
            final t = (map['symbol'] as String? ?? '').toUpperCase();
            final price = (map['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
            final change = (map['regularMarketChangePercent'] as num?)?.toDouble() ?? 0.0;
            final quote = QuoteResult(ticker: t, price: price, changePercent: change, success: price > 0);
            result[t] = quote;
            _cache[t] = (quote, DateTime.now());
          }
        }
      } catch (e) {
        print('[MarketData] erro batch BRAPI: $e');
      }
      for (final t in toFetchBrapi) {
        result.putIfAbsent(t, () => QuoteResult.empty(t));
      }
    }

    // Batch CoinGecko
    if (toFetchCrypto.isNotEmpty) {
      try {
        final ids = toFetchCrypto
            .map((t) => _cryptoIds[t] ?? t.toLowerCase())
            .join(',');
        final uri = Uri.parse(
          '$_geckoUrl/simple/price?ids=$ids&vs_currencies=brl&include_24hr_change=true',
        );
        final response = await http.get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          for (final ticker in toFetchCrypto) {
            final coinId = _cryptoIds[ticker] ?? ticker.toLowerCase();
            final data = decoded[coinId] as Map<String, dynamic>?;
            if (data != null) {
              final price = (data['brl'] as num?)?.toDouble() ?? 0.0;
              final change = (data['brl_24h_change'] as num?)?.toDouble() ?? 0.0;
              final quote = QuoteResult(ticker: ticker, price: price, changePercent: change, success: price > 0);
              result[ticker] = quote;
              _cache[ticker] = (quote, DateTime.now());
            }
          }
        }
      } catch (e) {
        print('[MarketData] erro batch CoinGecko: $e');
      }
      for (final t in toFetchCrypto) {
        result.putIfAbsent(t, () => QuoteResult.empty(t));
      }
    }

    return result;
  }
}
