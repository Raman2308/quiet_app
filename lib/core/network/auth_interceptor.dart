import '../security/token_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/auth_token.dart';
import 'api_client.dart';

class AuthInterceptor {
  final TokenStorage tokenStorage;
  final AuthRepository authRepository;

  AuthInterceptor({required this.tokenStorage, required this.authRepository});

  /// Adds Authorization header if access token exists
  Future<Map<String, String>> attachAuthHeader(
    Map<String, String>? headers,
  ) async {
    final accessToken = await tokenStorage.getAccessToken();

    final newHeaders = <String, String>{...?headers};

    if (accessToken != null && accessToken.isNotEmpty) {
      newHeaders['Authorization'] = 'Bearer $accessToken';
    }

    return newHeaders;
  }

  /// Attempts token refresh when a 401 occurs
  Future<bool> refreshIfNeeded(ApiException error) async {
    if (error.statusCode != 401) return false;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final result = await authRepository.refreshToken(refreshToken);

      return await result.fold((_) async => false, (AuthToken newToken) async {
        await tokenStorage.saveAccessToken(newToken.accessToken);
        await tokenStorage.saveRefreshToken(newToken.refreshToken);

        try {
          await authRepository.saveToken(newToken);
        } catch (_) {}

        return true;
      });
    } catch (_) {
      return false;
    }
  }
}
