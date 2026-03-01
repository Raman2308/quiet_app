import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('[LoginScreen] State initialized');
  }

  void _login() {
    final email = emailController.text;
    final password = passwordController.text;

    print('[LoginScreen] Login attempt - Email: $email');

    if (email.isEmpty || password.isEmpty) {
      print('[LoginScreen] WARNING: Email or password is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    print('[LoginScreen] Calling authController.login()');
    widget.authController.login(email: email, password: password);
  }

  void _signup() {
    final email = emailController.text;
    final password = passwordController.text;

    print('[LoginScreen] SignUp attempt - Email: $email');

    if (email.isEmpty || password.isEmpty) {
      print('[LoginScreen] WARNING: Email or password is empty (signup)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    print('[LoginScreen] Calling authController.signUp()');
    widget.authController.signUp(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    print('[LoginScreen] Building login screen UI');

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _signup,
                  child: const Text("Sign up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('[LoginScreen] Disposing login screen');
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
