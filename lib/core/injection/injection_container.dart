import 'package:cloud_firestore/cloud_firestore.dart';

import '../logger/logger.dart';
import '../logger/console_logger.dart';

import '../logger/app_logger.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

import '../../features/quiet/domain/repositories/post_repository.dart';
import '../../features/quiet/data/datasources/post_remote_datasource.dart';
import '../../features/quiet/data/repositories/post_repository_impl.dart';

class InjectionContainer {
  static late final Logger _logger;

  static Future<void> init() async {
    // Choose logger (for now console)
    _logger = ConsoleLogger();

    AppLogger.initialize(_logger);
  }

  // ===== AUTH =====

  static AuthController initAuthController(AuthRepository repository) {
    return AuthController(repository);
  }

  // ===== QUIET =====

  static PostRepository initPostRepository() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = PostRemoteDataSourceImpl(firestore, _logger);

    return PostRepositoryImpl(remoteDataSource, _logger);
  }
}
