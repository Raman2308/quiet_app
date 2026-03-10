import 'package:firebase_auth/firebase_auth.dart';
import 'failures.dart';

class FailureMapper {
  static Failure mapException(Object error, StackTrace stackTrace) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuth(error);
    }

    return ServerFailure('Unexpected server error');
  }

  static Failure _mapFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthFailure('Invalid email address');

      case 'user-disabled':
        return AuthFailure('User account disabled');

      case 'user-not-found':
        return AuthFailure('User not found');

      case 'wrong-password':
        return AuthFailure('Wrong password');

      case 'email-already-in-use':
        return AuthFailure('Email already registered');

      case 'weak-password':
        return AuthFailure('Password is too weak');

      case 'network-request-failed':
        return NetworkFailure('Network error');

      default:
        return AuthFailure(e.message ?? 'Authentication failed');
    }
  }
}
