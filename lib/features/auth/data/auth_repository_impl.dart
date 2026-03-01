import '../../../../core/base/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logger/logger.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore, Logger logger)
    : super(logger);

  @override
  //Stream<User?> get authStateChanges => _auth.authStateChanges();
  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  }) {
    logger.info('AuthRepositoryImpl.signUp called with email=$email');

    return executeSafely(
      () async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        return cred.user!;
      },
      methodName: 'AuthRepository.signUp',
      data: {'email': email},
    );
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) {
    logger.info('AuthRepositoryImpl.login called with email=$email');

    return executeSafely(
      () async {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        return cred.user!;
      },
      methodName: 'AuthRepository.login',
      data: {'email': email},
    );
  }

  Future<Either<Failure, void>> logout() {
    logger.info('AuthRepositoryImpl.logout called');

    return executeSafely(() async {
      await _auth.signOut();
    }, methodName: 'AuthRepository.logout');
  }
}
