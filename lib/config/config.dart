import '../server_model/remote_config_service.dart';

class AppConfig {
  static String get baseUrl => RemoteConfigService().baseUrl;
}

class ApiPoints {
  // User Register and Login
  static String get authentication => '${AppConfig.baseUrl}/register-or-authenticate';

  // users Data
  // static String get usersData => '${AppConfig.baseUrl}/users';
  static String get currentUserData => '${AppConfig.baseUrl}/current-user';
  static String get referralsList => '${AppConfig.baseUrl}/api/user/referrals';

  // Level Data API
  static String get levelUpDateAPI => '${AppConfig.baseUrl}/updateUserLevel';
  static String get levelRewardAPI => '${AppConfig.baseUrl}/claim-reward';

  // Campaigns API Data
  static String get campaignsPost => '${AppConfig.baseUrl}/api/campaigns/post';
  static String get campaignsGet => '${AppConfig.baseUrl}/api/campaigns/currentGet';
  static String get campaignFiltered => '${AppConfig.baseUrl}/api/campaigns/filtered-campaigns';
  static String get campaignsViewers => '${AppConfig.baseUrl}/api/campaigns/viewers';
  static String get campaignsPauseResume => '${AppConfig.baseUrl}/api/campaigns';
  static String get campaignsCompletedDelete => '${AppConfig.baseUrl}/api/campaigns/completed';
  // static String get campaignsAll => '${AppConfig.baseUrl}/api/campaigns/all';

  // Tasks API
  static String get taskComplete => '${AppConfig.baseUrl}/api/task/complete-task';

  // Users Active
  static String get activeUsers => '${AppConfig.baseUrl}/api/activeUsers/trackActiveUsers';

  // Leaderboard API
  static String get leaderboardAPI => '${AppConfig.baseUrl}/api/leaderboard/all';
  static String get leaderboardCheckReward => '${AppConfig.baseUrl}/api/leaderboard/reward-popup';
  static String get leaderboardRewardClaim => '${AppConfig.baseUrl}/api/leaderboard/claim-reward';

  // Daily Reward API
  static String get dailyRewardAPI => '${AppConfig.baseUrl}/api/dailyreward/claim';

  // Ad Reward API
  static String get adReward => '${AppConfig.baseUrl}/api/adsReward/verify-reward';

  // Support Admin
  static String get supportSendMsg => '${AppConfig.baseUrl}/api/support';

  // Premium Subscription
  static String get premiumSubAPi => '${AppConfig.baseUrl}/api/premium/subscribe';

  // Buy Tickets
  static String get buyTickets => '${AppConfig.baseUrl}/api/purchase/buy-tickets';

  // Social Data
  static String get socialInstagramData => '${AppConfig.baseUrl}/api/instagram';

  // App Version Checking
  // static String get appVersionUpdate => '${AppConfig.baseUrl}/api/app-version';
}
