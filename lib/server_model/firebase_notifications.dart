import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'LocalNotificationManager.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'Used for Social Task alerts.',
  importance: Importance.high,
);

Future<void> setupFirebaseMessagingListeners() async {
  // Initialize local notification
  const AndroidInitializationSettings androidSettings =
  const AndroidInitializationSettings('notification_icon');
  final InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final route = response.payload;
      if (route != null) {
        globalPendingRoute = route;
      }
    },
  );

  // Create notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // ✅ Foreground message (app open, show + save)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final route = message.data['route'] ?? '';

    if (notification != null && android != null) {
      // 🔔 Show local notification
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'notification_icon',
          ),
        ),
        payload: route,
      );

      // 💾 Save notification locally
      await LocalNotificationManager.saveNotification(
        title: notification.title ?? 'No Title',
        body: notification.body ?? 'No Body',
        screenId: route,
      );
    }
  });

  // ✅ Background / Resumed state (app opened by tapping notification)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    final route = message.data['route'] ?? '';

    // 💾 Save notification (so even background-opened ones are stored)
    final notification = message.notification;
    if (notification != null) {
      await LocalNotificationManager.saveNotification(
        title: notification.title ?? 'No Title',
        body: notification.body ?? '',
        screenId: route,
      );
    }

    // Set navigation route
    if (route.isNotEmpty && globalPendingRoute == null) {
      globalPendingRoute = route;
    }
  });
}
