import '../server_model/remote_config_service.dart';

class AppConfig {
  static String get baseUrl => RemoteConfigService().baseUrl;
}
