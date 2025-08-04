import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../config/config.dart';
import '../functions_helper.dart';
import 'users_veriable.dart';

class UserProvider extends ChangeNotifier {
  List<AppUser> _users = [];
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isCurrentUserLoading = false;
  bool _autoTask = false;

  List<AppUser> get users => _users;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isCurrentUserLoading => _isCurrentUserLoading;
  bool get autoTask => _autoTask;

  /// Update the autoTask value
  void setAutoTask(bool value) {
    _autoTask = value;
    notifyListeners();
  }

  // 🔹 Fetch current user from API
  Future<void> fetchCurrentUser() async {
    _isCurrentUserLoading = true;
    notifyListeners();

    try {
      String? token = await Helper.getAuthToken();
      if (token == null){_isLoading = false;
        notifyListeners();
        return;}

      final response = await http.get(
        Uri.parse(ApiPoints.currentUserData),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          _currentUser = AppUser.fromJson(responseData['user']);
          notifyListeners();
        } else {
          throw Exception('User data not found');
        }
      } else {
        throw Exception('Failed to load current user: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching current user: $e');
      _currentUser = null;
    } finally {
      _isCurrentUserLoading = false;
      notifyListeners(); // 🔄 Update UI
    }
  }

  Future<void> trackActiveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().substring(0, 10); // e.g. "2025-08-03"

    // Check if already tracked today
    final String? lastTrackedDate = prefs.getString('last_tracked_date');
    if (lastTrackedDate == today) {
      debugPrint("📌 User already tracked today. Skipping API call.");
      return;
    }

    String? token = await Helper.getAuthToken();
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiPoints.activeUsers),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Daily active user tracked successfully");
        await prefs.setString('last_tracked_date', today); // Save the date
      } else {
        debugPrint("❌ Failed to track active user: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Exception while tracking active user: $e");
    }
  }
}
