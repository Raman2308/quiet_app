import 'logger.dart';

class ConsoleLogger implements Logger {
  @override
  void info(String message) {
    print('[INFO] $message');
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    print('[ERROR] $message');
    if (error != null) print(error.toString());
    if (stackTrace != null) print(stackTrace.toString());
  }
}
