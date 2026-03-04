import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../../../../core/entities/auth_token.dart';

/// Exception thrown when remote datasource fails
class RemoteDataSourceException implements Exception {
  final String message;
  RemoteDataSourceException(this.message);

  @override
  String toString() => 'RemoteDataSourceException: $message';
}

/// Remote datasource responsible for auth-related HTTP calls.
class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  /// Call POST /auth/refresh with the provided refresh token and
  /// map the response to an [AuthToken].
  ///
  /// Expected server response (example):
  /// {
  ///   "accessToken": "...",
  ///   "refreshToken": "...",
  ///   "expiresIn": 3600
  /// }
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final resp = await apiClient.post(
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      if (resp == null || resp is! Map) {
        throw RemoteDataSourceException(
          'Invalid response from refresh endpoint',
        );
      }

      final Map<String, dynamic> json = Map<String, dynamic>.from(resp);

      final access =
          json['accessToken'] ?? json['access_token'] ?? json['token'];
      final refresh = json['refreshToken'] ?? json['refresh_token'];

      if (access == null || refresh == null) {
        throw RemoteDataSourceException('Missing tokens in refresh response');
      }

      DateTime expiresAt;
      if (json.containsKey('expiresAt')) {
        final expiresAtRaw = json['expiresAt'];
        if (expiresAtRaw is String) {
          expiresAt = DateTime.parse(expiresAtRaw);
        } else if (expiresAtRaw is int) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtRaw);
        } else {
          expiresAt = DateTime.now().add(const Duration(hours: 1));
        }
      } else if (json.containsKey('expiresIn')) {
        final expiresIn = json['expiresIn'];
        final seconds = expiresIn is int
            ? expiresIn
            : int.tryParse('$expiresIn') ?? 3600;
        expiresAt = DateTime.now().add(Duration(seconds: seconds));
      } else {
        // default to 1 hour if server doesn't provide expiry
        expiresAt = DateTime.now().add(const Duration(hours: 1));
      }

      // Construct AuthToken entity
      final token = AuthToken(
        accessToken: access as String,
        refreshToken: refresh as String,
        expiresAt: expiresAt,
      );

      return token;
    } catch (e) {
      if (e is RemoteDataSourceException) rethrow;
      throw RemoteDataSourceException(e.toString());
    }
  }
}
