import 'package:app_quiet/core/entities/token.dart';
import 'package:app_quiet/core/errors/failures.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class FakeAuthRepository implements AuthRepository {
  Either<Failure, AuthToken>? loginResult;
  Either<Failure, AuthToken>? signUpResult;
  Either<Failure, AuthToken>? refreshTokenResult;
  AuthToken? cachedToken;

  @override
  Future<Either<Failure, AuthToken>> login({
    required String email,
    required String password,
  }) async {
    return loginResult ??
        Right(
          AuthToken(
            accessToken: 'fake_access_token',
            refreshToken: 'fake_refresh_token',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
  }

  @override
  Future<Either<Failure, AuthToken>> signUp({
    required String email,
    required String password,
  }) async {
    return signUpResult ??
        Right(
          AuthToken(
            accessToken: 'fake_access_token',
            refreshToken: 'fake_refresh_token',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    return refreshTokenResult ??
        Right(
          AuthToken(
            accessToken: 'fake_new_access_token',
            refreshToken: refreshToken,
            expiry: DateTime.now().add(const Duration(hours: 1)),
          ),
        );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    cachedToken = null;
    return const Right(null);
  }

  @override
  Future<AuthToken?> getCachedToken() async {
    return cachedToken;
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    cachedToken = token;
  }

  @override
  Future<void> clearTokens() async {
    cachedToken = null;
  }
}
