import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsItem {
  final String category;
  final String? ticker;
  final String headline;
  final String sub;
  final String timeAgo;
  final String? url;
  final String? imageUrl;
  final String? source;
  final bool isFeatured;

  const NewsItem({
    required this.category,
    required this.ticker,
    required this.headline,
    required this.sub,
    required this.timeAgo,
    this.url,
    this.imageUrl,
    this.source,
    this.isFeatured = false,
  });

  factory NewsItem.fromNewsAPI(Map<String, dynamic> json, int index) {
    final title = (json['title'] as String? ?? '')
        .replaceAll(RegExp(r'\s*-\s*[^-]+$'), '');
    final description = json['description'] as String? ?? '';
    final publishedAt = json['publishedAt'] as String? ?? '';
    final url = json['url'] as String?;
    final imageUrl = json['urlToImage'] as String?;
    final sourceName = (json['source'] as Map?)?['name'] as String? ?? '';

    final ticker = _extractTicker(title);
    final category = _inferCategory(title + description);
    final timeAgo = _formatTimeAgo(publishedAt);

    return NewsItem(
      category: category,
      ticker: ticker,
      headline: title,
      sub: description.isNotEmpty ? description : 'Toque para ler mais.',
      timeAgo: timeAgo,
      url: url,
      imageUrl: imageUrl,
      source: sourceName,
      isFeatured: index == 0,
    );
  }

  static String? _extractTicker(String text) {
    const tickers = [
      'PETR4','VALE3','ITUB4','BBDC4','ABEV3','B3SA3','WEGE3',
      'RENT3','RADL3','MGLU3','MXRF11','HGLG11','KNRI11','VISC11',
    ];
    for (final t in tickers) {
      if (text.toUpperCase().contains(t)) return t;
    }
    return null;
  }

  static String _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('fii') || lower.contains('fundo imobiliario') ||
        lower.contains('cota')) return 'fiis';
    if (lower.contains('dividendo') || lower.contains('jcp') ||
        lower.contains('proventos')) return 'dividends';
    if (lower.contains('selic') || lower.contains('inflacao') ||
        lower.contains('ipca') || lower.contains('pib') ||
        lower.contains('copom')) return 'economy';
    if (lower.contains('guerra') || lower.contains('oriente') ||
        lower.contains('china') || lower.contains('petroleo')) return 'geo';
    return 'market';
  }

  static String _formatTimeAgo(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'há ${diff.inHours} h';
      return 'há ${diff.inDays} d';
    } catch (_) {
      return '';
    }
  }
}

class NewsService {
  // 🔑 NewsAPI key (newsapi.org)
  static const String _apiKey = 'a12538a4596c42fe9221d38f17e8e65a';

  static const _baseUrl = 'https://newsapi.org/v2';

  // NewsAPI — plano Developer só funciona em localhost/emulador,
  // não em dispositivo físico em produção.
  static const _queryByCategory = {
    'all':       'mercado financeiro brasil',
    'geo':       'geopolitica petroleo brasil',
    'fiis':      'fundos imobiliarios brasil',
    'dividends': 'dividendos acoes brasil',
    'economy':   'selic inflacao brasil',
  };

  Future<List<NewsItem>> fetchNews({String category = 'all'}) async {
    try {
      final items = await _fetchFromNewsAPI(category);
      return items.isNotEmpty ? items : _mockNews(category);
    } catch (e) {
      print('[NewsService] erro: $e — usando mock');
      return _mockNews(category);
    }
  }

  Future<List<NewsItem>> _fetchFromNewsAPI(String category) async {
    final rawQuery = _queryByCategory[category] ?? _queryByCategory['all']!;
    final query = Uri.encodeComponent(rawQuery);
    final uri = Uri.parse(
      '$_baseUrl/everything?q=$query&language=pt&sortBy=publishedAt&pageSize=10&apiKey=$_apiKey',
    );

    print('[NewsService] GET $uri');

    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    print('[NewsService] status ${response.statusCode}');

    if (response.statusCode != 200) {
      print('[NewsService] body: ${response.body}');
      throw Exception('NewsAPI error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    // NewsAPI retorna status "ok" ou "error" no body mesmo com 200
    if (decoded['status'] != 'ok') {
      print('[NewsService] API status error: ${decoded['message']}');
      throw Exception(decoded['message']);
    }

    final articles = (decoded['articles'] as List?) ?? [];
    print('[NewsService] artigos recebidos: ${articles.length}');

    return articles
        .asMap()
        .entries
        .map((e) => NewsItem.fromNewsAPI(e.value as Map<String, dynamic>, e.key))
        .toList();
  }

  List<NewsItem> _mockNews(String category) {
    final all = [
      const NewsItem(
        category: 'dividends', ticker: 'PETR4',
        headline: 'Petrobras anuncia dividendos de R\$ 2,50 por ação',
        sub: 'Valor será pago em maio aos acionistas registrados.',
        timeAgo: 'há 2 h', isFeatured: true,
      ),
      const NewsItem(
        category: 'dividends', ticker: 'VALE3',
        headline: 'Vale bate recorde de produção no 4º trimestre',
        sub: 'Resultado acima do esperado pelo mercado.',
        timeAgo: 'há 4 h',
      ),
      const NewsItem(
        category: 'economy', ticker: null,
        headline: 'Selic deve subir 0,5% na próxima reunião do Copom',
        sub: 'Analistas revisam projeção de inflação para cima.',
        timeAgo: 'há 5 h',
      ),
      const NewsItem(
        category: 'dividends', ticker: 'ITUB4',
        headline: 'Itaú reporta lucro líquido de R\$ 9,8 bilhões',
        sub: 'Crescimento de 15% sobre o mesmo período do ano anterior.',
        timeAgo: 'há 6 h',
      ),
      const NewsItem(
        category: 'fiis', ticker: 'MXRF11',
        headline: 'MXRF11 anuncia distribuição de R\$ 0,10/cota',
        sub: 'Yield mensal de 0,95% sobre o valor de mercado.',
        timeAgo: 'há 8 h',
      ),
      const NewsItem(
        category: 'geo', ticker: null,
        headline: 'Tensões no Oriente Médio pressionam petróleo',
        sub: 'Brent sobe 2% com incertezas geopolíticas.',
        timeAgo: 'há 10 h',
      ),
      const NewsItem(
        category: 'economy', ticker: 'BBDC4',
        headline: 'Banco do Brasil eleva guidance de crédito para 2025',
        sub: 'Carteira deve crescer entre 9% e 13%.',
        timeAgo: 'há 12 h',
      ),
    ];

    if (category == 'all') return all;
    return all.where((n) => n.category == category).toList();
  }
}
