import 'package:app/config/authentication.dart';
import 'package:app/pages/sidebar_pages/buy_tickets.dart';
import 'package:app/pages/sidebar_pages/profile.dart';
import 'package:app/pages/sidebar_pages/premium_account.dart';
import 'package:app/server_model/local_notifications.dart';
import 'package:app/server_model/provider/daily_reward.dart';
import 'package:app/server_model/provider/leaderboard_provider.dart';
import 'package:app/server_model/provider/leaderboard_reward.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'pages/sidebar_pages/earn_rewards.dart';
import 'screen/intro_screen/flash.dart';
import 'server_model/internet_provider.dart';
import 'server_model/level_data_provider.dart';
import 'server_model/provider/campaign_api.dart';
import 'server_model/provider/fetch_taskts.dart';
import 'server_model/provider/level_update_api.dart';
import 'server_model/provider/task_complete.dart';
import 'server_model/provider/users_provider.dart';
import 'server_model/remote_config_service.dart';
import 'server_model/theme/light_theme.dart';
import 'server_model/theme/dark_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? globalPendingRoute;
String? incomingReferralCode;

/// Firebase background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔙 Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppPurchase.instance.isAvailable();

  // 🔹 Initialize notifications and Firebase
  await NotificationService.init();
  await Firebase.initializeApp();

  // 🔹 Background FCM handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Fix: Ensure immersive edge-to-edge layout for Android 12–15
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  ));

  // ⚡️ Initialize services in background
  _initializeServices();

  // ✅ Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeaderboardProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => LevelUpProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => LeaderboardReward(), lazy: true),
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => AllCampaignsProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => CampaignProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LevelDataProvider(), lazy: true),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/dailyReward': (context) => const EarnTickets(),
        '/premium': (context) => const PremiumAccount(),
        '/buyTicket': (context) => const BuyTickets(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: SafeArea(
            top: false, // content status bar ke neeche bhi ja sakta hai
            bottom: true, // navigation bar ke overlap se bachaata hai
            child: child!,
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Social Task',
      theme: LightThemesSetup.lightTheme,
      darkTheme: DarkThemesSetup.darkTheme,
      themeMode: ThemeMode.system,
      home: Flash(initialRoute: globalPendingRoute),
    );
  }
}

/// Background me services initialize
Future<void> _initializeServices() async {
  try {
    await RemoteConfigService().initialize();
  } catch (e) {
    debugPrint("⚠️ RemoteConfig init failed: $e");
  }

  try {
    await InAppPurchase.instance.isAvailable();
  } catch (e) {
    debugPrint("⚠️ InAppPurchase check failed: $e");
  }

  try {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final initialRoute = initialMessage?.data['route'];
    if (initialRoute != null) {
      globalPendingRoute = initialRoute;
    }
  } catch (e) {
    debugPrint("⚠️ Initial FCM message fetch failed: $e");
  }
}
