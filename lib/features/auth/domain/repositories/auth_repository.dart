import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
}