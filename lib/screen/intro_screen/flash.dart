import 'dart:async';
import 'dart:io';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:app/pages/sidebar_pages/my_account.dart';
import 'package:app/ui/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import '../../config/authentication.dart';
import '../../config/config.dart';
import '../../server_model/firebase_notifications.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/provider/users_provider.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../server_model/update_checking_playstore.dart';
import '../../ui/flash_message.dart';
import '../home.dart';
import 'onboarding.dart';
import '../../main.dart';

class Flash extends StatefulWidget {
  static const String KEYLOGIN = "login";
  static const String AUTH_TOKEN_KEY = "auth_token";
  final String? initialRoute;

  const Flash({super.key, this.initialRoute});

  @override
  State<Flash> createState() => _FlashState();
}

class _FlashState extends State<Flash> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    checkInstallReferrer();
    VersionChecker().checkAppVersion(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    if (!_initialized && internetProvider.isConnected) {
      _initialized = true;
      _initServices();
    }
  }

  Future<void> _initServices() async {
// 🟡 Request Notification Permission if not granted
    if (await Permission.notification.isDenied || await Permission.notification.isRestricted) {
      await Permission.notification.request();
    }

    bool navigationDone = false;
    Future.delayed(Duration(seconds: 6), () {
      if (!navigationDone) {
        AlertMessage.snackMsg(context: context, message: 'Unstable network connection', time: 3);
      }
    });

    try {
      await setupFirebaseMessagingListeners();
      await _handleNavigation(context);
      navigationDone = true;
    } catch (e) {
      debugPrint("⚠️ Navigation error: $e");
    }
  }

  // ✅ Only Play Store referrer remains
  Future<void> checkInstallReferrer() async {
    try {
      final ReferrerDetails details = await AndroidPlayInstallReferrer.installReferrer;
      final String? referrerUrl = details.installReferrer;

      debugPrint("🎯 Referrer URL: $referrerUrl");

      if (referrerUrl != null && referrerUrl.contains("ref=")) {
        final uri = Uri.splitQueryString(referrerUrl);
        final code = uri['ref'];
        if (code != null && code.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("pending_referral_code", code);
        }
      } else {
        debugPrint("ℹ️ No referral info found in Play Store URL.");
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

    final token = await Helper.getAuthToken();

    if (token != null && token.isNotEmpty) {
      _navigateTo(context, const Home(onPage: 1));

      if (widget.initialRoute != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, widget.initialRoute!);
        });
      }
      final userProvider = Provider.of<UserProvider>(context, listen: false);
           userProvider.fetchCurrentUser();

    } else {
      _navigateTo(context, Authentication());
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pushAndRemoveUntil(
      context, MaterialPageRoute(builder: (_) => screen), (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Consumer<InternetProvider>(
      builder: (context, internetProvider, _) {
        return Scaffold(
          backgroundColor: theme.secondaryContainer,
          body: Container(
            decoration: BoxDecoration(
            gradient: LinearGradient(
            colors: [theme.secondaryContainer, theme.secondary,],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
        ),),
            child: Center(
              child: internetProvider.isConnected
                  ? SizedBox(
                width: 120,
                height: 120,
                child: Image.asset('assets/images/socialtask.webp'),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.asset('assets/images/socialtask.webp'),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 60),
                      const SizedBox(height: 12),
                      const Text(
                        "No Internet Connection",
                        style: TextStyle(color: Colors.white, fontSize: 18),
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
