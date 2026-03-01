class FakeAuthRepository implements AuthRepository {
  Either<Failure, User>? loginResult;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    return loginResult!;
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() async {
    throw UnimplementedError();
  }
}