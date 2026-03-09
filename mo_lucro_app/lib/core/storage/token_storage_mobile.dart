import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mobile implementation — uses FlutterSecureStorage (encrypted keychain/keystore).
const _storage = FlutterSecureStorage();

Future<String?> readToken(String key) => _storage.read(key: key);
Future<void> writeToken(String key, String value) =>
    _storage.write(key: key, value: value);
Future<void> deleteToken(String key) => _storage.delete(key: key);
Future<void> deleteAllTokens() => _storage.deleteAll();
