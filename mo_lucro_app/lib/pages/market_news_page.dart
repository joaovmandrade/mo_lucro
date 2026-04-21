import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Market news feed screen with category filters and article detail.
class MarketNewsPage extends StatefulWidget {
  const MarketNewsPage({super.key});

  @override
  State<MarketNewsPage> createState() => _MarketNewsPageState();
}

class _MarketNewsPageState extends State<MarketNewsPage> {
  String _filter = 'all';

  static const _filters = {
    'all':         'Todos',
    'geo':         'Geopolítica',
    'fiis':        'FIIs',
    'dividends':   'Dividendos',
    'economy':     'Economia',
  };

  // Static mock headlines (replace with API in production)
  static const _news = [
    _NewsItem(
      category: 'dividends',
      ticker: 'PETR4',
      headline: 'Petrobras anuncia dividendos de R\$ 2,50 por ação',
      sub: 'Valor a ser pago em 20 de maio aos acionistas.',
      timeAgo: 'há 2 h',
      isFeatured: true,
    ),
    _NewsItem(
      category: 'dividends',
      ticker: 'VALE3',
      headline: 'Vale bate recorde de produção no 4º trimestre',
      sub: 'Resultado acima do esperado pelo mercado.',
      timeAgo: 'há 4 h',
    ),
    _NewsItem(
      category: 'economy',
      ticker: null,
      headline: 'Selic deve subir 0,5% na próxima reunião do Copom',
      sub: 'Analistas revisam projeção de inflação para cima.',
      timeAgo: 'há 5 h',
    ),
    _NewsItem(
      category: 'dividends',
      ticker: 'ITUB4',
      headline: 'Itaú reporta lucro líquido de R\$ 9,8 bilhões',
      sub: 'Crescimento de 15% em relação ao mesmo período do ano anterior.',
      timeAgo: 'há 6 h',
    ),
    _NewsItem(
      category: 'fiis',
      ticker: 'MXRF11',
      headline: 'MXRF11 anuncia distribuição de R\$ 0,10/cota',
      sub: 'Yield mensal de 0,95% sobre o valor de mercado.',
      timeAgo: 'há 8 h',
    ),
    _NewsItem(
      category: 'geo',
      ticker: null,
      headline: 'Tensões no Oriente Médio pressionam petróleo',
      sub: 'Brent sobe 2% com incertezas geopolíticas.',
      timeAgo: 'há 10 h',
    ),
    _NewsItem(
      category: 'economy',
      ticker: 'BBDC4',
      headline: 'Banco do Brasil eleva guidance de crédito para 2025',
      sub: 'Carteira deve crescer entre 9% e 13%.',
      timeAgo: 'há 12 h',
    ),
  ];

  List<_NewsItem> get _filtered =>
      _filter == 'all' ? _news : _news.where((n) => n.category == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final featured = _filtered.firstWhere(
      (n) => n.isFeatured,
      orElse: () => _filtered.isNotEmpty ? _filtered.first : _news.first,
    );
    final regular = _filtered.where((n) => !n.isFeatured).toList();

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        title: const Text('Notícias do Mercado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _filters.entries.map((e) {
                final isSel = _filter == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _filter = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.bg2,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSel ? AppColors.primary : AppColors.border,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Featured card
                if (_filtered.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => _showDetail(context, featured),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F1D3B), Color(0xFF192B52)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.xxl),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            if (featured.ticker != null) ...[
                              _NewsTag(
                                  label: featured.ticker!,
                                  color: AppColors.primary),
                              const SizedBox(width: 6),
                            ],
                            _NewsTag(
                                label: _categoryLabel(featured.category),
                                color: AppColors.accent),
                            const Spacer(),
                            Text(featured.timeAgo,
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 11)),
                          ]),
                          const SizedBox(height: 10),
                          Text(
                            featured.headline,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            featured.sub,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          const Row(children: [
                            Text('Ler mais',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: AppColors.primary, size: 14),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Regular list
                ...regular.map((n) => _NewsTile(
                      item: n,
                      onTap: () => _showDetail(context, n),
                    )),

                const SizedBox(height: 16),
                Center(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Ver Mais'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, _NewsItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => _NewsDetail(item: item, scrollCtrl: ctrl),
      ),
    );
  }

  String _categoryLabel(String cat) {
    switch (cat) {
      case 'fiis':     return 'FIIs';
      case 'geo':      return 'Geopolítica';
      case 'dividends':return 'Dividendos';
      case 'economy':  return 'Economia';
      default:         return 'Mercado';
    }
  }
}

// ── Tile ────────────────────────────────────────────────────

class _NewsTile extends StatelessWidget {
  final _NewsItem item;
  final VoidCallback onTap;

  const _NewsTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.article_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    if (item.ticker != null) ...[
                      _NewsTag(label: item.ticker!, color: AppColors.accent),
                      const SizedBox(width: 6),
                    ],
                    Text(item.timeAgo,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 10)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item.headline,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Detail sheet ────────────────────────────────────────────

class _NewsDetail extends StatelessWidget {
  final _NewsItem item;
  final ScrollController scrollCtrl;

  const _NewsDetail({required this.item, required this.scrollCtrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Tags
        Row(children: [
          if (item.ticker != null) ...[
            _NewsTag(label: item.ticker!, color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          Text(item.timeAgo,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
        const SizedBox(height: 12),

        Text(
          item.headline,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.sub,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),

        // Placeholder article body
        const Text(
          'A análise indica que o resultado está em linha com os fundamentos sólidos da empresa. '
          'Especialistas recomendam cautela ao avaliar o momento para novos aportes, considerando '
          'o cenário macroeconômico atual e as perspectivas para o setor.\n\n'
          'Os dados divulgados reforçam a tese de investimento de longo prazo, mas investidores '
          'devem acompanhar de perto os próximos balanços para confirmar a tendência.\n\n'
          'O volume negociado no pregão de hoje foi 40% superior à média dos últimos 30 dias, '
          'sinalizando interesse institucional renovado no ativo.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 24),

        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.bookmark_border_rounded, size: 16),
          label: const Text('Salvar artigo'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────

class _NewsTag extends StatelessWidget {
  final String label;
  final Color color;

  const _NewsTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _NewsItem {
  final String category;
  final String? ticker;
  final String headline;
  final String sub;
  final String timeAgo;
  final bool isFeatured;

  const _NewsItem({
    required this.category,
    required this.ticker,
    required this.headline,
    required this.sub,
    required this.timeAgo,
    this.isFeatured = false,
  });
}
