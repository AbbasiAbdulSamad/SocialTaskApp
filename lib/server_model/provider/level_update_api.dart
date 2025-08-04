import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../config/config.dart';
import '../../pages/sidebar_pages/level.dart';
import '../functions_helper.dart';

class LevelUpProvider with ChangeNotifier {
  bool _isLoading = false;
  String _message = '';
  bool _levelTreasureBox = false;
  bool _rewardLastAnimation = false;

  bool get isLoading => _isLoading;
  String get message => _message;
  bool get levelTreasureBox => _levelTreasureBox;
  bool get rewardLastAnimation => _rewardLastAnimation;


  Future<void> updateUserLevel() async {
    try {
      _isLoading = true;
      notifyListeners();

      String? token = await Helper.getAuthToken();
      if (token == null){_isLoading = false;
        notifyListeners();
        return;
      }
      String? userEmail = Helper.getFirebaseEmail();

      final response = await http.post(
        Uri.parse(ApiPoints.levelUpDateAPI),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userEmail': userEmail}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _message = "✅ Level Checking: ${responseData['message']}";
      } else {
        _message = "❌ Failed to update level: ${response.body}";
      }
    } catch (error) {
      _message = "⚠️ Error updating level: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 **Function to Claim Level Reward**
  Future<void> claimLevelReward(BuildContext context) async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Level()));

    Future.delayed(const Duration(seconds: 2), () async {
      _levelTreasureBox = true;
      notifyListeners();


    Future.delayed(const Duration(seconds: 2), () async{
    try {
      _isLoading = true;
      notifyListeners();

      // Get Token JWT
      String? token = await Helper.getAuthToken();
      // Check Token Null
      if (token == null){_isLoading = false;
        notifyListeners();
        return;}
      // Get Firebase uid
      String? userEmail = Helper.getFirebaseEmail();

      final response = await http.post(
        Uri.parse(ApiPoints.levelRewardAPI), // ✅ API for claiming reward
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'userEmail': userEmail}),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _message = "🎉 Reward Claimed: ${responseData['message']}";
      } else {
        _message = "❌ Failed to claim reward: ${response.body}";
      }

    } catch (error) {
      _message = "⚠️ Error claiming reward: $error";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    await updateUserLevel();

    Future.delayed(const Duration(milliseconds: 1600), (){
      _levelTreasureBox = false;
      _rewardLastAnimation = true;
      notifyListeners();

      Future.delayed(const Duration(seconds: 4), (){
        _rewardLastAnimation = false;
        notifyListeners();
      });
    });

    });
    });  // treasurebox On 1 sec delay

  }

}
