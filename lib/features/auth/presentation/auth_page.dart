import 'package:app_quiet/core/logger/app_logger.dart';
import 'package:app_quiet/features/auth/data/datasources/google_auth_service.dart';
import 'package:app_quiet/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final controller = context.watch<AuthController>();

    if (controller.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                Text(
                  "Quiet",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 8),

                Text(
                  isLogin ? "Welcome back" : "Create your account",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          if (isLogin) {
                            controller.login(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          } else {
                            controller.signUp(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                          }
                        },
                  child: controller.isLoading
                      ? const CircularProgressIndicator()
                      : Text(isLogin ? "Login" : "Sign Up"),
                ),

                const SizedBox(height: 16),

                OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text("Continue with Google"),
                  onPressed: () async {
                    final result = await GoogleAuthService().signIn();

                    result.fold(
                      (failure) {
                        AppLogger.appError("Login failed: ${failure.message}");
                      },
                      (user) {
                        AppLogger.appInfo("Logged in: ${user.email}");

                        final controller = context.read<AuthController>();
                        controller.setAuthenticated(user);
                        WidgetsBinding.instance.addPostFrameCallback((_) {});
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign up"
                        : "Already have an account? Login",
                  ),
                ),

                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
