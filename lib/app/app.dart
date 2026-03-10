import 'package:app_quiet/core/injection/injection_container.dart';
import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:app_quiet/features/auth/presentation/auth_page.dart';
import 'package:app_quiet/features/quiet/domain/usecases/publish_post.dart';
import 'package:app_quiet/features/quiet/presentation/writing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';

import 'package:provider/provider.dart';

class QuietApp extends StatelessWidget {
  final AuthController authController;

  const QuietApp({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthController>.value(
      value: authController,
      child: MaterialApp(
        title: 'Quiet App',
        debugShowCheckedModeBanner: false,

        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            /// user logged in
            if (snapshot.hasData) {
              return WritingScreen(
                publishPost: PublishPost(
                  InjectionContainer.getPostRepository(),
                ),
                logger: AppLogger(),
              );
            }

            /// user logged out
            return const AuthPage();
          },
        ),
      ),
    );
  }
}
