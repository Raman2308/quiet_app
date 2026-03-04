import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:app_quiet/features/auth/presentation/controllers/auth_controller.dart';
import 'package:app_quiet/core/entities/token.dart';
import 'package:app_quiet/core/errors/failures.dart';
import '../../fake_repository.dart';

void main() {
  group('AuthController login', () {
    test('stores token when login succeeds', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      final fakeToken = AuthToken(
        accessToken: 'test_access',
        refreshToken: 'test_refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      fakeRepo.loginResult = Right(fakeToken);

      // Act
      await controller.login(email: 'test@example.com', password: 'password');

      // Assert
      expect(controller.isAuthenticated, true);
      expect(controller.currentToken, fakeToken);
    });

    test('clears token when login fails', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      fakeRepo.loginResult = Left(
        AuthFailure('wrong_password', 'Wrong password'),
      );

      // Act
      await controller.login(email: 'test@example.com', password: 'wrong');

      // Assert
      expect(controller.isAuthenticated, false);
      expect(controller.currentToken, null);
    });
  });

  group('AuthController signup', () {
    test('stores token when signup succeeds', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      final fakeToken = AuthToken(
        accessToken: 'test_access',
        refreshToken: 'test_refresh',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      fakeRepo.signUpResult = Right(fakeToken);

      // Act
      await controller.signUp(email: 'test@example.com', password: 'password');

      // Assert
      expect(controller.isAuthenticated, true);
      expect(controller.currentToken, fakeToken);
    });
  });

  group('AuthController refreshToken', () {
    test('updates token when refresh succeeds', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      final oldToken = AuthToken(
        accessToken: 'old_access',
        refreshToken: 'refresh_token',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      
      // Set initial cached token
      fakeRepo.cachedToken = oldToken;
      await controller.saveToken(oldToken);

      final newToken = AuthToken(
        accessToken: 'new_access',
        refreshToken: 'refresh_token',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      fakeRepo.refreshTokenResult = Right(newToken);

      // Act
      final success = await controller.refreshAuthToken();

      // Assert
      expect(success, true);
      expect(controller.currentToken, newToken);
    });

    test('returns false when refresh fails', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      final token = AuthToken(
        accessToken: 'access',
        refreshToken: 'refresh_token',
        expiry: DateTime.now().add(const Duration(hours: 1)),
      );
      
      fakeRepo.cachedToken = token;
      await controller.saveToken(token);

      fakeRepo.refreshTokenResult = Left(
        AuthFailure('token_expired', 'Token expired'),
      );

      // Act
      final success = await controller.refreshAuthToken();

      // Assert
      expect(success, false);
      expect(controller.currentToken, null);
    });
  });
}

