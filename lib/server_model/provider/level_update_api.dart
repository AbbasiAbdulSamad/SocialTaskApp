import 'dart:convert';
import 'package:app/server_model/provider/users_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../pages/sidebar_pages/level.dart';
import '../LocalNotificationManager.dart';
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
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final userLevel = user!.levelData.level+1;
    final levelReward = user.levelData.levelReward;

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));

    Helper.navigatePush(context, const Level());

    Future.delayed(const Duration(seconds: 2), () async {
      _levelTreasureBox = true;
      notifyListeners();


    Future.delayed(const Duration(seconds: 1), () async{

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
        LocalNotificationManager.saveNotification(
            title: 'Level Up $userLevel 🎉',
            body: '+$levelReward Tickets Level Reward',
            screenId: "Level"
        );
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

    Future.delayed(const Duration(seconds: 1), (){
      _rewardLastAnimation = true;
      notifyListeners();

      Future.delayed(const Duration(seconds: 7), (){
        _levelTreasureBox = false;
        _rewardLastAnimation = false;
        notifyListeners();
      });

    });
    });
    });  // treasurebox On 1 sec delay

  }

}
