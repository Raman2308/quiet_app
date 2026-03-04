import 'dart:convert';
import 'package:http/http.dart' as http;

import '../security/token_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

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
    final uri = Uri.parse(baseUrl + path);

    if (queryParams == null) return uri;

    return uri.replace(
      queryParameters: queryParams.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
    );
  }

  Future<Map<String, String>> _buildHeaders([
    Map<String, String>? extra,
  ]) async {
    final headers = {...defaultHeaders};

    if (tokenStorage != null) {
      final token = await tokenStorage!.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (extra != null) headers.addAll(extra);

    return headers;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = await _buildHeaders(headers);

    http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _httpClient
              .get(uri, headers: requestHeaders)
              .timeout(timeout);
          break;

        case 'POST':
          response = await _httpClient
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(timeout);
          break;

        case 'PUT':
          response = await _httpClient
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(timeout);
          break;

        case 'DELETE':
          response = await _httpClient
              .delete(
                uri,
                headers: requestHeaders,
                body: body != null ? json.encode(body) : null,
              )
              .timeout(timeout);
          break;

        default:
          throw Exception("Unsupported HTTP method: $method");
      }

      return _handleResponse(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        final retried = await _tryRefreshAndRetry(() {
          return _request(
            method,
            path,
            body: body,
            queryParameters: queryParameters,
            headers: headers,
          );
        });

        if (retried != null) return retried;
      }

      rethrow;
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _request(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _request(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return _request(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      timeout: timeout,
    );
  }

  Future<dynamic> _tryRefreshAndRetry(
    Future<dynamic> Function() retryBlock,
  ) async {
    if (authRepository == null || tokenStorage == null) return null;

    final refresh = await tokenStorage!.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    final result = await authRepository!.refreshToken(refresh);

    return result.fold((_) => null, (newToken) async {
      await tokenStorage!.saveAccessToken(newToken.accessToken);
      await tokenStorage!.saveRefreshToken(newToken.refreshToken);

      try {
        await authRepository!.saveToken(newToken);
      } catch (_) {}

      return await retryBlock();
    });
  }

  dynamic _handleResponse(http.Response resp) {
    final status = resp.statusCode;

    if (status >= 200 && status < 300) {
      if (resp.body.isEmpty) return null;

      try {
        return json.decode(resp.body);
      } catch (_) {
        return resp.body;
      }
    }

    throw ApiException(
      statusCode: status,
      message: resp.body.isNotEmpty ? resp.body : "HTTP $status",
    );
  }

  void close() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => "ApiException($statusCode): $message";
}
