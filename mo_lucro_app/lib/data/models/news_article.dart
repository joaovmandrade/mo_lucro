/// NewsArticle data model.
class NewsArticle {
  final String title;
  final String description;
  final String source;
  final String url;
  final String? imageUrl;
  final String publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      source: json['source'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['image'] as String?,
      publishedAt: json['publishedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'source': source,
        'url': url,
        'image': imageUrl,
        'publishedAt': publishedAt,
      };
}
