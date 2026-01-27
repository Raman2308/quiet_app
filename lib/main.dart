import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../screens/writing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCTrIoa5mweHiONqnz-shkwKnSq67GkA3o",
      authDomain: "quiet-app-afa49.firebaseapp.com",
      projectId: "quiet-app-afa49",
      storageBucket: "quiet-app-afa49.firebasestorage.app",
      messagingSenderId: "986496188100",
      appId: "1:986496188100:web:43ea472c9322bb43e6d391",
      measurementId: "G-1KWTFRMCEL",
    ),
  );

  runApp(const QuietApp());
}

class QuietApp extends StatelessWidget {
  const QuietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiet',
      theme: ThemeData.dark(),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const WritingScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
