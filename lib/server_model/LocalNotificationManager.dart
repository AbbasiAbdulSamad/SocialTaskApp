import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notifications.dart';

class LocalNotificationManager {
  static const String _key = 'local_notifications';
  static const String _countKey = 'notification_count';

  /// Show notification and save locally with current date
  /// Stores screenId as string for navigation
  static Future<void> saveNotification({
    required String title,
    required String body,
    required String screenId,
  }) async {
    // 2️⃣ Get SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];

    // 3️⃣ Prepare notification map
    final notificationMap = {
      'title': title,
      'body': body,
      'date': DateTime.now().toIso8601String(),
      'screenId': screenId ?? "",
    };

    // 4️⃣ Add new notification
    stored.add(jsonEncode(notificationMap));

    // 5️⃣ Keep only last 15 days notifications
    final now = DateTime.now();
    final List<String> filtered = stored.where((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      final date = DateTime.tryParse(map['date'] ?? '') ?? now;
      return now.difference(date).inDays <= 15;
    }).toList();

    // 6️⃣ Save filtered list
    await prefs.setStringList(_key, filtered);

    // 7️⃣ Increment notification count
    int count = prefs.getInt(_countKey) ?? 0;
    count++;
    await prefs.setInt(_countKey, count);
  }

  /// Retrieve notifications (latest first)
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_key) ?? [];
    return stored
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  /// Get current notification count
  static Future<int> getNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countKey) ?? 0;
  }

  /// Reset notification count to 0 (call when page opens)
  static Future<void> resetNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
  }

  /// 🔥 Delete all saved notifications (use on logout)
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_countKey);
  }
}
