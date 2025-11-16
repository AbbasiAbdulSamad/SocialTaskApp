import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../screen/home.dart';
import '../../ui/flash_message.dart';
import '../LocalNotificationManager.dart';
import '../functions_helper.dart';

class CampaignProvider with ChangeNotifier {
  List<Map<String, dynamic>> _campaigns = [];
  bool _isLoading = false;
  String _errorMessage = "";

  List<Map<String, dynamic>> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;


  Future<void> fetchCampaigns({bool forceRefresh = false}) async {
    if (!forceRefresh && _campaigns.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = "";
    notifyListeners();


    String? token = await Helper.getAuthToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(ApiPoints.campaignsGet),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );


      if (response.statusCode == 200) {
        List<dynamic> campaigns = jsonDecode(response.body);
        _campaigns = campaigns.cast<Map<String, dynamic>>();
      } else {
        _errorMessage = response.body;
        _campaigns = [];
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      _errorMessage = "Network error!";
      _campaigns = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createCampaign({
    required BuildContext context,
    required String title,
    required String videoUrl,
    required int watchTime,
    required int quantity,
    required String selectedOption,
    required String campaignImg,
    required String social,
    required String catagory,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Validate quantity before proceeding
      if (quantity <= 0) {
        AlertMessage.errorMsg(context, "Quantity must be greater than 10.", "Invalid Input");
        _isLoading = false;
        notifyListeners();
        return;
      }

      String? token = await Helper.getAuthToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse(ApiPoints.campaignsPost),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'videoUrl': videoUrl,
          'watchTime': watchTime,
          'quantity': quantity,
          'selectedOption': selectedOption,
          'campaignImg': campaignImg,
          'social': social,
          'catagory': catagory,
        }),
      );


      if (response.statusCode == 201) {
   // Campaign create success goto Home Page
        Helper.navigateAndRemove(context, const Home(onPage: 2));

   // Success Alert
        AlertMessage.successMsg(context, 'Your $social $selectedOption campaign is now active.', 'Success');
        debugPrint('Created success');
        fetchCampaigns(forceRefresh: true);

      await LocalNotificationManager.saveNotification(
        title: '$social Campaign Created',
        body: '$social $quantity $selectedOption',
        screenId: 'Campaigns'
      );

      } else {
        // ✅ Extract error message from response
        String errorMessage = "Something went wrong, please try again.";
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('error')) {
            errorMessage = errorJson['error'];
          }
        } catch (e) {
          debugPrint("⚠️ Error parsing JSON response: $e");
        }
        // ✅ Show actual error message
        AlertMessage.errorMsg(context, errorMessage, 'Not enough');
        debugPrint('Not enough');
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      AlertMessage.errorMsg(context, 'Something went wrong, please try again.', 'An Error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}