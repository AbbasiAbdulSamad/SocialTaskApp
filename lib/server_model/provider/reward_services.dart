import 'dart:convert';
import 'package:app/server_model/provider/users_provider.dart';
import 'package:app/ui/ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../config/config.dart';
import '../../ui/flash_message.dart';
import '../functions_helper.dart';
import '../local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RewardProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _reward = 20;
  int get reward => _reward;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 🎁 Claim Daily Reward
  Future<void> claimDailyReward(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser!;

    if (user.premiumExpiry != null) {
      final expiryDate = DateTime.parse("${user.premiumExpiry}");
      final now = DateTime.now();
      _reward = expiryDate.isAfter(now) ? 100 : 20;
    } else {
      _reward = 20;
    }

    try {
      // ✅ Step 1: Close popup
      Navigator.pop(context);

      // ✅ Step 2: Show loading
      _setLoading(true);

      final token = await Helper.getAuthToken();
      if (token == null) {
        await Future.delayed(const Duration(milliseconds: 200)); // Wait for UI rebuild
        if (context.mounted) {
          AlertMessage.errorMsg(context, "User not found", "Error!");
        }
        _setLoading(false);
        return;
      }

      final response = await http.post(
        Uri.parse(ApiPoints.dailyRewardAPI),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);
      await Future.delayed(const Duration(milliseconds: 300));

      if (response.statusCode == 200) {
        _setLoading(false);
        if (context.mounted) {
          UnityAdsManager.showInterstitialAd(context, _reward);
        }
      } else {
        _setLoading(false);
        if (context.mounted) {
          AlertMessage.errorMsg(
            context,
            data['message'] ?? "Unknown error",
            "Already Claimed",
          );
        }
      }
    } catch (e) {
      _setLoading(false);
      if (context.mounted) {
        AlertMessage.errorMsg(context, "Error: $e", "Error!");
      }
    }
  }


  /// 🎬 Claim Ad Reward (After full video watched)
  Future<void> claimAdsReward(BuildContext context) async {
    try {
      _setLoading(true);
      // 🔹 Firebase token le lo (auth proof)
      final token = await Helper.getAuthToken();

      if (token == null) {
        AlertMessage.errorMsg(context, "User not fount", "Error!");
        _setLoading(false);
        return;
      }

      // 🔹 API call to backend (Node.js)
      final response = await http.post(
        Uri.parse(ApiPoints.adReward),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        AlertMessage.successMsg(
            context, data['message'] ?? "+20 Tickets Reward added!", "Ad Reward");
      } else {
        AlertMessage.errorMsg(
            context, data['message'] ?? "Something went wrong", "Error!");
      }
    } catch (e) {
      AlertMessage.errorMsg(context, "Error: $e", "Error!");
    } finally {
      _setLoading(false);
    }
  }
}
