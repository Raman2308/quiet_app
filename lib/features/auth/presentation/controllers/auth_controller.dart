import 'package:app_quiet/core/entities/token.dart';
import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_quiet/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_quiet/features/auth/domain/usecases/signup_usecase.dart';
import 'package:app_quiet/features/auth/domain/usecases/refresh_token_usecase.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  late final LoginUseCase loginUseCase;
  late final SignUpUseCase signUpUseCase;
  late final RefreshTokenUseCase refreshTokenUseCase;

  AuthToken? _currentToken;
  bool _isLoading = false;

  AuthToken? get currentToken => _currentToken;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentToken != null && !_isTokenExpired();

  AuthController(this.repository) {
    loginUseCase = LoginUseCase(repository);
    signUpUseCase = SignUpUseCase(repository);
    refreshTokenUseCase = RefreshTokenUseCase(repository);
    print(
      '[AuthController] Initialized with repository: ${repository.runtimeType}',
    );
    _initializeToken();
  }

  /// Initialize token from cached token on startup
  Future<void> _initializeToken() async {
    _currentToken = await repository.getCachedToken();
    notifyListeners();
  }

  /// Check if the current token has expired
  bool _isTokenExpired() {
    if (_currentToken == null) return true;
    return _currentToken!.expiry.isBefore(DateTime.now());
  }

  Future<void> login({required String email, required String password}) async {
    print('[AuthController] login() called - Email: $email');

    _isLoading = true;
    notifyListeners();

    final result = await loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        // ❌ Failure case
        print('[AuthController] Login failed: ${failure.message}');
        _currentToken = null;
      },
      (token) {
        // ✅ Success case
        print(
          '[AuthController] Login successful - Token expires at: ${token.expiry}',
        );
        _currentToken = token;
        repository.saveToken(token);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    print('[AuthController] signUp() called - Email: $email');

    _isLoading = true;
    notifyListeners();

    final result = await signUpUseCase(email: email, password: password);

    result.fold(
      (failure) {
        print('[AuthController] SignUp failed: ${failure.message}');
        _currentToken = null;
      },
      (token) {
        print(
          '[AuthController] SignUp successful - Token expires at: ${token.expiry}',
        );
        _currentToken = token;
        repository.saveToken(token);
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh the authentication token
  Future<bool> refreshAuthToken() async {
    if (_currentToken == null) {
      print('[AuthController] No token to refresh');
      return false;
    }

    print('[AuthController] Refreshing token...');

    final result = await refreshTokenUseCase(_currentToken!.refreshToken);

    return result.fold(
      (failure) {
        print('[AuthController] Token refresh failed: ${failure.message}');
        _currentToken = null;
        return false;
      },
      (token) {
        print('[AuthController] Token refreshed - New expiry: ${token.expiry}');
        _currentToken = token;
        repository.saveToken(token);
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> logout() async {
    print('[AuthController] logout() called');

    _isLoading = true;
    notifyListeners();

    await repository.logout();
    await repository.clearTokens();
    _currentToken = null;

    _isLoading = false;
    notifyListeners();
  }
}
