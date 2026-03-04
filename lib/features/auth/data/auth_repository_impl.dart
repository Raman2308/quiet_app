import '../../../../core/base/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logger/logger.dart';
import '../../../../core/entities/token.dart';
import '../../../../core/security/token_storage.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final TokenStorage _tokenStorage;

  // In-memory token storage (consider using a secure storage solution in production)
  AuthToken? _cachedToken;

  AuthRepositoryImpl(
    this._auth,
    this._firestore,
    this._tokenStorage,
    Logger logger,
  ) : super(logger);

  /// Helper method to create AuthToken from FirebaseUser
  Future<AuthToken> _createAuthTokenFromUser(User user) async {
    logger.info('Creating AuthToken for user: ${user.uid}');

    // Get ID token and ID token claims
    final idTokenResult = await user.getIdTokenResult(true);
    final expirationTime =
        idTokenResult.expirationTime ??
        DateTime.now().add(const Duration(hours: 1));

    // Log token expiration time
    final now = DateTime.now();
    final timeUntilExpiry = expirationTime.difference(now);
    logger.info(
      'AuthToken created | User: ${user.uid} | '
      'Expires in: ${timeUntilExpiry.inMinutes} minutes | '
      'Expiry: ${expirationTime.toIso8601String()}',
    );

    return AuthToken(
      accessToken: idTokenResult.token ?? '',
      refreshToken: user.refreshToken ?? '',
      expiry: expirationTime,
    );
  }

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

        // Create user document in Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'email': cred.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        // Create and cache token
        final token = await _createAuthTokenFromUser(cred.user!);
        _cachedToken = token;

        return cred.user!;
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
        logger.info('Attempting login for email: $email');
        final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        logger.info('Login successful for user: ${cred.user?.uid}');

        // Create and cache token
        final token = await _createAuthTokenFromUser(cred.user!);
        _cachedToken = token;

        logger.info(
          'Login complete | User: ${cred.user?.uid} | '
          'Token valid until: ${token.expiry.toIso8601String()}',
        );

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
      logger.info('Attempting token refresh...');
      final user = _auth.currentUser;
      if (user == null) {
        logger.info('Token refresh failed: No user logged in');
        throw Exception('No user logged in');
      }

      logger.info('Refreshing token for user: ${user.uid}');

      // Force refresh of the ID token using the refresh token
      final idTokenResult = await user.getIdTokenResult(true);
      final newExpiry =
          idTokenResult.expirationTime ??
          DateTime.now().add(const Duration(hours: 1));

      final token = AuthToken(
        accessToken: idTokenResult.token ?? '',
        refreshToken: user.refreshToken ?? refreshToken,
        expiry: newExpiry,
      );

      // Log old vs new token expiry
      final oldExpiry = _cachedToken?.expiry;
      if (oldExpiry != null) {
        logger.info(
          'Token refreshed | User: ${user.uid} | '
          'Old expiry: ${oldExpiry.toIso8601String()} | '
          'New expiry: ${newExpiry.toIso8601String()}',
        );
      }

      _cachedToken = token;
      return token;
    }, methodName: 'AuthRepository.refreshToken');
  }

  @override
  Future<Either<Failure, void>> logout() {
    final userId = _auth.currentUser?.uid;
    logger.info('Logout initiated for user: $userId');

    return executeSafely(() async {
      // Log which user is logging out
      logger.info('Logging out user: $userId');

      _cachedToken = null;

      // Clear tokens from secure storage
      logger.info('Clearing tokens from secure storage...');
      await _tokenStorage.clearTokens();
      logger.info('Tokens cleared from storage');

      // Sign out from Firebase to invalidate session
      logger.info('Signing out from Firebase...');
      await _auth.signOut();
      logger.info('Firebase logout complete for user: $userId');
    }, methodName: 'AuthRepository.logout');
  }

  @override
  Future<AuthToken?> getCachedToken() async {
    // Check if cached token is still valid
    if (_cachedToken != null) {
      final isValid = _cachedToken!.expiry.isAfter(DateTime.now());
      if (isValid) {
        final timeRemaining = _cachedToken!.expiry
            .difference(DateTime.now())
            .inMinutes;
        logger.info(
          'Cached token is valid | Expires in: $timeRemaining minutes',
        );
        return _cachedToken;
      } else {
        // Token has expired
        logger.info(
          'Cached token has expired | '
          'Expiry was: ${_cachedToken!.expiry.toIso8601String()}',
        );
      }
    }

    // If no cached token or it's expired, try to get from current user
    final user = _auth.currentUser;
    if (user != null) {
      logger.info('Retrieving fresh token for user: ${user.uid}');
      _cachedToken = await _createAuthTokenFromUser(user);
      return _cachedToken;
    }

    logger.info('No cached token and no current user available');
    return null;
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    logger.info(
      'Saving token | User token expires at: ${token.expiresAt.toIso8601String()}',
    );
    _cachedToken = token;
    // TODO: Implement secure storage (e.g., flutter_secure_storage)
  }

  @override
  Future<void> clearTokens() async {
    logger.info('Clearing all cached tokens');
    _cachedToken = null;
    // Clear from secure storage as well
    logger.info('Removing tokens from secure storage');
    await _tokenStorage.clearTokens();
    logger.info('All tokens cleared');
  }
}
