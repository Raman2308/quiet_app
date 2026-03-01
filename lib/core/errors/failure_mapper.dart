import 'package:firebase_auth/firebase_auth.dart';
import 'failures.dart';

class FailureMapper {
  static Failure mapException(Object error, StackTrace stackTrace) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuth(error);
    }

    return  ServerFailure('Unexpected server error');
  }

  static Failure _mapFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return  AuthFailure('Email already registered');
      case 'invalid-email':
        return  AuthFailure('Invalid email address');
      case 'weak-password':
        return  AuthFailure('Password is too weak');
      case 'user-not-found':
        return  AuthFailure('User not found');
      case 'wrong-password':
        return  AuthFailure('Wrong password');
      default:
        return AuthFailure(e.message ?? 'Authentication failed');
    }
  }
}