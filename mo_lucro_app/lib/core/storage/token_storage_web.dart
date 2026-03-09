import 'package:hive_flutter/hive_flutter.dart';

/// Web implementation — uses Hive (IndexedDB under the hood on web).
/// NOTE: Not as secure as native keychain, but web has no equivalent.
const _boxName = 'auth_tokens';

Future<String?> readToken(String key) async {
  final box = await Hive.openBox<String>(_boxName);
  return box.get(key);
}

Future<void> writeToken(String key, String value) async {
  final box = await Hive.openBox<String>(_boxName);
  await box.put(key, value);
}

Future<void> deleteToken(String key) async {
  final box = await Hive.openBox<String>(_boxName);
  await box.delete(key);
}

Future<void> deleteAllTokens() async {
  final box = await Hive.openBox<String>(_boxName);
  await box.clear();
}
