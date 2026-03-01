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

void main() async {
  print('[Main] Starting app initialization...');

  WidgetsFlutterBinding.ensureInitialized();
  print('[Main] WidgetsFlutterBinding initialized');

  // initialize a concrete logger so AppLogger static helpers can be used
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
    print('[Main] ERROR: Firebase initialization failed');
    rethrow;
  }

  // 2️⃣ Then create instances
  print('[Main] Creating service instances...');
  final logger = AppLogger();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  print('[Main] Service instances created');

  // 3️⃣ Dependency injection
  print('[Main] Setting up dependency injection...');
  final authRepository = AuthRepositoryImpl(firebaseAuth, firestore, logger);
  final authController = AuthController(authRepository);
  print('[Main] Dependency injection complete');

  print('[Main] Launching app...');
  runApp(QuietApp(authController: authController));
}
