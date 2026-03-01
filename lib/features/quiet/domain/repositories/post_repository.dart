import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, void>> addPost(Post post);

  Future<Either<Failure, List<Post>>> getPosts();
}