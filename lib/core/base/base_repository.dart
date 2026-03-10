import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../errors/failures.dart';

import '../logger/logger.dart';

abstract class BaseRepository {
  final Logger logger;
  BaseRepository(this.logger);
  Future<Either<Failure, T>> executeSafely<T>(
    Future<T> Function() action, {
    String? methodName,
    Map<String, dynamic>? data,
  }) async {
    final m = methodName ?? 'unknown';
    // log entry with optional data payload
    logger.info('[$m] start. data: ${data ?? {}}');

    try {
      final result = await action();
      // successful result can be logged for debugging
      logger.info('[$m] success. result: $result');
      return Right(result);
    } catch (e, stackTrace) {
      logger.error('[$methodName] exception', error: e, stackTrace: stackTrace);

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case "user-not-found":
            return Left(AuthFailure("No account found for this email."));

          case "wrong-password":
            return Left(AuthFailure("Incorrect password."));

          case "invalid-credential":
            return Left(
              AuthFailure(
                "This account uses Google Sign-In. Please login with Google.",
              ),
            );

          case "email-already-in-use":
            return Left(
              AuthFailure("Email already registered. Please login instead."),
            );

          default:
            return Left(AuthFailure(e.message ?? "Authentication failed"));
        }
      }

      return Left(ServerFailure("Unexpected error occurred."));
    }
  }
}
