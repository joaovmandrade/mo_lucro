import 'package:bcrypt/bcrypt.dart';

/// Password hashing helper using BCrypt.
class PasswordHelper {
  static const int _rounds = 12;

  /// Hash a plain text password.
  static String hash(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _rounds));
  }

  /// Verify a password against a hash.
  static bool verify(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }
}
