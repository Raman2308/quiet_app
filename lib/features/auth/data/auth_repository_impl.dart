import '../../../../core/base/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logger/logger.dart';
import '../../../../core/entities/token.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // In-memory token storage (consider using a secure storage solution in production)
  AuthToken? _cachedToken;

  AuthRepositoryImpl(this._auth, this._firestore, Logger logger)
    : super(logger);

  /// Helper method to create AuthToken from FirebaseUser
  Future<AuthToken> _createAuthTokenFromUser(User user) async {
    logger.info('Creating AuthToken for user: ${user.uid}');

    // Get ID token and ID token claims
    final idTokenResult = await user.getIdTokenResult(true);
    final expirationTime =
        idTokenResult.expirationTime ??
        DateTime.now().add(const Duration(hours: 1));

    return AuthToken(
      accessToken: idTokenResult.token ?? '',
      refreshToken: user.refreshToken ?? '',
      expiry: expirationTime,
    );
  }

  @override
  Future<Either<Failure, AuthToken>> signUp({
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

        // Create user document in Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        // Create and cache token
        final token = await _createAuthTokenFromUser(cred.user!);
        _cachedToken = token;

        return token;
      },
      methodName: 'AuthRepository.signUp',
      data: {'email': email},
    );
  }

  @override
  Future<Either<Failure, AuthToken>> login({
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

        // Create and cache token
        final token = await _createAuthTokenFromUser(cred.user!);
        _cachedToken = token;

        return token;
      },
      methodName: 'AuthRepository.login',
      data: {'email': email},
    );
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) {
    logger.info('AuthRepositoryImpl.refreshToken called');

    return executeSafely(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Force refresh of the ID token using the refresh token
      final idTokenResult = await user.getIdTokenResult(true);

      final token = AuthToken(
        accessToken: idTokenResult.token ?? '',
        refreshToken: user.refreshToken ?? refreshToken,
        expiry:
            idTokenResult.expirationTime ??
            DateTime.now().add(const Duration(hours: 1)),
      );

      _cachedToken = token;
      return token;
    }, methodName: 'AuthRepository.refreshToken');
  }

  @override
  Future<Either<Failure, void>> logout() {
    logger.info('AuthRepositoryImpl.logout called');

    return executeSafely(() async {
      _cachedToken = null;
      await _auth.signOut();
    }, methodName: 'AuthRepository.logout');
  }

  @override
  Future<AuthToken?> getCachedToken() async {
    logger.info('AuthRepositoryImpl.getCachedToken called');

    // Check if cached token is still valid
    if (_cachedToken != null && _cachedToken!.expiry.isAfter(DateTime.now())) {
      return _cachedToken;
    }

    // If no cached token or it's expired, try to get from current user
    final user = _auth.currentUser;
    if (user != null) {
      _cachedToken = await _createAuthTokenFromUser(user);
      return _cachedToken;
    }

    return null;
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    logger.info('AuthRepositoryImpl.saveToken called');
    _cachedToken = token;
    // TODO: Implement secure storage (e.g., flutter_secure_storage)
  }

  @override
  Future<void> clearTokens() async {
    logger.info('AuthRepositoryImpl.clearTokens called');
    _cachedToken = null;
    // TODO: Clear from secure storage if implemented
  }
}
