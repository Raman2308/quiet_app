import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/logger/logger.dart';
import '../../domain/entities/post.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<void> addPost(Post post);
  Future<List<Post>> getPosts(String userId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  final Logger logger;

  PostRemoteDataSourceImpl(this.firestore, this.logger);

  @override
  Future<void> addPost(Post post) async {
    try {
      logger.info("RemoteDataSource | Before Firestore write1");

      final docRef = FirebaseFirestore.instance;
      logger.info("RemoteDataSource | Before Firestore write2");

      final model = PostModel(
        id: docRef.databaseId,
        content: post.content,
        createdAt: post.createdAt,
        userId: post.userId,
      );
      logger.info("RemoteDataSource | Before Firestore write3");

      final data = model.toJson();
      // data['id'] = docRef.id;

      logger.info("Firestore data being written: $data");

      logger.info("Writing post with userId: ${post.userId}");
      logger.info("Data being sent: ${model.toJson()}");
      try {
        await firestore
            .collection('posts')
            .add(data)
            .timeout(const Duration(seconds: 10));
      } on FirebaseException catch (e) {
        logger.error("Firestore error: ${e.code} ${e.message}");
        rethrow;
      }
      logger.info("RemoteDataSource | After Firestore write");
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
  Future<List<Post>> getPosts(String userId) async {
    try {
      final snapshot = await firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
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
