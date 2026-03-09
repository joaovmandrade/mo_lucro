import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-based cache repository for offline-first data.
/// Stores JSON-serialized data with TTL (time-to-live) support.
class CacheRepository {
  static const String _cacheBoxName = 'cache';
  static const Duration defaultTTL = Duration(minutes: 30);

  /// Get cached data by key. Returns null if expired or not found.
  static Future<T?> get<T>(String key) async {
    final box = await Hive.openBox(_cacheBoxName);
    final entry = box.get(key) as Map?;
    if (entry == null) return null;

    final expiresAt = DateTime.parse(entry['expiresAt'] as String);
    if (DateTime.now().isAfter(expiresAt)) {
      await box.delete(key);
      return null;
    }

    final data = entry['data'];
    if (data is String) {
      try {
        return jsonDecode(data) as T;
      } catch (_) {
        return data as T;
      }
    }
    return data as T;
  }

  /// Store data with optional TTL.
  static Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final box = await Hive.openBox(_cacheBoxName);
    final expiresAt = DateTime.now().add(ttl ?? defaultTTL);
    await box.put(key, {
      'data': data is Map || data is List ? jsonEncode(data) : data,
      'expiresAt': expiresAt.toIso8601String(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete cached entry.
  static Future<void> delete(String key) async {
    final box = await Hive.openBox(_cacheBoxName);
    await box.delete(key);
  }

  /// Clear all cache.
  static Future<void> clearAll() async {
    final box = await Hive.openBox(_cacheBoxName);
    await box.clear();
  }

  /// Clear cache entries matching a prefix.
  static Future<void> clearByPrefix(String prefix) async {
    final box = await Hive.openBox(_cacheBoxName);
    final keysToDelete = box.keys.where((k) => k.toString().startsWith(prefix));
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  // --- Convenience cache keys ---
  static const String dashboardKey = 'dashboard_data';
  static const String investmentsKey = 'investments_list';
  static const String expensesKey = 'expenses_list';
  static const String expenseSummaryKey = 'expense_summary';
  static const String goalsKey = 'goals_list';
  static const String riskAnalysisKey = 'risk_analysis';
  static const String diversificationKey = 'diversification';
  static const String maturitiesKey = 'maturities';
  static const String profileResultKey = 'profile_result';
  static const String recommendationsKey = 'recommendations';
}

/// Mixin for providers to add caching behavior.
mixin CacheMixin {
  /// Try cache first, then fetch from API. Returns cached data if API fails.
  Future<T?> cacheFirst<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration ttl = const Duration(minutes: 30),
  }) async {
    // Try to get from cache
    final cached = await CacheRepository.get<T>(key);

    try {
      // Fetch fresh data
      final fresh = await fetcher();
      // Update cache
      await CacheRepository.set(key, fresh, ttl: ttl);
      return fresh;
    } catch (e) {
      // Return cached data if available, otherwise rethrow
      if (cached != null) return cached;
      rethrow;
    }
  }
}
