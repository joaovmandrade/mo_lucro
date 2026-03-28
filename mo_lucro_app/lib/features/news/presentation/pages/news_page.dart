import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/news_article.dart';
import '../../../../providers/news_provider.dart';

/// Financial news screen — displays a minimal, elegant list of news articles.
class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(newsProvider.notifier).loadNews());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias Financeiras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(newsProvider.notifier).loadNews(),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(state.error!, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => ref.read(newsProvider.notifier).loadNews(),
                  child: const Text('Tentar novamente'),
                ),
              ]),
            ),
          );
        }
        if (state.articles.isEmpty) {
          return const Center(
            child: Text('Nenhuma notícia disponível.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(newsProvider.notifier).loadNews(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: state.articles.length,
            separatorBuilder: (_, __) => const Divider(height: 32),
            itemBuilder: (context, i) => _NewsCard(article: state.articles[i]),
          ),
        );
      }),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  const _NewsCard({required this.article});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inHours < 1) return 'Agora';
      if (diff.inHours < 24) return 'Há ${diff.inHours}h';
      return 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _open() async {
    final uri = Uri.tryParse(article.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (if available)
          if (article.imageUrl != null && article.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                article.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Source + time
          Row(children: [
            const Icon(Icons.article_outlined, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              article.source.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 8),
            const Text('·', style: TextStyle(color: AppColors.textTertiary)),
            const SizedBox(width: 8),
            Text(
              _formatDate(article.publishedAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ]),
          const SizedBox(height: 10),

          // Title
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            article.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Read more link
          Row(children: [
            Text(
              'Ler mais',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary.withOpacity(0.9)),
          ]),
        ],
      ),
    );
  }
}
