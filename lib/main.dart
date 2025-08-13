import 'package:app/config/authentication.dart';
import 'package:app/pages/sidebar_pages/my_account.dart';
import 'package:app/screen/task_screen/Tiktok_Task/tiktok_task_handler.dart';
import 'package:app/server_model/provider/leaderboard_reward.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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

  await Firebase.initializeApp();

  // 🔹 Initialize Firebase Remote Config
  await RemoteConfigService().initialize();

  // 🔹 Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Get initial notification route
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  final initialRoute = initialMessage?.data['route'];
  if (initialRoute != null) {
    globalPendingRoute = initialRoute;
  }

  // ✅ Run the app and pass initialRoute to MyApp
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LevelUpProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => LeaderboardReward(), lazy: true),
        ChangeNotifierProvider(create: (_) => InternetProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => AllCampaignsProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => CampaignProvider(), lazy: true),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LevelDataProvider(), lazy: true),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  const MyApp({super.key, this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/targetScreen': (context) => const EarnTickets(),
        '/referral': (context) => MyAccount(),
        '/login': (context) => Authentication(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      title: 'Social Task',
      theme: LightThemesSetup.lightTheme,
      darkTheme: DarkThemesSetup.darkTheme,
      themeMode: ThemeMode.system,
      home: Flash(initialRoute: initialRoute),
    );
  }
}
