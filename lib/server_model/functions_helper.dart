import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/authentication.dart';
import '../main.dart';
import 'dart:convert';

class Helper {
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // If the token is null, refresh the token
    if (token == null) {
      debugPrint('Token is null, refreshing...');
      token = await _refreshToken();
    }

    // If the token is expired, refresh the token
    if (token != null && await _isTokenExpired(token)) {
      debugPrint('Token expired, refreshing...');
      token = await _refreshToken();
    }

    // If token could not be refreshed, log out the user
    if (token == null) {
      await _logoutUser();
    }

    return token;
  }

  // Method to check if token is expired
  static Future<bool> _isTokenExpired(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> payloadMap = jsonDecode(payload);
      final exp = payloadMap['exp'] ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch / 1000;

      return exp <= now;
    } catch (_) {
      return true;
    }
  }

  // Method to refresh the token
  static Future<String?> _refreshToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Refresh the Firebase token
        final refreshedToken = await user.getIdToken(true); // Force token refresh
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', refreshedToken!); // Save the new token
        debugPrint("Token refreshed successfully.");
        return refreshedToken;
      }
    } catch (e) {
      debugPrint("Error refreshing token: $e");
    }
    return null;
  }

  // Method to log out the user
  static Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove token
    await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    debugPrint('User logged out');
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Authentication()), (route) => false,
    );
  }
  static String? getFirebaseEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }
}
