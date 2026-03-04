import '../../../../core/base/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logger/logger.dart';
import 'package:app_quiet/features/auth/domain/entities/auth_token.dart';
import '../../../../core/security/token_storage.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends BaseRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final TokenStorage _tokenStorage;

  /// In-memory token cache
  AuthToken? _cachedToken;

  AuthRepositoryImpl(
    this._auth,
    this._firestore,
    this._tokenStorage,
    Logger logger,
  ) : super(logger);

  /// Creates AuthToken from Firebase User
  Future<AuthToken> _createAuthTokenFromUser(User user) async {
    logger.info('Creating AuthToken for user: ${user.uid}');

    final idTokenResult = await user.getIdTokenResult(true);

    final expirationTime =
        idTokenResult.expirationTime ??
        DateTime.now().add(const Duration(hours: 1));

    final now = DateTime.now();
    final timeUntilExpiry = expirationTime.difference(now);

    logger.info(
      'AuthToken created | User: ${user.uid} | '
      'Expires in: ${timeUntilExpiry.inMinutes} minutes | '
      'Expiry: ${expirationTime.toIso8601String()}',
    );

    final token = AuthToken(
      accessToken: idTokenResult.token ?? '',
      refreshToken: user.refreshToken ?? '',
      expiresAt: expirationTime,
    );

    return token;
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

        final user = cred.user!;
        logger.info('User created: ${user.uid}');

        /// Create Firestore user document
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        /// Create token
        final token = await _createAuthTokenFromUser(user);

        /// Cache token
        _cachedToken = token;

        /// Save token securely
        await _tokenStorage.saveAccessToken(token.accessToken);
        await _tokenStorage.saveRefreshToken(token.refreshToken);

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

        final user = cred.user!;
        logger.info('Login successful for user: ${user.uid}');

        final token = await _createAuthTokenFromUser(user);

        /// Cache token
        _cachedToken = token;

        /// Save tokens to secure storage
        await _tokenStorage.saveAccessToken(token.accessToken);
        await _tokenStorage.saveRefreshToken(token.refreshToken);

        logger.info(
          'Login complete | User: ${user.uid} | '
          'Token valid until: ${token.expiresAt.toIso8601String()}',
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
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user logged in');
      }

      logger.info('Refreshing token for user: ${user.uid}');

      final idTokenResult = await user.getIdTokenResult(true);

      final newExpiry =
          idTokenResult.expirationTime ??
          DateTime.now().add(const Duration(hours: 1));

      final token = AuthToken(
        accessToken: idTokenResult.token ?? '',
        refreshToken: user.refreshToken ?? refreshToken,
        expiresAt: newExpiry,
      );

      final oldExpiry = _cachedToken?.expiresAt;

      if (oldExpiry != null) {
        logger.info(
          'Token refreshed | User: ${user.uid} | '
          'Old expiry: ${oldExpiry.toIso8601String()} | '
          'New expiry: ${newExpiry.toIso8601String()}',
        );
      }

      _cachedToken = token;

      await _tokenStorage.saveAccessToken(token.accessToken);
      await _tokenStorage.saveRefreshToken(token.refreshToken);

      return token;
    }, methodName: 'AuthRepository.refreshToken');
  }

  @override
  Future<Either<Failure, void>> logout() {
    final userId = _auth.currentUser?.uid;
    logger.info('Logout initiated for user: $userId');

    return executeSafely(() async {
      _cachedToken = null;

      /// Clear tokens
      await _tokenStorage.clearTokens();

      /// Firebase logout
      await _auth.signOut();

      logger.info('User logged out: $userId');
    }, methodName: 'AuthRepository.logout');
  }

  @override
  Future<AuthToken?> getCachedToken() async {
    if (_cachedToken != null) {
      final isValid = _cachedToken!.expiresAt.isAfter(DateTime.now());

      if (isValid) {
        final remaining = _cachedToken!.expiresAt
            .difference(DateTime.now())
            .inMinutes;

        logger.info('Cached token valid | Expires in $remaining minutes');

        return _cachedToken;
      }

      logger.info(
        'Cached token expired at ${_cachedToken!.expiresAt.toIso8601String()}',
      );
    }

    final user = _auth.currentUser;

    if (user != null) {
      logger.info('Generating new token for user: ${user.uid}');
      _cachedToken = await _createAuthTokenFromUser(user);
      return _cachedToken;
    }

    logger.info('No cached token and no authenticated user');

    return null;
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    logger.info('Saving token | Expiry: ${token.expiresAt.toIso8601String()}');

    _cachedToken = token;

    await _tokenStorage.saveAccessToken(token.accessToken);
    await _tokenStorage.saveRefreshToken(token.refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    logger.info('Clearing all tokens');

    _cachedToken = null;

    await _tokenStorage.clearTokens();
  }
}
