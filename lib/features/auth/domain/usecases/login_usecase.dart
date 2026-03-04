import 'package:app_quiet/core/errors/failures.dart';
import 'package:app_quiet/features/auth/domain/entities/auth_token.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthToken>> call({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}
