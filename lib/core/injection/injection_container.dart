import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../logger/logger.dart';
import '../logger/console_logger.dart';
import '../logger/app_logger.dart';
import '../security/token_storage.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

import '../../features/quiet/domain/repositories/post_repository.dart';
import '../../features/quiet/data/datasources/post_remote_datasource.dart';
import '../../features/quiet/data/repositories/post_repository_impl.dart';

class InjectionContainer {
  static late final Logger _logger;
  static late final TokenStorage _tokenStorage;
  static late final ApiClient _apiClient;
  static late final AuthRepository _authRepository;
  static late final AuthenticatedApiClient _authenticatedApiClient;

  static Future<void> init() async {
    // ===== Logger =====
    _logger = ConsoleLogger();
    AppLogger.initialize(_logger);

    // ===== TokenStorage (Singleton) =====
    _tokenStorage = TokenStorage();

    // ===== ApiClient (Singleton, no auth initially) =====
    _apiClient = ApiClient(
      baseUrl: 'https://api.example.com', // Update with your actual base URL
    );

    // ===== AuthRepository (Singleton) =====
    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    _authRepository = AuthRepositoryImpl(
      firebaseAuth,
      firestore,
      _tokenStorage,
      _logger,
    );

    // ===== AuthenticatedApiClient (wraps ApiClient + AuthRepository + TokenStorage) =====
    _authenticatedApiClient = AuthenticatedApiClient(
      apiClient: _apiClient,
      authRepository: _authRepository,
      tokenStorage: _tokenStorage,
    );

    // Update ApiClient with auth dependencies for 401 refresh handling
    _apiClient = ApiClient(
      baseUrl: 'https://api.example.com',
      tokenStorage: _tokenStorage,
      authRepository: _authRepository,
    );
  }

  // ===== AUTH =====

  static TokenStorage getTokenStorage() => _tokenStorage;

  static ApiClient getApiClient() => _apiClient;

  static AuthenticatedApiClient getAuthenticatedApiClient() =>
      _authenticatedApiClient;

  static AuthRepository getAuthRepository() => _authRepository;

  static AuthController initAuthController() {
    return AuthController(_authRepository);
  }

  // ===== QUIET =====

  static PostRepository getPostRepository() {
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = PostRemoteDataSourceImpl(firestore, _logger);
    return PostRepositoryImpl(remoteDataSource, _logger);
  }

  static PostRepository initPostRepository() {
    return getPostRepository();
  }
}
