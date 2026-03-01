import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'logger.dart';

class FirebaseLogger implements Logger {
  final FirebaseCrashlytics crashlytics;

  FirebaseLogger(this.crashlytics);

  @override
  void info(String message) {
    crashlytics.log(message);
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    crashlytics.recordError(
      error ?? message,
      stackTrace,
      reason: message,
    );
  }
}