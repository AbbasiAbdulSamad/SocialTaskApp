import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/config.dart';
import '../../screen/home.dart';
import '../../ui/flash_message.dart';
import '../functions_helper.dart';

class TaskProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = "";

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// 🔥 Task Complete Karne Wali Function
  Future<void> completeTask({
    required BuildContext context,
    required String campaignId,
    required int rewardCoins,
    required int onPage
  }) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    String? token = await Helper.getAuthToken();
    if (token == null){_isLoading = false;
      notifyListeners();
      return;}

    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    try {
      final response = await http.post(
        Uri.parse(ApiPoints.taskComplete),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userEmail': userEmail,
          'campaignId': campaignId,
        }),
      );


      if (response.statusCode == 200) {
        AlertMessage.snackMsg(context: context, message: 'You earned +$rewardCoins tickets!', time: 2);
        Helper.navigateAndRemove(context, Home(onPage: onPage));

      } else {
        // ✅ API Error message extract karo
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? "Failed to complete task!";

        debugPrint("❌ Task Completion Failed: $errorMsg");
        _errorMessage = errorMsg;  // ✅ Store Error Message

        // ✅ Alert Message Show Karo
        AlertMessage.errorMsg(context, errorMsg, 'Error');
        Navigator.pop(context);
      }

    } catch (e) {
      debugPrint("❌ Exception: $e");
      _errorMessage = "Something went wrong!";
      AlertMessage.errorMsg(context, _errorMessage, 'Error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> completeTaskAuto({
    required BuildContext context,
    required String campaignId,
    required int rewardCoins,
    bool autoTask = false
  }) async {
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();

    String? token = await Helper.getAuthToken();
    if (token == null){_isLoading = false;
    notifyListeners();
    return;}

    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    try {
      final response = await http.post(
        Uri.parse(ApiPoints.taskComplete),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userEmail': userEmail,
          'campaignId': campaignId,
          'autoTask': autoTask
        }),
      );


      if (response.statusCode == 200) {
        AlertMessage.snackMsg(context: context, message: 'You earned +$rewardCoins tickets!', time: 2);
      } else {
        // ✅ API Error message extract karo
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMsg = responseData['message'] ?? "Failed to complete task!";
        debugPrint("❌ Task Completion Failed: $errorMsg");
        AlertMessage.errorMsg(context, errorMsg, 'Error');
      }

    } catch (e) {
      AlertMessage.errorMsg(context, "Something went wrong!", 'Error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
