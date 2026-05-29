import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/new_service.dart';

/// Market news feed — fetches from GNews API (or mock on fallback).
class MarketNewsPage extends StatefulWidget {
  const MarketNewsPage({super.key});

  @override
  State<MarketNewsPage> createState() => _MarketNewsPageState();
}

class _MarketNewsPageState extends State<MarketNewsPage> {
  final _service = NewsService();

  String _filter = 'all';
  List<NewsItem> _news = [];
  bool _loading = true;
  String? _error;

  static const _filters = {
    'all':       'Todos',
    'geo':       'Geopolítica',
    'fiis':      'FIIs',
    'dividends': 'Dividendos',
    'economy':   'Economia',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? category}) async {
    final cat = category ?? _filter;
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _service.fetchNews(category: cat);
      if (mounted) setState(() { _news = items; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _changeFilter(String key) async {
    setState(() => _filter = key);
    await _load(category: key);
  }

  NewsItem? get _featured => _news.isEmpty ? null : _news.firstWhere(
    (n) => n.isFeatured,
    orElse: () => _news.first,
  );

  List<NewsItem> get _regular => _featured == null
      ? []
      : _news.where((n) => n != _featured).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Column(
        children: [
          // ── Header azul gradiente ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      // Botão voltar
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: AppColors.textOnBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Título
                      const Expanded(
                        child: Text(
                          'Notícias do Mercado',
                          style: TextStyle(
                            color: AppColors.textOnBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Botão refresh
                      GestureDetector(
                        onTap: () => _load(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: AppColors.textOnBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Category filter chips ──────────────────────────────
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _filters.entries.map((e) {
                final isSel = _filter == e.key;
                return GestureDetector(
                  onTap: () => _changeFilter(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary.withOpacity(0.15) : AppColors.bg2,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isSel ? AppColors.primary : AppColors.border,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Text(e.value,
                        style: TextStyle(
                          color: isSel ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.bg2,
              onRefresh: _load,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _LoadingState();
    if (_error != null) return _ErrorState(message: _error!, onRetry: _load);
    if (_news.isEmpty) return _EmptyState(onRetry: _load);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (_featured != null) ...[
          _FeaturedCard(item: _featured!, onTap: () => _showDetail(_featured!)),
          const SizedBox(height: 16),
        ],
        ..._regular.map((n) => _NewsTile(item: n, onTap: () => _showDetail(n))),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Recarregar'),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _showDetail(NewsItem item) {
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
}

// ── Featured card ──────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  const _FeaturedCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (item.ticker != null) ...[
                _NewsTag(label: item.ticker!, color: Colors.white),
                const SizedBox(width: 6),
              ],
              _NewsTag(label: _catLabel(item.category), color: Colors.white),
              const Spacer(),
              Text(item.timeAgo,
                  style: const TextStyle(color: AppColors.textOnBlueDim, fontSize: 11)),
            ]),
            const SizedBox(height: 10),
            Text(item.headline,
                style: const TextStyle(
                    color: AppColors.textOnBlue, fontSize: 16,
                    fontWeight: FontWeight.w700, height: 1.4)),
            const SizedBox(height: 6),
            Text(item.sub,
                style: const TextStyle(color: AppColors.textOnBlueDim, fontSize: 13),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(children: [
              if (item.source != null) ...[
                const Icon(Icons.public_rounded, color: AppColors.textOnBlueDim, size: 12),
                const SizedBox(width: 4),
                Text(item.source!,
                    style: const TextStyle(color: AppColors.textOnBlueDim, fontSize: 11)),
                const Spacer(),
              ] else const Spacer(),
              const Text('Ler mais',
                  style: TextStyle(color: AppColors.textOnBlue, fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.textOnBlue, size: 14),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── News tile ─────────────────────────────────────────────────
class _NewsTile extends StatelessWidget {
  final NewsItem item;
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
              width: 48, height: 48,
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
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    const Spacer(),
                    if (item.source != null)
                      Text(item.source!,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ]),
                  const SizedBox(height: 4),
                  Text(item.headline,
                      style: const TextStyle(color: AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Detail sheet ──────────────────────────────────────────────
class _NewsDetail extends StatelessWidget {
  final NewsItem item;
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
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          if (item.ticker != null) ...[
            _NewsTag(label: item.ticker!, color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          _NewsTag(label: _catLabel(item.category), color: AppColors.accent),
          const Spacer(),
          Text(item.timeAgo,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
        const SizedBox(height: 12),
        Text(item.headline,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 20,
                fontWeight: FontWeight.w700, height: 1.4)),
        const SizedBox(height: 8),
        Text(item.sub,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.6)),
        if (item.source != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.public_rounded, size: 13, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(item.source!,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
        ],
        const SizedBox(height: 20),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        const Text(
          'A análise indica que o resultado está em linha com os fundamentos '
          'sólidos da empresa. Especialistas recomendam cautela ao avaliar o '
          'momento para novos aportes, considerando o cenário macroeconômico '
          'atual e as perspectivas para o setor.\n\n'
          'Os dados divulgados reforçam a tese de investimento de longo prazo, '
          'mas investidores devem acompanhar de perto os próximos balanços para '
          'confirmar a tendência.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 24),
        if (item.url != null)
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Abrir fonte original'),
          ),
        const SizedBox(height: 12),
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

// ── Loading ───────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 4; i++)
          Container(
            height: 76,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
          ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Não foi possível carregar as notícias',
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 16,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty ─────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.newspaper_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            const Text('Nenhuma notícia nessa categoria',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 15,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 14),
              label: const Text('Recarregar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────
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
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

String _catLabel(String cat) {
  switch (cat) {
    case 'fiis':     return 'FIIs';
    case 'geo':      return 'Geopolítica';
    case 'dividends':return 'Dividendos';
    case 'economy':  return 'Economia';
    default:         return 'Mercado';
  }
}
