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
  static const String _bannerId = "Banner_Android";
  static const String _rewardedId = "Rewarded_Android";
  static const String _interstitialId = "Interstitial_Android"; // 🆕 New Interstitial ID

  static bool _rewardedLoaded = false;
  static bool _interstitialLoaded = false; // 🆕 New flag

  /// 🔹 Initialize Unity Ads
  static Future<void> initialize() async {
    await UnityAds.init(
      gameId: _androidGameId,
      testMode: true,
      onComplete: () {
        print("✅ Unity Ads Initialized");
        loadRewardedAd();
        loadInterstitialAd();
      },
      onFailed: (error, message) =>
          print("❌ Unity Ads Init Failed: $error - $message"),
    );
  }

  /// 🔹 Load Rewarded Ad
  static void loadRewardedAd() {
    print("⏳ Loading Rewarded Ad...");
    UnityAds.load(
      placementId: _rewardedId,
      onComplete: (placementId) {
        print("🎉 Rewarded Ad Loaded: $placementId");
        _rewardedLoaded = true;
      },
      onFailed: (placementId, error, message) {
        print("❌ Failed to Load Rewarded Ad: $error - $message");
        _rewardedLoaded = false;
      },
    );
  }

  /// 🔹 Show Rewarded Ad
  static Future<void> showRewardedAd(BuildContext context) async {
    if (!_rewardedLoaded) {
      print("⚠️ Rewarded Ad not loaded yet!");
      loadRewardedAd();
      return;
    }

    UnityAds.showVideoAd(
      placementId: _rewardedId,
      onStart: (placementId) => print('▶️ Rewarded Ad Started: $placementId'),
      onComplete: (placementId) {
        print('✅ Reward Completed: $placementId');
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
    print("⏳ Loading Interstitial Ad...");
    UnityAds.load(
      placementId: _interstitialId,
      onComplete: (placementId) {
        print("🎉 Interstitial Ad Loaded: $placementId");
        _interstitialLoaded = true;
      },
      onFailed: (placementId, error, message) {
        print("❌ Failed to Load Interstitial Ad: $error - $message");
        _interstitialLoaded = false;
      },
    );
  }
  /// 🔹 Show Interstitial Ad
  static Future<void> showInterstitialAd(BuildContext context, int reward) async {
    if (!_interstitialLoaded) {
      print("⚠️ Interstitial Ad not loaded yet!");
      loadInterstitialAd();
      return;
    }
    UnityAds.showVideoAd(
      placementId: _interstitialId,
      onStart: (placementId) => print('▶️ Interstitial Ad Started: $placementId'),
      onClick: (placementId) => print('🖱️ Interstitial Clicked: $placementId'),
      onComplete: (placementId) {

        // Reward Claim Success Message
        AlertMessage.successMsg(context, "Daily Reward +$reward Added Successfully 🎉", "Successfully Claimed", time: 5);

        NotificationService.showNotification(
          title: '🎉 Daily Reward Claimed!',
          body: 'You earned +$reward tickets from Daily Reward!',
        );
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

  /// 🔹 Banner Widget (Reusable)
  static Widget bannerAd({
    Alignment alignment = Alignment.bottomCenter,
  }) {
    return Align(
      alignment: alignment,
      child: UnityBannerAd(
        placementId: _bannerId,
        onLoad: (placementId) => print('✅ Banner Loaded: $placementId'),
        onClick: (placementId) => print('🖱️ Banner Clicked: $placementId'),
        onFailed: (placementId, error, message) =>
            print('❌ Banner Failed: $error $message'),
      ),
    );
  }
}
