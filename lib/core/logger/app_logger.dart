import '../config/config_provider.dart';
import 'logger.dart';

class AppLogger implements Logger {
  // Global logger used by static helpers and instances
  static late Logger _globalLogger;

  /// Initialize the global logger (called from InjectionContainer)
  static void initialize(Logger logger) {
    _globalLogger = logger;
  }

  /// Static convenience: used in places that call AppLogger.info(...)
  static void appInfo(String message) {
    if (!ConfigProvider.config.enableDebugLogs) return;
    _globalLogger.info(message);
  }

  static void appError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _globalLogger.error(message, error: error, stackTrace: stackTrace);
  }

  // Instance methods implement Logger so AppLogger can be passed where
  // a Logger implementation is required (e.g., repositories).
  @override
  void info(String message) => AppLogger.appInfo(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.appError(message, error: error, stackTrace: stackTrace);
}
