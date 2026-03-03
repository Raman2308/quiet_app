import 'package:app_quiet/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_quiet/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  late final LoginUseCase loginUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthController(this.repository) {
    loginUseCase = LoginUseCase(repository);
    print(
      '[AuthController] Initialized with repository: ${repository.runtimeType}',
    );
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
      },
      (user) {
        // ✅ Success case
        print('[AuthController] Login successful for email: ${user.email}');
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp({required String email, required String password}) async {
    print('[AuthController] signUp() called - Email: $email');

    _isLoading = true;
    notifyListeners();

    final result = await repository.signUp(email: email, password: password);

    result.fold(
      (failure) {
        print('[AuthController] SignUp failed: ${failure.message}');
      },
      (user) {
        print('[AuthController] SignUp successful for email: ${user.email}');
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
