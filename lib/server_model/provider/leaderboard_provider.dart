import 'dart:convert';
import 'package:app/config/config.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LeaderboardProvider with ChangeNotifier {
  List<dynamic> _leaderboard = [];
  List<dynamic> get leaderboard => _leaderboard;

  String? _serverTime;
  String? get serverTime => _serverTime;

  Map<String, dynamic>? _topUser1;
  Map<String, dynamic>? _topUser2;
  Map<String, dynamic>? _topUser3;
  Map<String, dynamic>? get topUser1 => _topUser1;
  Map<String, dynamic>? get topUser2 => _topUser2;
  Map<String, dynamic>? get topUser3 => _topUser3;

  int? _currentUserRank;
  int? get currentUserRank => _currentUserRank;

  Map<String, dynamic>? _currentUserData;
  Map<String, dynamic>? get currentUserData => _currentUserData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await Helper.getAuthToken();
      if (token == null) throw Exception("Firebase token not found");

      final response = await http.get(
        Uri.parse(ApiPoints.leaderboardAPI),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _leaderboard = data['leaderboard'] ?? [];
        _serverTime = data['serverTime'] ?? "";

        debugPrint(_serverTime);

        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final currentUserData = _leaderboard.firstWhere(
                (user) => user['email'] == currentUser.email,
            orElse: () => null,
          );

          _currentUserData = currentUserData;
          _currentUserRank = currentUserData?['rank'] ?? _leaderboard.length + 1;

          if (currentUserData == null) {
            _leaderboard.add({
              'email': currentUser.email,
              'name': currentUser.displayName ?? "You",
              'profile': currentUser.photoURL ?? "",
              'leaderboardScore': 0,
              'rank': _leaderboard.length + 1,
            });
          }
        }

        _leaderboard.sort((a, b) => (a['rank'] ?? 9999).compareTo(b['rank'] ?? 9999));

        _topUser1 = _leaderboard.isNotEmpty ? _leaderboard[0] : {};
        _topUser2 = _leaderboard.length > 1 ? _leaderboard[1] : {};
        _topUser3 = _leaderboard.length > 2 ? _leaderboard[2] : {};
      } else {
        throw Exception("Failed to load leaderboard (Status: ${response.statusCode})");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in LeaderboardProvider: $e");
      }
      _leaderboard = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatLargeNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }
}
