import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logger/logger.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final Logger logger;

  PostRepositoryImpl(this.remoteDataSource, this.logger);

  @override
  Future<Either<Failure, void>> addPost(Post post) async {
    try {
      await remoteDataSource.addPost(post);
      logger.info("PostRepository | addPost | Success");
      return const Right(null);
    } catch (e, stackTrace) {
      logger.error(
        "PostRepository | addPost | Error",
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure("Failed to add post"));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    try {
      final posts = await remoteDataSource.getPosts();
      logger.info("PostRepository | getPosts | Success");
      return Right(posts);
    } catch (e, stackTrace) {
      logger.error(
        "PostRepository | getPosts | Error",
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ServerFailure("Failed to fetch posts"));
    }
  }
}