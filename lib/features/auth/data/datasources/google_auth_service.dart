import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "986496188100-3sbm3hrdav5q94eavtm4d171itf621co.apps.googleusercontent.com",
  );

  Future<Either<Failure, User>> signIn() async {
    try {
      UserCredential userCredential;

      /// Web login
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(provider);
      }
      /// Mobile login
      else {
        final googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return Left(AuthFailure("Google login cancelled"));
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user!;

      /// Log provider info
      final providers = user.providerData.map((p) => p.providerId).toList();

      debugPrint("User providers: $providers");

      return Right(user);
    } catch (e) {
      return Left(AuthFailure("Google login failed"));
    }
  }

  /// Link email/password to Google account
  Future<Either<Failure, void>> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return Left(AuthFailure("No logged in user"));
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.linkWithCredential(credential);

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure("Failed to link email/password"));
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception("Google signout failed");
    }
  }
}
