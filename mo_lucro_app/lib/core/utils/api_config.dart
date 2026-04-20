import 'package:flutter/foundation.dart';

/// Centralizes API URL resolution for local dev and emulator usage.
class ApiConfig {
  static const _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) {
      return _baseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8080';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://127.0.0.1:8080';
  }

  static String get apiV1BaseUrl => '$baseUrl/api/v1';
}
