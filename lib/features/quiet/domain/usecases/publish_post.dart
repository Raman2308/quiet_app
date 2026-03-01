import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

class PublishPost {
  final PostRepository repository;

  PublishPost(this.repository);

  Future<Either<Failure, void>> call(Post post) {
    // Future business logic can go here
    // Example: validation, trimming, tagging, AI enhancement
    return repository.addPost(post);
  }
}
