import '../security/token_storage.dart';
import 'api_client.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/auth_token.dart';

/// Wrapper around [ApiClient] that ensures requests include a valid
/// Authorization header. If the access token is expired it will attempt
/// to refresh it via [AuthRepository.refreshToken], persist the new tokens
/// using [TokenStorage], and retry the original request once.
class AuthenticatedApiClient {
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  AuthenticatedApiClient({
    required this.apiClient,
    required this.authRepository,
    required this.tokenStorage,
  });

  Future<AuthToken?> _getCachedToken() async {
    // Prefer repository cached token (may contain expiry info).
    final repoToken = await authRepository.getCachedToken();
    if (repoToken != null) return repoToken;

    // Fall back to token storage - we only have raw strings here so
    // cannot know expiry. Return null to trigger a refresh attempt.
    final access = await tokenStorage.getAccessToken();
    final refresh = await tokenStorage.getRefreshToken();
    if (access != null && refresh != null) {
      return AuthToken(
        accessToken: access,
        refreshToken: refresh,
        expiresAt: DateTime.now(),
      );
    }
    return null;
  }

  Future<bool> _ensureValidToken() async {
    final token = await _getCachedToken();
    if (token != null && !token.isExpired()) return true;

    // Try to obtain refresh token from either repo token or storage
    final refreshFromRepo = token?.refreshToken;
    final refreshFromStorage = await tokenStorage.getRefreshToken();
    final refresh = refreshFromRepo ?? refreshFromStorage;
    if (refresh == null || refresh.isEmpty) return false;

    final result = await authRepository.refreshToken(refresh);
    return result.fold((_) => false, (newToken) async {
      // Persist tokens
      await tokenStorage.saveAccessToken(newToken.accessToken);
      await tokenStorage.saveRefreshToken(newToken.refreshToken);
      await authRepository.saveToken(newToken);
      return true;
    });
  }

  Map<String, String> _authHeaderForToken(AuthToken? token) {
    if (token == null) return {};
    return {'Authorization': 'Bearer ${token.accessToken}'};
  }

  Future<dynamic> _executeWithAuth(
    Future<dynamic> Function(Map<String, String> headers) request, {
    bool retrying = false,
  }) async {
    // Ensure token valid before first attempt
    await _ensureValidToken();
    var token = await authRepository.getCachedToken();
    if (token == null) {
      // Try token storage fallback
      final access = await tokenStorage.getAccessToken();
      final refresh = await tokenStorage.getRefreshToken();
      if (access != null && refresh != null) {
        token = AuthToken(
          accessToken: access,
          refreshToken: refresh,
          expiresAt: DateTime.now(),
        );
      }
    }

    try {
      return await request(_authHeaderForToken(token));
    } on ApiException catch (e) {
      // If unauthorized, attempt refresh and retry once
      if (e.statusCode == 401 && !retrying) {
        final refreshed = await _ensureValidToken();
        if (!refreshed) rethrow;

        final newToken = await authRepository.getCachedToken();

        return _executeWithAuth(request, retrying: true);
      }
      rethrow;
    }
  }

  // Convenience wrappers mirroring ApiClient methods
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithAuth((authHeaders) {
      final merged = <String, String>{};
      if (headers != null) merged.addAll(headers);
      merged.addAll(authHeaders);
      return apiClient.get(
        path,
        queryParameters: queryParameters,
        headers: merged,
        timeout: timeout,
      );
    });
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithAuth((authHeaders) {
      final merged = <String, String>{};
      if (headers != null) merged.addAll(headers);
      merged.addAll(authHeaders);
      return apiClient.post(
        path,
        body: body,
        queryParameters: queryParameters,
        headers: merged,
        timeout: timeout,
      );
    });
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithAuth((authHeaders) {
      final merged = <String, String>{};
      if (headers != null) merged.addAll(headers);
      merged.addAll(authHeaders);
      return apiClient.put(
        path,
        body: body,
        queryParameters: queryParameters,
        headers: merged,
        timeout: timeout,
      );
    });
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return _executeWithAuth((authHeaders) {
      final merged = <String, String>{};
      if (headers != null) merged.addAll(headers);
      merged.addAll(authHeaders);
      return apiClient.delete(
        path,
        body: body,
        queryParameters: queryParameters,
        headers: merged,
        timeout: timeout,
      );
    });
  }
}
