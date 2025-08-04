import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(hours: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      // 'api_url': 'https://socialtask-server.fly.dev',
      'minimum_app_version': '1.0.5',
    });

    await _remoteConfig.fetchAndActivate();
  }

  String get baseUrl {
    final baseUrl = _remoteConfig.getString('api_url');
    return baseUrl.isNotEmpty
        ? 'http://10.71.110.75:3000'
        : 'http://10.71.110.75:3000';
        // ? baseUrl
        // : 'https://socialtask-server.fly.dev';
  }

  String get minimumRequiredVersion {
    final version = _remoteConfig.getString('minimum_app_version');
    return version.isNotEmpty ? version : '1.0.5';
  }
}
