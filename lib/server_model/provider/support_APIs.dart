import 'dart:convert';
import 'package:app/config/config.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:http/http.dart' as http;

class SupportService {
  // 📨 Create support ticket
  static Future<Map<String, dynamic>> createTicket({
    required String category,
    required String subject,
    required String message,
  }) async {
    try {
      final token = await Helper.getAuthToken();

      final Map<String, dynamic> body = {
        "category": category,
        "subject": subject,
        "message": message,
      };

      final response = await http.post(
        Uri.parse("${ApiPoints.supportSendMsg}/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data["success"] == true) {
        return {"success": true, "data": data["ticket"]};
      } else {
        return {"success": false, "error": data["error"] ?? "Failed to create ticket"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // 📋 Get all tickets for logged-in user
  static Future<Map<String, dynamic>> getUserTickets() async {
    try {
      final token = await Helper.getAuthToken();

      final response = await http.get(
        Uri.parse("${ApiPoints.supportSendMsg}/user"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "tickets": data};
      } else {
        return {"success": false, "error": data["error"] ?? "Failed to fetch tickets"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // ❌ Delete ticket
  static Future<Map<String, dynamic>> deleteTicket(String ticketId) async {
    try {
      final token = await Helper.getAuthToken();

      final response = await http.delete(
        Uri.parse("${ApiPoints.supportSendMsg}/delete/$ticketId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"]};
      } else {
        return {"success": false, "error": data["error"] ?? "Failed to delete ticket"};
      }
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

}
