import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class AddPost {
  final PostRepository repository;

  AddPost(this.repository);

  Future<Either<Failure, void>> call(Post post) {
    return repository.addPost(post);
  }
}