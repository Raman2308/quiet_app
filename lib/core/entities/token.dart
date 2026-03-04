class AuthToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });
}
