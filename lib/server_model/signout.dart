import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/authentication.dart';
import '../ui/flash_message.dart';

class SignOut{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  // ✅ Firebase Logout Function
  Future<void> signOutFromFirebase(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      // 🔹 Remove token from SharedPreferences
      var prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Authentication()), (route) => false);
    } catch (e) {
      String errorMessage = handleError(e);
      AlertMessage.errorMsg(context, errorMessage, 'Error');
    }
  }

  // ✅ Better Error Handling
  String handleError(dynamic e) {
    if (e is FirebaseAuthException) {
      return "Authentication error: ${e.message}";
    }
    if (e is http.ClientException) {
      return "Network error! Check your internet connection.";
    }
    if (e.toString().contains("sign_in_canceled")) {
      return "Sign-in canceled! Please try again.";
    }
    if (e.toString().contains("play-services")) {
      return "Google Play Services error! Update and try again.";
    }
    debugPrint('Print::::::::::::: $e');
    return "An unexpected error occurred. Please try again.";
  }
}
