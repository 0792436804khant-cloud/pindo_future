import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String _tokenKey = 'pindo_future_sanctum_token';
  static String? _inMemoryToken;

  AuthLocalDataSourceImpl({FlutterSecureStorage? secureStorage})
      : secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {
      // In-memory fallback
    }
  }

  @override
  Future<String?> getToken() async {
    if (_inMemoryToken != null) return _inMemoryToken;
    try {
      final token = await secureStorage.read(key: _tokenKey);
      _inMemoryToken = token;
      return token;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  @override
  Future<void> deleteToken() async {
    _inMemoryToken = null;
    try {
      await secureStorage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
