import 'package:flutter/material.dart';
import 'package:app_quiet/core/logger/app_logger.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/quiet/presentation/writing_screen.dart';
import '../features/quiet/domain/repositories/post_repository.dart';

class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController}) {
    print('[AppRouter] Initialized');
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    print('[AppRouter] generateRoute: ${settings.name}');

    switch (settings.name) {
      case '/':
        print('[AppRouter] Loading login screen');
        return MaterialPageRoute(
          builder: (_) => LoginScreen(authController: authController),
        );

      case '/write':
        print('[AppRouter] Loading writing screen');
        try {
          final postRepository = settings.arguments as PostRepository;
          return MaterialPageRoute(
            builder: (_) => WritingScreen(
              postRepository: postRepository,
              logger: AppLogger(),
            ),
          );
        } catch (e) {
          print('[AppRouter] ERROR: Failed to load writing screen - $e');
          rethrow;
        }

      default:
        print('[AppRouter] Route not found: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
