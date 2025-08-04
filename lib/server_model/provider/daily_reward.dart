import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../config/config.dart';
import '../../ui/flash_message.dart';
import '../functions_helper.dart';

class DailyRewardService {
  Future<void> claimDailyReward(BuildContext context) async {
    try {
      String? token = await Helper.getAuthToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse(ApiPoints.dailyRewardAPI),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AlertMessage.successMsg(context, data['message'], "Successfully Claimed");
      } else {
        final errorData = jsonDecode(response.body);
        AlertMessage.errorMsg(context, errorData['message'], "Today Claimed");
      }
    } catch (e) {
      AlertMessage.errorMsg(context, "Error: $e", "Error!");
    }
    Navigator.pop(context);
  }
}
