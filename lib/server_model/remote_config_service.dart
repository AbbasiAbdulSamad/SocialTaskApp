import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/button.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(minutes: 1),
      ),
    );

    await _remoteConfig.setDefaults({
      'api_url': 'http://10.230.117.48:3000',
      // 'api_url': 'https://socialtask-server.fly.dev',
      'minimum_app_version': '1.1.1',
    });

    await _remoteConfig.fetchAndActivate();
  }

  String get baseUrl {
    final baseUrl = _remoteConfig.getString('api_url');
    return baseUrl.isNotEmpty
        ? 'http://10.230.117.48:3000'
        : 'http://10.230.117.48:3000';
        // ? baseUrl
        // : 'https://socialtask-server.fly.dev';
  }

  String get minimumRequiredVersion {
    final version = _remoteConfig.getString('minimum_app_version');
    return version.isNotEmpty ? version : '1.1.1';
  }






  /// 🚀 Check for Update and Show Popup
  Future<void> checkManullayUpdate(BuildContext context) async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Compare versions
      if (_isVersionLower(currentVersion, minimumRequiredVersion)) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  /// Compare versions (e.g., 1.0.8 < 1.0.9)
  bool _isVersionLower(String current, String minRequired) {
    List<int> currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> minParts =
    minRequired.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < minParts.length; i++) {
      if (currentParts[i] < minParts[i]) return true;
      if (currentParts[i] > minParts[i]) return false;
    }
    return false;
  }

  /// Show Update Dialog
  void _showUpdateDialog(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false, // force update
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.all(20),
        shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
        content: Container(
          height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.secondary, theme.secondaryContainer,],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            border: Border.all(color: theme.onPrimaryContainer, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const  Text("New Update Required", style: TextStyle(fontFamily: '3rdRoboto', fontSize: 20, color: Colors.orangeAccent, fontWeight: FontWeight.bold),),
              const SizedBox(height: 20,),
              const Text("New version of the app is available. Please update to continue.", style: TextStyle(color: Colors.white),),

            Row(
              children: [
                const Expanded(child: SizedBox()),
                MyButton(txt: "Update", ico: Icons.android, borderRadius: 40, pading: const EdgeInsets.only(left: 20, right: 20), shadowOn: true,
                    bgColor: theme.onPrimary, borderLineOn: true, borderLineSize: 0.5, borderColor: theme.onPrimaryContainer, txtSize: 16, txtColor: Colors.black,
                    onClick: (){
                      if (Platform.isAndroid) {
                        _launchURL("https://play.google.com/store/apps/details?id=com.socialtask.app");
                      } else if (Platform.isIOS) {
                        _launchURL("https://apps.apple.com/app/idYOUR_APP_ID");
                      }
                    }),
              ],
            )
            ],
          ),
        ),
      ),
    );
  }

  /// Launch store link
  void _launchURL(String url) async {
    // You can use url_launcher package
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}



