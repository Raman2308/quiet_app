import 'dart:convert';
import 'package:http/http.dart' as http;
import '../security/token_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// Simple reusable API client supporting GET/POST/PUT/DELETE with JSON
/// encoding/decoding, baseUrl configuration and common headers.
///
/// Designed for Clean Architecture: small, testable, and injectable.
class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _httpClient;
  final TokenStorage? tokenStorage;
  final AuthRepository? authRepository;

  ApiClient({
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
    http.Client? httpClient,
    this.tokenStorage,
    this.authRepository,
  }) : defaultHeaders =
           defaultHeaders ??
           const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
       _httpClient = httpClient ?? http.Client();

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse(baseUrl).replace(
      path: Uri.parse(baseUrl).path + '/$normalizedPath',
      queryParameters: queryParams?.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
    );
    return uri;
  }

  Future<Map<String, String>> _buildHeaders([
    Map<String, String>? extra,
  ]) async {
    final headers = Map<String, String>.from(defaultHeaders);
    if (tokenStorage != null) {
      final access = await tokenStorage!.getAccessToken();
      if (access != null && access.isNotEmpty) {
        headers['Authorization'] = 'Bearer $access';
      }
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);

    try {
      final resp = await _httpClient
          .get(uri, headers: requestHeaders)
          .timeout(timeout ?? const Duration(seconds: 30));

      return _processResponse(resp);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retried = await _tryRefreshAndRetry(() async {
          final refreshedHeaders = await _buildHeaders(headers);
          final retryResp = await _httpClient
              .get(uri, headers: refreshedHeaders)
              .timeout(timeout ?? const Duration(seconds: 30));
          return _processResponse(retryResp);
        });
        if (retried != null) return retried;
      }
      rethrow;
    }
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);
    final payload = body == null ? null : json.encode(body);

    try {
      final resp = await _httpClient
          .post(uri, headers: requestHeaders, body: payload)
          .timeout(timeout ?? const Duration(seconds: 30));

      return _processResponse(resp);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retried = await _tryRefreshAndRetry(() async {
          final refreshedHeaders = await _buildHeaders(headers);
          final retryResp = await _httpClient
              .post(uri, headers: refreshedHeaders, body: payload)
              .timeout(timeout ?? const Duration(seconds: 30));
          return _processResponse(retryResp);
        });
        if (retried != null) return retried;
      }
      rethrow;
    }
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);
    final payload = body == null ? null : json.encode(body);

    try {
      final resp = await _httpClient
          .put(uri, headers: requestHeaders, body: payload)
          .timeout(timeout ?? const Duration(seconds: 30));

      return _processResponse(resp);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retried = await _tryRefreshAndRetry(() async {
          final refreshedHeaders = await _buildHeaders(headers);
          final retryResp = await _httpClient
              .put(uri, headers: refreshedHeaders, body: payload)
              .timeout(timeout ?? const Duration(seconds: 30));
          return _processResponse(retryResp);
        });
        if (retried != null) return retried;
      }
      rethrow;
    }
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);
    final payload = body == null ? null : json.encode(body);

    try {
      final resp = await _httpClient
          .delete(uri, headers: requestHeaders, body: payload)
          .timeout(timeout ?? const Duration(seconds: 30));

      return _processResponse(resp);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retried = await _tryRefreshAndRetry(() async {
          final refreshedHeaders = await _buildHeaders(headers);
          final retryResp = await _httpClient
              .delete(uri, headers: refreshedHeaders, body: payload)
              .timeout(timeout ?? const Duration(seconds: 30));
          return _processResponse(retryResp);
        });
        if (retried != null) return retried;
      }
      rethrow;
    }
  }

  /// Attempt to refresh tokens using the [authRepository] and [tokenStorage]
  /// then execute [retryBlock] if refresh succeeded. Returns the retry
  /// result or null if refresh didn't occur.
  Future<dynamic> _tryRefreshAndRetry(
    Future<dynamic> Function() retryBlock,
  ) async {
    if (authRepository == null || tokenStorage == null) return null;

    final refresh = await tokenStorage!.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    final result = await authRepository!.refreshToken(refresh);
    return await result.fold(
      (failure) async {
        // Refresh failed
        return null;
      },
      (newToken) async {
        // Persist new tokens
        await tokenStorage!.saveAccessToken(newToken.accessToken);
        await tokenStorage!.saveRefreshToken(newToken.refreshToken);
        try {
          await authRepository!.saveToken(newToken);
        } catch (_) {}

        // Retry the original request once
        return await retryBlock();
      },
    );
  }

  dynamic _tryDecodeBody(String body) {
    if (body.isEmpty) return null;
    try {
      return json.decode(body);
    } catch (_) {
      return body;
    }
  }

  dynamic _processResponse(http.Response resp) {
    final code = resp.statusCode;
    final body = resp.body;

    if (code >= 200 && code < 300) {
      return _tryDecodeBody(body);
    }

    // Basic error mapping; repositories can map to domain Failures as needed
    throw ApiException(
      statusCode: code,
      message: body.isNotEmpty ? body : 'HTTP $code',
    );
  }

  /// Close the underlying http client if you created it here.
  void close() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
