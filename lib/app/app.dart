import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'router.dart';

class QuietApp extends StatelessWidget {
  final AuthController authController;

  const QuietApp({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    AppLogger.appInfo('[QuietApp] Created with AuthController');

    AppLogger.appInfo('[QuietApp] Building app UI...');
    return MaterialApp(
      title: 'Quiet App',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        AppLogger.appInfo('[QuietApp] Generating route for: ${settings.name}');
        return AppRouter(
          authController: authController,
        ).generateRoute(settings);
      },
    );
  }
}
