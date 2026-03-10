import 'package:app_quiet/core/injection/injection_container.dart';
import 'package:app_quiet/features/quiet/domain/usecases/publish_post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_quiet/core/logger/app_logger.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/auth_page.dart';

import '../features/quiet/presentation/writing_screen.dart';

class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController}) {
    AppLogger.appInfo('[AppRouter] Initialized');
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    AppLogger.appInfo('[AppRouter] generateRoute: ${settings.name}');

    switch (settings.name) {
      /// AUTH PAGE (Login + Signup)
      case '/':
      case '/auth':
        AppLogger.appInfo('[AppRouter] Loading AuthPage');

        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: authController,
            child: const AuthPage(),
          ),
        );

      /// WRITING SCREEN
      case '/write':
        AppLogger.appInfo('[AppRouter] Loading WritingScreen');
        try {
          final postRepository = InjectionContainer.getPostRepository();

          return MaterialPageRoute(
            builder: (_) => WritingScreen(
              publishPost: PublishPost(postRepository),
              logger: AppLogger(),
            ),
          );
        } catch (e) {
          AppLogger.appError(
            '[AppRouter] Failed to load writing screen',
            error: e,
          );

          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Failed to open writing screen")),
            ),
          );
        }

      /// UNKNOWN ROUTE
      default:
        AppLogger.appInfo('[AppRouter] Route not found: ${settings.name}');

        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
