import 'dart:convert';

/// Cache model for market data.
class MarketCache {
  final String key;
  final Map<String, dynamic> value;
  final DateTime expiresAt;
  final DateTime createdAt;

  const MarketCache({
    required this.key,
    required this.value,
    required this.expiresAt,
    required this.createdAt,
  });

  factory MarketCache.fromRow(Map<String, dynamic> row) {
    final rawValue = row['value'];
    Map<String, dynamic> parsedValue;
    if (rawValue is String) {
      parsedValue = jsonDecode(rawValue) as Map<String, dynamic>;
    } else {
      parsedValue = rawValue as Map<String, dynamic>;
    }

    return MarketCache(
      key: row['key'] as String,
      value: parsedValue,
      expiresAt: DateTime.parse(row['expires_at'].toString()),
      createdAt: DateTime.parse(row['created_at'].toString()),
    );
  }
}
