import 'dart:convert';
import 'package:app/config/config.dart';
import 'package:app/pages/sidebar_pages/leaderboard.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LeaderboardReward with ChangeNotifier {
  bool _showPopup = false;
  int? _rank;
  int? _score;
  int? _reward;
  late bool _animation = false;

  bool get showPopup => _showPopup;
  int? get rank => _rank;
  int? get score => _score;
  bool get animation => _animation;
  int? get reward => _reward;

  Future<void> checkRewardPopup() async {
    try {
      final token = await Helper.getAuthToken();
      final response = await http.get(
        Uri.parse(ApiPoints.leaderboardCheckReward),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _showPopup = data['showPopup'] == true;
        _rank = data['rank'];
        _score = data['leaderboardScore'];
        _reward = data['reward'];
      } else {
        _showPopup = false;
      }

    } catch (error) {
      print("❌ Error in checkRewardPopup: $error");
      _showPopup = false;
    }

    notifyListeners();
  }

  Future<bool> claimReward(BuildContext context) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardScreen()));
    try {
      final token = await Helper.getAuthToken();
      final response = await http.post(
        Uri.parse(ApiPoints.leaderboardRewardClaim),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Reward claimed: $data");
        _showPopup = false;
        _animation = true;
        notifyListeners();
        Future.delayed(const Duration(seconds: 5), () {
          _animation = false;
          notifyListeners();
        });
        return true;
      } else {
        final data = json.decode(response.body);
        print("❌ Claim failed: $data");
        return false;
      }
    } catch (error) {
      print("❌ Error in claimReward: $error");
      return false;
    }
  }

}

