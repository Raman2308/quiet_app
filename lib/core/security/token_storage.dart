import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple secure token storage wrapper using `flutter_secure_storage`.
///
/// Keeps keys private to this class and exposes async methods for saving,
/// retrieving and clearing access/refresh tokens. A `FlutterSecureStorage`
/// instance can be injected for testing.
class TokenStorage {
  final FlutterSecureStorage _secureStorage;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  /// Creates a [TokenStorage]. If [secureStorage] is not provided, a
  /// default `FlutterSecureStorage` instance is used.
  TokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessKey, value: token);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshKey, value: token);
  }

  /// Read access token (returns `null` if not present)
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessKey);
  }

  /// Read refresh token (returns `null` if not present)
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshKey);
  }

  /// Remove both access and refresh tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessKey);
    await _secureStorage.delete(key: _refreshKey);
  }
}
