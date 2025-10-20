import 'dart:convert';
import 'package:app/server_model/provider/users_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../ui/flash_message.dart';
import '../functions_helper.dart';
import '../local_notifications.dart';

class DailyRewardService {
  int _reward = 20;

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
      final token = await Helper.getAuthToken();
      if (token == null) {
        AlertMessage.errorMsg(context, "Token not found", "Error!");
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

      if (response.statusCode == 200) {
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ Ab yahan popup close karo
        Navigator.pop(context);

        AlertMessage.successMsg(context, data['message'], "Successfully Claimed");

        NotificationService.showNotification(
          title: '🎉 Daily Reward Claimed!',
          body: 'You earned +$_reward tickets from Daily Reward!',
        );
      } else {
        Navigator.pop(context);
        AlertMessage.errorMsg(context, data['message'] ?? "Unknown error", "Today Claimed");
      }
    } catch (e) {
      Navigator.pop(context);
      AlertMessage.errorMsg(context, "Error: $e", "Error!");
    }
  }
}
