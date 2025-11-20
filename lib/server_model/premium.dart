import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import 'functions_helper.dart';

class PremiumSubscription {
  static Future<Map<String, dynamic>> subscribeToPremium(String plan) async {
    try {
      String? token = await Helper.getAuthToken();
      if (token == null) {
        return {"error": "User not authenticated"};
      }

      // Send API request to subscribe to premium
      final response = await http.post(
        Uri.parse(ApiPoints.premiumSubAPi),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "plan": plan,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {

        return jsonDecode(response.body);
      } else {
        return {"error": "Failed to subscribe: ${response.body}"}; // Error response
      }
    } catch (e) {
      return {"error": "Error: $e"}; // Handle other errors
    }
  }
}
