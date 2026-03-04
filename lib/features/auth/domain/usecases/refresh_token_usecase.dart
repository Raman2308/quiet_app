import 'package:app_quiet/core/errors/failures.dart';
import 'package:app_quiet/core/entities/token.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<Either<Failure, AuthToken>> call(String refreshToken) {
    return repository.refreshToken(refreshToken);
  }
}
