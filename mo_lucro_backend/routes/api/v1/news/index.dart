import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

/// GET /api/v1/news
/// Returns financial news. Uses GNews API if key is set, else curated static data.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final apiKey = Platform.environment['GNEWS_API_KEY'] ?? '';

  if (apiKey.isNotEmpty) {
    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://gnews.io/api/v1/search?q=finanças+investimentos&lang=pt&country=br&max=10&token=$apiKey',
      );
      final req = await client.getUrl(uri);
      final res = await req.close().timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = await res.transform(const SystemEncoding().decoder).join();
        final decoded = _reshapeGnews(body);
        if (decoded != null) return Response.json(body: decoded);
      }
    } catch (_) {
      // Fall through to static
    }
  }

  return Response.json(body: _staticNews);
}

List<Map<String, dynamic>>? _reshapeGnews(String body) {
  try {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final articles = map['articles'] as List<dynamic>;
    return articles.map((a) {
      final m = a as Map<String, dynamic>;
      return {
        'title': m['title'] ?? '',
        'description': m['description'] ?? '',
        'source': (m['source'] as Map?)?['name'] ?? '',
        'url': m['url'] ?? '',
        'image': m['image'],
        'publishedAt': m['publishedAt'] ?? '',
      };
    }).toList();
  } catch (_) {
    return null;
  }
}

const _staticNews = [
  {
    'title': 'Selic permanece em 13,75% ao ano, decide Copom',
    'description':
        'O Comitê de Política Monetária do Banco Central decidiu manter a taxa básica de juros, aguardando sinais de desaceleração da inflação nos próximos meses.',
    'source': 'Agência Brasil',
    'url': 'https://agenciabrasil.ebc.com.br',
    'image': null,
    'publishedAt': '2026-03-28T10:00:00Z',
  },
  {
    'title': 'Ibovespa avança 1,2% puxado por ações de bancos',
    'description':
        'O principal índice da Bolsa de Valores brasileira fechou em alta, impulsionado pelo setor financeiro após dados positivos de crédito.',
    'source': 'InfoMoney',
    'url': 'https://infomoney.com.br',
    'image': null,
    'publishedAt': '2026-03-28T09:30:00Z',
  },
  {
    'title': 'Tesouro Direto: IPCA+ 2035 ultrapassa 6% ao ano',
    'description':
        'Investidores encontram oportunidade em títulos indexados à inflação com taxas reais atrativas no ambiente de juros elevados.',
    'source': 'Valor Econômico',
    'url': 'https://valor.globo.com',
    'image': null,
    'publishedAt': '2026-03-27T18:00:00Z',
  },
  {
    'title': 'Bitcoin volta a US\$ 70 mil e renova interesse de investidores',
    'description':
        'A moeda digital voltou a despertar atenção após sequência de alta, com analistas divididos sobre a sustentabilidade do movimento.',
    'source': 'CoinTelegraph Brasil',
    'url': 'https://br.cointelegraph.com',
    'image': null,
    'publishedAt': '2026-03-27T14:00:00Z',
  },
  {
    'title': 'FIIs: fundos de logística lideram rentabilidade no trimestre',
    'description':
        'Fundos imobiliários do setor de galpões e logística se destacaram com distribuição de rendimentos acima da média do mercado.',
    'source': 'Funds Explorer',
    'url': 'https://fundsexplorer.com.br',
    'image': null,
    'publishedAt': '2026-03-26T12:00:00Z',
  },
  {
    'title': 'Dólar recua após dados de inflação nos EUA surpreenderem',
    'description':
        'A moeda americana perdeu força frente ao real com a expectativa de um ciclo de cortes de juros pelo Fed ainda este ano.',
    'source': 'Reuters Brasil',
    'url': 'https://reuters.com',
    'image': null,
    'publishedAt': '2026-03-26T11:00:00Z',
  },
  {
    'title': '5 erros que todo investidor iniciante comete ao montar a carteira',
    'description':
        'Especialistas apontam as armadilhas mais comuns e como evitá-las para construir um portfólio sólido no longo prazo.',
    'source': 'XP Investimentos',
    'url': 'https://xpi.com.br',
    'image': null,
    'publishedAt': '2026-03-25T09:00:00Z',
  },
];
