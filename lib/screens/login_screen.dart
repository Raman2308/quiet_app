import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool isLogin = true;
  bool loading = false;
  String error = '';

  Future<void> handleAuth() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      if (isLogin) {
        await auth.login(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await auth.signUp(
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } catch (e) {
      setState(() => error = e.toString());
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Quiet",
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 10),
      Semantics(
                   label: 'login-button',
                   button: true,
              child:  ElevatedButton(
                  key: const Key('loginButton'),
                onPressed: loading ? null : handleAuth,
                child: Text(
                  loading
                      ? "Please wait..."
                      : isLogin
                      ? "Login"
                      : "Sign Up",
                ),
              ),
            ),  

              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : "Already have an account? Login",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
