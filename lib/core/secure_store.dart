/// SecureStore — bezpieczne trzymanie sekretów (MODEL_API_KEY, tokeny).
///
/// flutter_secure_storage: Android → Keystore (AES), iOS → Keychain.
/// Zasada: klucz wchodzi przez ekran konfiguracji lub Bridge, zapisany
/// w secure storage, czyszczony na wylogowaniu/zmianie profilu.
/// --dart-define zostaje TYLKO jako dev-override i nigdy nie jest persistowany.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kApiKey = 'alfa.model_api_key';
  static const _kBridgeToken = 'alfa.bridge_token';

  /// Inicjalizacja przy starcie: dev-override (--dart-define) NIE jest zapisywany;
  /// klucz produkcyjny czytany z secure storage nadpisuje pusty config.
  static Future<void> hydrate() async {
    if (AlfaConfig.modelApiKey.isEmpty) {
      final stored = await _storage.read(key: _kApiKey);
      if (stored != null && stored.isNotEmpty) {
        AlfaConfig.modelApiKey = stored;
      }
    }
  }

  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _kApiKey, value: key);
    AlfaConfig.modelApiKey = key;
  }

  static Future<String?> readBridgeToken() => _storage.read(key: _kBridgeToken);

  static Future<void> saveBridgeToken(String token) =>
      _storage.write(key: _kBridgeToken, value: token);

  /// „Nowe życie" — pełny reset profilu: czyści sekrety z urządzenia.
  static Future<void> wipeProfile() async {
    await _storage.deleteAll();
    AlfaConfig.modelApiKey = '';
  }
}
