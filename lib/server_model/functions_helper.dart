import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/authentication.dart';
import '../main.dart';
import 'dart:convert';

class Helper {
  static Future<String?> getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Ye automatically refresh token deta hai agar expire ho gaya ho
      final token = await user.getIdToken();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token!);
      return token;
    } catch (e) {
      debugPrint("Error getting auth token: $e");
      return null;
    }
  }

  static void listenForTokenRefresh() {
    FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (user != null) {
        final newToken = await user.getIdToken();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', newToken!);
        debugPrint('🔄 Token auto refreshed and saved.');
      }
    });
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Authentication()),
          (route) => false,
    );
  }

  static String? getFirebaseEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }
}
