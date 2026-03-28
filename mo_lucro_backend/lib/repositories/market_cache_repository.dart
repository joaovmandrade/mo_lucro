import 'dart:convert';
import '../core/database.dart';

/// Repository for market cache access.
class MarketCacheRepository {
  /// Get cached value if not expired.
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final result = await Database.query(
        '''
        SELECT value FROM market_cache 
        WHERE key = @key AND expires_at > CURRENT_TIMESTAMP
        ''',
        parameters: {'key': key},
      );
      
      if (result.isEmpty) return null;
      
      final rowValue = result.first.toColumnMap()['value'];
      if (rowValue is String) {
        return jsonDecode(rowValue) as Map<String, dynamic>;
      }
      return rowValue as Map<String, dynamic>;
    } catch (e) {
      print('[MarketCacheRepository] Database get error: $e');
      return null;
    }
  }

  /// Set cache value with time to live.
  Future<void> set(String key, Map<String, dynamic> value, Duration ttl) async {
    try {
      final expiresAt = DateTime.now().add(ttl).toUtc();
      final jsonValue = jsonEncode(value);
      
      await Database.query(
        '''
        INSERT INTO market_cache (key, value, expires_at)
        VALUES (@key, @value::jsonb, @expiresAt)
        ON CONFLICT (key) DO UPDATE 
        SET value = EXCLUDED.value,
            expires_at = EXCLUDED.expires_at,
            created_at = CURRENT_TIMESTAMP
        ''',
        parameters: {
          'key': key,
          'value': jsonValue,
          'expiresAt': expiresAt.toIso8601String(),
        },
      );
    } catch (e) {
      print('[MarketCacheRepository] Database set error: $e');
    }
  }
}
