import 'package:app/server_model/functions_helper.dart';
import 'package:app/server_model/provider/reward_services.dart';
import 'package:app/server_model/provider/leaderboard_reward.dart';
import 'package:app/server_model/rate_app.dart';
import 'package:app/server_model/remote_config_service.dart';
import 'package:app/ui/ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../server_model/provider/fetch_taskts.dart';
import '../server_model/provider/level_update_api.dart';
import '../server_model/provider/users_provider.dart';
import '../server_model/internet_provider.dart';
import '../ui/pop_reward.dart';
import 'update_checking_playstore.dart';

class FetchDataService{
  static bool _isApiCalled = false;

  static Future<void> fetchData(BuildContext context, {bool forceRefresh = false}) async {
    final allCampaignsProvider = Provider.of<AllCampaignsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    final leveUpAPI = Provider.of<LevelUpProvider>(context, listen: false);
    final leaderboardRewardProvider = Provider.of<LeaderboardReward>(context, listen: false);

    if (!internetProvider.isConnected) {
      return;
    }

    // ✅ Step 1: Fetch campaigns first (so UI updates quickly)
    await allCampaignsProvider.fetchAllCampaigns(context: context, forceRefresh: forceRefresh);

    // ✅ Step 2: Run other APIs in the background
    Future.delayed(Duration.zero, () async {
      await Future.wait([
        // userProvider.fetchUsers(),
        userProvider.fetchCurrentUser(),
        leveUpAPI.updateUserLevel(),
        leaderboardRewardProvider.checkRewardPopup(),
      ]);

      // ✅ Step 3: Call `trackActiveUsers()` only once per app session
      if (!_isApiCalled) {
        _isApiCalled = true;
        VersionChecker().checkAppVersion(context);
        RemoteConfigService().checkManullayUpdate(context);
        await userProvider.trackActiveUsers();
        Future.delayed(Duration(seconds: 3), (){
          AppRating().rateApp(context);
        });
      }

      // ✅ Step 4: Check reward claim (avoid null errors)
      if (leaderboardRewardProvider.showPopup) {
        int? rank = leaderboardRewardProvider.rank;
        Future.delayed(Duration(seconds: 1), () {
          if (!context.mounted) return; // ✅ Avoid calling dialog if screen is closed
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => RewardPop.rewardPop(
                  context: context,
                   img: "assets/animations/leaderboard_pop.json",
                  reward: "Rank #$rank",
                  congratulations: "Score ${leaderboardRewardProvider.score}\n+${leaderboardRewardProvider.reward} Tickets",
                  description: "Get your rank reward in the leaderboard",
                  buttonIcon: Icons.leaderboard_outlined,
                  buttonText: 'Claim Reward',
                      apiCall: ()=> leaderboardRewardProvider.claimReward(context)
              ));
        });
      }

      // ✅ Step 4: Check reward claim (avoid null errors)
      if (userProvider.currentUser?.levelData.rewardClaim == false) {
        int reward = userProvider.currentUser!.levelData.levelReward;
        int nextLevel = userProvider.currentUser!.levelData.level + 1;
        Future.delayed(Duration(seconds: 2), () {
          if (!context.mounted) return; // ✅ Avoid calling dialog if screen is closed
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => RewardPop.rewardPop(
              context: context,
              useForLevel: true,
              level: nextLevel,
              img: "assets/animations/levelUpPopup.json",
              reward: "+$reward Tickets",
              description: "Unlock the next level and claim Reward",
              buttonIcon: Icons.leaderboard,
              buttonText: 'Unlock Level',
                  apiCall: () {
                Provider.of<LevelUpProvider>(context, listen: false).claimLevelReward(context);
              },
            ),
          );
        });
      }
    });
  }
}
