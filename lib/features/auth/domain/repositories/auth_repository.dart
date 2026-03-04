import 'package:app_quiet/core/entities/token.dart';
import 'package:app_quiet/core/entities/token.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Login with email and password, returns AuthToken
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  });

  /// Sign up with email and password, returns AuthToken
  Future<Either<Failure, AuthToken>> signUp({
    required String email,
    required String password,
  });

  /// Refresh the access token using a refresh token
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Get the current cached token (if available)
  Future<AuthToken?> getCachedToken();

  /// Save token locally
  Future<void> saveToken(AuthToken token);

  /// Clear all stored tokens
  Future<void> clearTokens();
}