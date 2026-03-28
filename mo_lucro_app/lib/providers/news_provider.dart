import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/news_article.dart';
import '../../data/datasources/news_datasource.dart';

class NewsState {
  final bool isLoading;
  final List<NewsArticle> articles;
  final String? error;

  const NewsState({
    this.isLoading = false,
    this.articles = const [],
    this.error,
  });

  NewsState copyWith({bool? isLoading, List<NewsArticle>? articles, String? error}) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      articles: articles ?? this.articles,
      error: error,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NewsDataSource _dataSource;

  NewsNotifier(this._dataSource) : super(const NewsState());

  Future<void> loadNews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final articles = await _dataSource.getNews();
      state = state.copyWith(isLoading: false, articles: articles);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Não foi possível carregar as notícias.');
    }
  }
}

final newsDataSourceProvider = Provider((_) => NewsDataSource());

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.read(newsDataSourceProvider));
});
