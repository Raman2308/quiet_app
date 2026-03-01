enum Environment { dev, prod }

class AppConfig {
  final Environment environment;
  final bool enableDebugLogs;

  const AppConfig({
    required this.environment,
    required this.enableDebugLogs,
  });

  static const dev = AppConfig(
    environment: Environment.dev,
    enableDebugLogs: true,
  );

  static const prod = AppConfig(
    environment: Environment.prod,
    enableDebugLogs: false,
  );
}