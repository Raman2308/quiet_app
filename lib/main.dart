import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:app_quiet/core/config/config_provider.dart';
import 'package:app_quiet/core/config/app_config.dart';

import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:app_quiet/core/logger/console_logger.dart';

import 'package:app_quiet/core/injection/injection_container.dart';

import 'package:app_quiet/features/auth/presentation/controllers/auth_controller.dart';

import 'package:app_quiet/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =============================
  // APP CONFIG
  // =============================

  ConfigProvider.instance.init(
    AppConfig.dev, // switch to prod() in production
  );

  // =============================
  // LOGGER
  // =============================

  final systemLogger = ConsoleLogger();
  AppLogger.initialize(systemLogger);

  AppLogger.appInfo('[Main] Starting app initialization');

  // =============================
  // FIREBASE
  // =============================

  try {
    AppLogger.appInfo('[Main] Initializing Firebase...');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    AppLogger.appInfo('[Main] Firebase initialized successfully');
  } catch (e, st) {
    AppLogger.appError(
      '[Main] Firebase initialization failed',
      error: e,
      stackTrace: st,
    );
    rethrow;
  }

  // =============================
  // DEPENDENCY INJECTION
  // =============================

  await InjectionContainer.init();

  // =============================
  // AUTH CONTROLLER
  // =============================

  final AuthController authController = InjectionContainer.initAuthController();

  AppLogger.appInfo('[Main] Launching app...');

  // =============================
  // RUN APP
  // =============================

  runApp(QuietApp(authController: authController));
}
