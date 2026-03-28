import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

/// Data source for financial news — hits backend, falls back to static data.
class NewsDataSource {
  static const _baseUrl = 'http://localhost:8080/api/v1/news';

  Future<List<NewsArticle>> getNews() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body) as List;
        return list.map((e) => NewsArticle.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Backend unavailable — use static fallback
    }
    return _staticNews;
  }

  static final _staticNews = [
    NewsArticle(
      title: 'Selic permanece em 13,75% ao ano, decide Copom',
      description:
          'O Comitê de Política Monetária do Banco Central decidiu manter a taxa básica de juros, aguardando sinais de desaceleração da inflação.',
      source: 'Agência Brasil',
      url: 'https://agenciabrasil.ebc.com.br',
      publishedAt: '2026-03-28T10:00:00Z',
    ),
    NewsArticle(
      title: 'Ibovespa avança 1,2% puxado por ações de bancos',
      description:
          'O principal índice da Bolsa de Valores brasileira fechou em alta, impulsionado pelo setor financeiro após dados positivos de crédito.',
      source: 'InfoMoney',
      url: 'https://infomoney.com.br',
      publishedAt: '2026-03-28T09:30:00Z',
    ),
    NewsArticle(
      title: 'Tesouro Direto: IPCA+ 2035 ultrapassa 6% ao ano',
      description:
          'Investidores encontram oportunidade em títulos indexados à inflação com taxas reais atrativas no ambiente de juros elevados.',
      source: 'Valor Econômico',
      url: 'https://valor.globo.com',
      publishedAt: '2026-03-27T18:00:00Z',
    ),
    NewsArticle(
      title: 'Bitcoin volta a US\$ 70 mil e renova interesse de investidores',
      description:
          'A moeda digital voltou a despertar atenção após sequência de alta, com analistas divididos sobre a sustentabilidade do movimento.',
      source: 'CoinTelegraph Brasil',
      url: 'https://br.cointelegraph.com',
      publishedAt: '2026-03-27T14:00:00Z',
    ),
    NewsArticle(
      title: 'FIIs: fundos de logística lideram rentabilidade no trimestre',
      description:
          'Fundos imobiliários do setor de galpões e logística se destacaram com distribuição de rendimentos acima da média do mercado.',
      source: 'Funds Explorer',
      url: 'https://fundsexplorer.com.br',
      publishedAt: '2026-03-26T12:00:00Z',
    ),
    NewsArticle(
      title: 'Dólar recua após dados de inflação nos EUA surpreenderem',
      description:
          'A moeda americana perdeu força frente ao real com a expectativa de um ciclo de cortes de juros pelo Fed ainda este ano.',
      source: 'Reuters Brasil',
      url: 'https://reuters.com',
      publishedAt: '2026-03-26T11:00:00Z',
    ),
    NewsArticle(
      title: '5 erros que todo investidor iniciante comete ao montar a carteira',
      description:
          'Especialistas apontam as armadilhas mais comuns e como evitá-las para construir um portfólio sólido no longo prazo.',
      source: 'XP Investimentos',
      url: 'https://xpi.com.br',
      publishedAt: '2026-03-25T09:00:00Z',
    ),
  ];
}
