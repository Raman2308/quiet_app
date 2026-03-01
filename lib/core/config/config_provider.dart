import 'app_config.dart';

class ConfigProvider {
  static late AppConfig _config;

  static void initialize(AppConfig config) {
    _config = config;
  }

  static AppConfig get config => _config;
}