import 'package:shared_preferences/shared_preferences.dart';

class AppReviewMode {
  static final AppReviewMode _instance = AppReviewMode._internal();
  factory AppReviewMode() => _instance;
  AppReviewMode._internal();

  static late SharedPreferences _prefs;

  /// App start par sirf 1 dafa call karein
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Kahin bhi direct check karne ke liye
  static bool isEnabled() {
    return _prefs.getBool('review_mode') ?? false;
  }
}
