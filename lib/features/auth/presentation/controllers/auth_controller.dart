import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_quiet/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_quiet/features/auth/domain/usecases/signup_usecase.dart';
import 'package:app_quiet/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:app_quiet/features/auth/domain/entities/auth_token.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  late final LoginUseCase loginUseCase;
  late final SignUpUseCase signUpUseCase;
  late final RefreshTokenUseCase refreshTokenUseCase;

  AuthToken? _currentToken;
  bool _isLoading = false;
  String? _errorMessage;

  AuthToken? get currentToken => _currentToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentToken != null && !_isTokenExpired();
  String? get errorMessage => _errorMessage;

  AuthController(this.repository) {
    loginUseCase = LoginUseCase(repository);
    signUpUseCase = SignUpUseCase(repository);
    refreshTokenUseCase = RefreshTokenUseCase(repository);
    AppLogger.appInfo(
      '[AuthController] Initialized with repository: ${repository.runtimeType}',
    );
    _initializeToken();
  }

  /// Initialize token from cached token on startup
  Future<void> _initializeToken() async {
    AppLogger.appInfo('[AuthController] Initializing cached token on startup');
    _currentToken = await repository.getCachedToken();
    if (_currentToken != null) {
      if (_isTokenExpired()) {
        AppLogger.appInfo(
          '[AuthController] Cached token expired on startup | '
          'Expiry: ${_currentToken!.expiresAt.toIso8601String()}',
        );
      } else {
        final timeRemaining = _currentToken!.expiresAt
            .difference(DateTime.now())
            .inMinutes;
        AppLogger.appInfo(
          '[AuthController] Cached token restored | '
          'Expires in: $timeRemaining minutes',
        );
      }
    } else {
      AppLogger.appInfo(
        '[AuthController] No cached token available on startup',
      );
    }
    notifyListeners();
  }

  /// Check if the current token has expired
  bool _isTokenExpired() {
    if (_currentToken == null) return true;
    return _currentToken!.expiresAt.isBefore(DateTime.now());
  }

  Future<void> login({required String email, required String password}) async {
    AppLogger.appInfo('[AuthController] Login attempt - Email: $email');

    _isLoading = true;
    notifyListeners();

    final result = await loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        AppLogger.appError('[AuthController] Login failed: ${failure.message}');
        _errorMessage = failure.message;
        _currentToken = null;
      },
      (token) {
        final timeRemaining = token.expiresAt
            .difference(DateTime.now())
            .inMinutes;
        AppLogger.appInfo(
          '[AuthController] Login successful | '
          'Token expires in: $timeRemaining minutes | '
          'Expiry: ${token.expiresAt.toIso8601String()}',
        );
        _currentToken = token;
        _errorMessage = null;
        repository.saveToken(token);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    AppLogger.appInfo('[AuthController] SignUp attempt - Email: $email');

    _isLoading = true;
    notifyListeners();

    final result = await signUpUseCase(email: email, password: password);

    result.fold(
      (failure) {
        AppLogger.appError(
          '[AuthController] SignUp failed: ${failure.message}',
        );
        _errorMessage = failure.message;
        _currentToken = null;
      },
      (token) {
        final timeRemaining = token.expiresAt
            .difference(DateTime.now())
            .inMinutes;
        AppLogger.appInfo(
          '[AuthController] SignUp successful | '
          'Token expires in: $timeRemaining minutes | '
          'Expiry: ${token.expiresAt.toIso8601String()}',
        );
        _currentToken = token;
        _errorMessage = null;
        repository.saveToken(token);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the authentication token
  Future<bool> refreshAuthToken() async {
    if (_currentToken == null) {
      AppLogger.appInfo(
        '[AuthController] Token refresh skipped - No token available',
      );
      return false;
    }

    final currentExpiry = _currentToken!.expiresAt;
    final timeRemaining = currentExpiry.difference(DateTime.now()).inMinutes;
    AppLogger.appInfo(
      '[AuthController] Attempting token refresh | '
      'Current token expires in: $timeRemaining minutes',
    );

    final result = await refreshTokenUseCase(_currentToken!.refreshToken);

    return result.fold(
      (failure) {
        AppLogger.appError(
          '[AuthController] Token refresh failed: ${failure.message}',
        );
        _currentToken = null;
        return false;
      },
      (newToken) {
        final newTimeRemaining = newToken.expiresAt
            .difference(DateTime.now())
            .inMinutes;
        AppLogger.appInfo(
          '[AuthController] Token refresh successful | '
          'Old expiry: ${currentExpiry.toIso8601String()} | '
          'New expiry: ${newToken.expiresAt.toIso8601String()} | '
          'New token expires in: $newTimeRemaining minutes',
        );
        _currentToken = newToken;
        repository.saveToken(newToken);
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> logout() async {
    AppLogger.appInfo('[AuthController] Logout initiated');

    _isLoading = true;
    notifyListeners();

    try {
      await repository.logout();
      AppLogger.appInfo('[AuthController] Repository logout complete');

      await repository.clearTokens();
      AppLogger.appInfo('[AuthController] All tokens cleared');

      _currentToken = null;
      AppLogger.appInfo(
        '[AuthController] Logout successful - User session ended',
      );
    } catch (e) {
      AppLogger.appError('[AuthController] Logout failed: $e', error: e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
