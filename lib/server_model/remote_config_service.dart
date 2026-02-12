import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ui/button.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(days: 5),
        ),
      );

      // Defaults
      await _remoteConfig.setDefaults({
        'minimum_app_version': '2.5.0',
        'review_mode': true,
      });

      final prefs = await SharedPreferences.getInstance();
      bool? storedReviewMode = prefs.getBool('review_mode');

      // Agar false already stored → skip Remote Config
      if (storedReviewMode == false) return;

      // Fetch Remote Config
      await _remoteConfig.fetchAndActivate();
      bool remoteReviewMode = _remoteConfig.getBool('review_mode');

      if (remoteReviewMode != storedReviewMode) {
        // True → store, False → store once and lock
        await prefs.setBool('review_mode', remoteReviewMode);
      }

    } catch (e, s) {
      debugPrint("🔥 Remote Config error: $e");
      debugPrint("$s");

      // fallback defaults + SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('review_mode', true);
    }
  }

  /// Version Getter
  String get minimumRequiredVersion {
    final version = _remoteConfig.getString('minimum_app_version');
    return version.isNotEmpty ? version : '2.5.0';
  }

  /// SharedPreferences based Review Mode
  Future<bool> get isReviewMode async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('review_mode') ?? true;
  }

  /// Version Update Check
  Future<void> checkManullayUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      if (_isVersionLower(currentVersion, minimumRequiredVersion)) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  bool _isVersionLower(String current, String minRequired) {
    List<int> currentParts =
    current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> minParts =
    minRequired.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < minParts.length; i++) {
      if (i >= currentParts.length) return true;
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
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.secondary, theme.secondaryContainer],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(color: theme.onPrimaryContainer, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "New Update Required",
                  style: TextStyle(
                      fontFamily: '3rdRoboto',
                      fontSize: 20,
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "New version of the app is available. Please update to continue.",
                  style: TextStyle(color: Colors.white),
                ),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    MyButton(
                      txt: "Update",
                      ico: Icons.android,
                      borderRadius: 40,
                      pading:
                      const EdgeInsets.only(left: 20, right: 20),
                      shadowOn: true,
                      bgColor: theme.onPrimary,
                      borderLineOn: true,
                      borderLineSize: 0.5,
                      borderColor: theme.onPrimaryContainer,
                      txtSize: 16,
                      txtColor: Colors.black,
                      onClick: () {
                        if (Platform.isAndroid) {
                          _launchURL(
                              "https://play.google.com/store/apps/details?id=com.socialtask.app");
                        } else if (Platform.isIOS) {
                          _launchURL("https://apps.apple.com/app/");
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Launch store link
  void _launchURL(String url) async {
    await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  }
}
