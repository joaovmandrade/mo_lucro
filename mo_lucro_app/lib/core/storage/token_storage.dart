import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

// Conditional import for secure storage (mobile only)
import 'token_storage_mobile.dart'
    if (dart.library.html) 'token_storage_web.dart' as platform;

/// Cross-platform token storage abstraction.
/// Uses FlutterSecureStorage on mobile and Hive on web.
class TokenStorage {
  static Future<String?> read(String key) => platform.readToken(key);
  static Future<void> write(String key, String value) =>
      platform.writeToken(key, value);
  static Future<void> delete(String key) => platform.deleteToken(key);
  static Future<void> deleteAll() => platform.deleteAllTokens();
}
