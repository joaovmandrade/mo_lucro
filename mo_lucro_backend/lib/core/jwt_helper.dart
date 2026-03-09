import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'config.dart';

/// JWT token helper for creating and validating tokens.
class JwtHelper {
  /// Create an access token (short-lived).
  static String createAccessToken(String userId) {
    final jwt = JWT(
      {
        'sub': userId,
        'type': 'access',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: Duration(minutes: AppConfig.jwtAccessExpiryMinutes),
    );
  }

  /// Create a refresh token (long-lived).
  static String createRefreshToken(String userId) {
    final jwt = JWT(
      {
        'sub': userId,
        'type': 'refresh',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(
      SecretKey(AppConfig.jwtSecret),
      expiresIn: Duration(days: AppConfig.jwtRefreshExpiryDays),
    );
  }

  /// Verify a token and return the payload.
  /// Returns null if the token is invalid or expired.
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(AppConfig.jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      print('[JWT] Token expired');
      return null;
    } on JWTException catch (e) {
      print('[JWT] Invalid token: ${e.message}');
      return null;
    }
  }

  /// Extract user ID from a valid token.
  static String? getUserIdFromToken(String token) {
    final payload = verifyToken(token);
    return payload?['sub'] as String?;
  }

  /// Check if token is an access token.
  static bool isAccessToken(String token) {
    final payload = verifyToken(token);
    return payload?['type'] == 'access';
  }

  /// Check if token is a refresh token.
  static bool isRefreshToken(String token) {
    final payload = verifyToken(token);
    return payload?['type'] == 'refresh';
  }
}
