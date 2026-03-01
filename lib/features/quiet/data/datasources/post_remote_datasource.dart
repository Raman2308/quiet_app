import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/logger/logger.dart';
import '../../domain/entities/post.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<void> addPost(Post post);

  Future<List<Post>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;

  PostRemoteDataSourceImpl(this.firestore, this.logger);

  @override
  Future<void> addPost(Post post) async {
    try {
      final docRef = firestore.collection('posts').doc();
      final model = PostModel(
        id: docRef.id,
        content: post.content,
        createdAt: post.createdAt,
      );
      await docRef.set(model.toJson());
      logger.info('PostRemoteDataSource | addPost | Success');
    } catch (e, st) {
      logger.error(
        'PostRemoteDataSource | addPost | Error',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<List<Post>> getPosts() async {
    try {
      final snapshot = await firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();
      final posts = snapshot.docs
          .map((doc) => PostModel.fromJson(doc.data(), doc.id))
          .toList();
      logger.info('PostRemoteDataSource | getPosts | Success');
      return posts;
    } catch (e, st) {
      logger.error(
        'PostRemoteDataSource | getPosts | Error',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
