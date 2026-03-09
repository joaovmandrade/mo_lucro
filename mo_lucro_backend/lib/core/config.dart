import 'dart:io';
import 'package:dotenv/dotenv.dart';

/// Application configuration loaded from environment variables.
class AppConfig {
  static DotEnv? _env;

  static void initialize() {
    _env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  }

  // Database
  static String get dbHost => _get('DATABASE_HOST', 'localhost');
  static int get dbPort => int.parse(_get('DATABASE_PORT', '5432'));
  static String get dbName => _get('DATABASE_NAME', 'mo_lucro_db');
  static String get dbUser => _get('DATABASE_USER', 'postgres');
  static String get dbPassword => _get('DATABASE_PASSWORD', 'postgres');

  // JWT
  static String get jwtSecret =>
      _get('JWT_SECRET', 'default-secret-change-me');
  static int get jwtAccessExpiryMinutes =>
      int.parse(_get('JWT_ACCESS_EXPIRY_MINUTES', '15'));
  static int get jwtRefreshExpiryDays =>
      int.parse(_get('JWT_REFRESH_EXPIRY_DAYS', '7'));

  // Server
  static int get port => int.parse(_get('PORT', '8080'));
  static String get environment => _get('ENVIRONMENT', 'development');
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  static String _get(String key, String defaultValue) {
    return _env?[key] ??
        Platform.environment[key] ??
        defaultValue;
  }
}
