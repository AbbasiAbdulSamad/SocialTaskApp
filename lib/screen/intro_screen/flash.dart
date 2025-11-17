import 'dart:async';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:app/ui/ads.dart';
import 'package:app/ui/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/authentication.dart';
import '../../server_model/firebase_notifications.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/provider/users_provider.dart';
import '../../server_model/update_checking_playstore.dart';
import '../home.dart';
import 'onboarding.dart';
import '../../main.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Flash extends StatefulWidget {
  static const String KEYLOGIN = "login";
  static const String AUTH_TOKEN_KEY = "auth_token";
  final String? initialRoute;

  const Flash({super.key, this.initialRoute});

  @override
  State<Flash> createState() => _FlashState();
}

class _FlashState extends State<Flash> {
  bool _navigationDone = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1️⃣ Start a 6-sec timer — show "Unstable network" if delay occurs
    Timer(const Duration(seconds: 6), () {
      if (mounted && !_navigationDone) {
        AlertMessage.snackMsg(context: context, message: "Unstable network connection");
      }
    });

    // 2️⃣ Parallel background initialization
    await Future.wait([
      _checkInstallReferrer(),
      _checkRemoteConfig(),
      _requestNotificationPermission(),
      VersionChecker().checkAppVersion(context),
      Future(() => UnityAdsManager.initialize()),
    ]);

    // 3️⃣ Firebase setup (non-blocking)
    unawaited(setupFirebaseMessagingListeners());
    Helper.listenForTokenRefresh();

    // 4️⃣ Navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () async {
      await _handleNavigation(context);
      _navigationDone = true;
    });
  }

  Future<void> _checkRemoteConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getInt("remote_config_last_fetch") ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      const threeDays = 3 * 24 * 60 * 60 * 1000;

      if (now - lastFetchTime < threeDays) {
        debugPrint("🕐 Skipping Remote Config fetch (cached <3 days)");
        return;
      }

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ));

      await remoteConfig.fetchAndActivate();
      await prefs.setInt("remote_config_last_fetch", now);
      debugPrint("✅ Remote Config fetched & activated");
    } catch (e) {
      debugPrint("⚠️ Remote Config error: $e");
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isRestricted) {
      await Permission.notification.request();
    }
  }

  Future<void> _checkInstallReferrer() async {
    try {
      final details = await AndroidPlayInstallReferrer.installReferrer;
      final referrerUrl = details.installReferrer;

      if (referrerUrl != null && referrerUrl.contains("ref=")) {
        final uri = Uri.splitQueryString(referrerUrl);
        final code = uri['ref'];
        if (code != null && code.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("pending_referral_code", code);
          debugPrint("🎯 Referral code saved: $code");
        }
      }
    } catch (e) {
      debugPrint("❌ Install Referrer Error: $e");
    }
  }

  Future<void> _handleNavigation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingViewed = prefs.getBool(Flash.KEYLOGIN) ?? false;

    if (!isOnboardingViewed) {
      _navigateTo(context, const OnBoarding());
      return;
    }

    await FirebaseAuth.instance.authStateChanges().first;
    final token = await Helper.getAuthToken();
    final route = widget.initialRoute ?? globalPendingRoute;

    if (token != null && token.isNotEmpty) {
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, route);
        });
      } else {
        _navigateTo(context, const Home(onPage: 1));
      }

      unawaited(Provider.of<UserProvider>(context, listen: false).fetchCurrentUser());
    } else {
      _navigateTo(context, Authentication());
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    if (!mounted) return;

    Helper.navigateAndRemove(context, screen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Consumer<InternetProvider>(
      builder: (context, internetProvider, _) {
        return Scaffold(
          backgroundColor: theme.secondaryContainer,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff324891), Color(0xff014665)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Center(
              child: internetProvider.isConnected
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/socialtask.png',
                      width: 120, height: 120),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/images/socialtask.png',
                      width: 120, height: 120),
                  Column(
                    children: const [
                      Icon(Icons.wifi_off,
                          color: Colors.white, size: 60),
                      SizedBox(height: 12),
                      Text(
                        "No Internet Connection",
                        style:
                        TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
