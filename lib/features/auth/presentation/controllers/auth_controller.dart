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
    print('[AuthController] Setting isLoading to true');
    notifyListeners();

    try {
      print('[AuthController] Calling loginUseCase with email: $email');
      await loginUseCase(email: email, password: password);
      print('[AuthController] Login successful for email: $email');
    } catch (e, stackTrace) {
      print('[AuthController] ERROR: Login failed - $e');
      print('[AuthController] Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      print('[AuthController] Setting isLoading to false');
      notifyListeners();
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    print('[AuthController] signUp() called - Email: $email');

    _isLoading = true;
    print('[AuthController] Setting isLoading to true (signUp)');
    notifyListeners();

    try {
      print('[AuthController] Calling repository.signUp with email: $email');
      await repository.signUp(email: email, password: password);
      print('[AuthController] SignUp successful for email: $email');
    } catch (e, stackTrace) {
      print('[AuthController] ERROR: SignUp failed - $e');
      print('[AuthController] Stack trace: $stackTrace');
      rethrow;
    } finally {
      _isLoading = false;
      print('[AuthController] Setting isLoading to false (signUp)');
      notifyListeners();
    }
  }
}
