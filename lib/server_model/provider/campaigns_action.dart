import 'dart:convert';
import 'package:app/screen/home.dart';
import 'package:app/ui/flash_message.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../LocalNotificationManager.dart';
import '../functions_helper.dart';
import 'campaign_api.dart';

class CampaignsAction with ChangeNotifier{

  bool isLoading = false;

  /// Pause a campaign by ID
  Future<bool> pauseCampaign(BuildContext context, String campaignId) async {
    return _updateCampaignStatus(context, campaignId, "pause");
  }

  /// Resume a paused campaign by ID
  Future<bool> resumeCampaign(BuildContext context, String campaignId) async {
    return _updateCampaignStatus(context, campaignId, "resume");
  }

  /// Internal method to hit pause/resume endpoint
  Future<bool> _updateCampaignStatus(BuildContext context, String campaignId, String action) async {
    try {
      isLoading = true;
      notifyListeners();
      final token = await Helper.getAuthToken();
      if (token == null) {
        debugPrint("❌ Token not found");
        return false;
      }

      final url = Uri.parse('${ApiPoints.campaignsPauseResume}/$campaignId/$action');
      final response = await http.put(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Provider.of<CampaignProvider>(context, listen: false).fetchCampaigns(forceRefresh: true);
        AlertMessage.snackMsg(context: context, message: 'Campaign $action successfully');
        return true;
      } else {debugPrint("❌ Failed to $action campaign: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception during $action: $e");
      return false;
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a completed campaign by ID
  Future<bool> deleteCompletedCampaign(BuildContext context, String campaignId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await Helper.getAuthToken();
      if (token == null) {
        debugPrint("❌ Token not found");
        return false;
      }

      final url = Uri.parse('${ApiPoints.campaignsCompletedDelete}/$campaignId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Helper.navigateAndRemove(context, const Home(onPage: 2));
        AlertMessage.snackMsg(context: context, message: 'Campaign deleted successfully');
        return true;
      } else {
        debugPrint("❌ Failed to delete campaign: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Exception during campaign delete: $e");
      return false;
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> reCreateCampaign({
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
    try {
      isLoading = true;
      notifyListeners();
      // ✅ Validate quantity before proceeding
      if (quantity <= 0) {
        AlertMessage.errorMsg(context, "Quantity must be greater than 10.", "Invalid Input");
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

      if (response.statusCode == 201){
        Helper.navigateAndRemove(context, const Home(onPage: 2));
        AlertMessage.successMsg(context, 'New $social $selectedOption campaign is now active.', 'Success');

        await LocalNotificationManager.saveNotification(
            title: '$social Campaign Recreated',
            body: '$social $quantity $selectedOption',
            screenId: 'Campaigns'
        );
      } else {
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
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      AlertMessage.errorMsg(context, 'Something went wrong, please try again.', 'An Error');
    }finally{
      isLoading = false;
      notifyListeners();
    }
  }
}
