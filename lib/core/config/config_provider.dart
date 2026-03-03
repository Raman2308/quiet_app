import 'app_config.dart';

class ConfigProvider {
  static final ConfigProvider instance = ConfigProvider._internal();
  ConfigProvider._internal();

  AppConfig? _config;

  void init(AppConfig config) {
    _config = config;
  }

  AppConfig get config {
    if (_config == null) {
      throw Exception('ConfigProvider not initialized. Call init() first.');
    }
    return _config!;
  }
}
