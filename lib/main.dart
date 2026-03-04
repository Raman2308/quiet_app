import 'package:app_quiet/core/security/token_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'app/app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:app_quiet/core/logger/console_logger.dart';
import 'package:app_quiet/core/config/config_provider.dart';
import 'package:app_quiet/core/config/app_config.dart';

void main() async {
  print('[Main] Starting app initialization...');

  WidgetsFlutterBinding.ensureInitialized();
  print('[Main] WidgetsFlutterBinding initialized');

  // ✅ 1️⃣ Initialize App Config FIRST
  ConfigProvider.instance.init(
    AppConfig.dev, // or prod() depending on your setup
  );
  print('[Main] Config initialized');

  // ✅ 2️⃣ Initialize Logger AFTER config
  final systemLogger = ConsoleLogger();
  AppLogger.initialize(systemLogger);
  print('[Main] Logger system initialized');

  try {
    print('[Main] Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Main] Firebase initialized successfully');
  } catch (e, st) {
    AppLogger.appError(
      '[Main] Firebase initialization failed: ${e.toString()}',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }

  print('[Main] Creating service instances...');
  final logger = AppLogger();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final tokenStorage = TokenStorage(); // Create tokenStorage instance

  print('[Main] Setting up dependency injection...');
  final authRepository = AuthRepositoryImpl(
    firebaseAuth,
    firestore,
    tokenStorage,
    logger,
  );
  final authController = AuthController(authRepository);

  print('[Main] Launching app...');
  runApp(QuietApp(authController: authController));
}
