import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
void main() {
  group('AuthController login', () {
    test('returns Right when repository succeeds', () async {
      // Arrange
      final fakeRepo = FakeAuthRepository();
      final controller = AuthController(fakeRepo);

      final fakeUser = FakeUser(); // we'll define simple fake
      fakeRepo.loginResult = Right(fakeUser);

      // Act
      final result = await controller.login('a', 'b');

      // Assert
      expect(result.isRight(), true);
    });
  }
  test('returns Left when repository fails', () async {
  final fakeRepo = FakeAuthRepository();
  final controller = AuthController(fakeRepo);

  fakeRepo.loginResult =
      Left(AuthFailure('wrong_password', 'Wrong password'));

  final result = await controller.login('a', 'b');

  expect(result.isLeft(), true);
});
  );
}