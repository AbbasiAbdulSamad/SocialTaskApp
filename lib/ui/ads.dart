import 'package:app/server_model/provider/reward_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../server_model/local_notifications.dart';
import 'flash_message.dart';

/// 🔹 Universal Unity Ads Manager Widget
/// Easily reusable anywhere in your Flutter app.
class UnityAdsManager {
  // --- Your Unity Game IDs ---
  static const String _androidGameId = "5980273";
  static const String _rewardedId = "Rewarded_Android";
  static const String _interstitialId = "Interstitial_Android";

  static bool _rewardedLoaded = false;
  static bool _interstitialLoaded = false;

  /// 🔹 Initialize Unity Ads
  static Future<void> initialize() async {
    UnityAds.init(
      gameId: _androidGameId,
      testMode: false,
      onComplete: () {
        debugPrint("✅ Unity Ads Initialized");
        loadRewardedAd();
        loadInterstitialAd();
      },
      onFailed: (error, message) =>
          debugPrint("❌ Unity Ads Init Failed: $error - $message"),
    );
  }

  /// 🔹 Load Rewarded Ad
  static void loadRewardedAd() {
    debugPrint("⏳ Loading Rewarded Ad...");
    UnityAds.load(
      placementId: _rewardedId,
      onComplete: (placementId) {
        debugPrint("🎉 Rewarded Ad Loaded: $placementId");
        _rewardedLoaded = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint("❌ Failed to Load Rewarded Ad: $error - $message");
        _rewardedLoaded = false;
      },
    );
  }

  /// 🔹 Show Rewarded Ad
  static Future<void> showRewardedAd(BuildContext context) async {
    if (!_rewardedLoaded) {
      debugPrint("⚠️ Rewarded Ad not loaded yet!");
      loadRewardedAd();
      return;
    }

    UnityAds.showVideoAd(
      placementId: _rewardedId,
      onStart: (placementId) => print('▶️ Rewarded Ad Started: $placementId'),
      onComplete: (placementId) {
        debugPrint('✅ Reward Completed: $placementId');
        if (context.mounted) {
          Provider.of<RewardProvider>(context, listen: false).claimAdsReward(context);
        }

        _rewardedLoaded = false;
        loadRewardedAd();
      },
      onFailed: (placementId, error, message) {
        debugPrint('❌ Ad Failed: $error - $message');
        _rewardedLoaded = false;
        loadRewardedAd();
      },
    );
  }


  /// 🔹 Load Interstitial Ad
  static void loadInterstitialAd() {
    debugPrint("⏳ Loading Interstitial Ad...");
    UnityAds.load(
      placementId: _interstitialId,
      onComplete: (placementId) {
        debugPrint("🎉 Interstitial Ad Loaded: $placementId");
        _interstitialLoaded = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint("❌ Failed to Load Interstitial Ad: $error - $message");
        _interstitialLoaded = false;
      },
    );
  }
  /// 🔹 Show Interstitial Ad
  static Future<void> showInterstitialAd(BuildContext context, int reward) async {
    if (!_interstitialLoaded) {
      debugPrint("⚠️ Interstitial Ad not loaded yet!");
      loadInterstitialAd();
      return;
    }
    UnityAds.showVideoAd(
      placementId: _interstitialId,
      onStart: (placementId) => print('▶️ Interstitial Ad Started: $placementId'),
      onClick: (placementId) => print('🖱️ Interstitial Clicked: $placementId'),
      onComplete: (placementId) {
        _interstitialLoaded = false;
        loadInterstitialAd();
      },
      onFailed: (placementId, error, message) {
        debugPrint('❌ Interstitial Failed: $error - $message');
        _interstitialLoaded = false;
        loadInterstitialAd();
      },
    );
  }
}
