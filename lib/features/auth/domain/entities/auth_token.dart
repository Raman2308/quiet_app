/// Immutable entity representing an authentication token
class AuthToken {
  /// The access token used for API authentication
  final String accessToken;

  /// The refresh token used to obtain a new access token
  final String refreshToken;

  /// The datetime when the access token expires
  final DateTime expiresAt;

  /// Creates an immutable [AuthToken]
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Checks if the token has expired
  bool isExpired() {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Checks if the token is still valid (not expired)
  bool isValid() {
    return !isExpired();
  }

  /// Returns the remaining duration until expiration
  Duration get timeUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return Duration.zero;
    }
    return expiresAt.difference(now);
  }

  @override
  String toString() =>
      'AuthToken('
      'accessToken: ${accessToken.substring(0, 10)}..., '
      'refreshToken: ${refreshToken.substring(0, 10)}..., '
      'expiresAt: $expiresAt)';
}
