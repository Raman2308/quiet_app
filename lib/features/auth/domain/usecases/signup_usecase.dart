import 'package:app_quiet/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:app_quiet/features/auth/domain/entities/auth_token.dart';

import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, AuthToken>> call({
    required String email,
    required String password,
  }) {
    return repository.signUp(email: email, password: password);
  }
}
