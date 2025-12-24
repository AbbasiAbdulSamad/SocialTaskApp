class ApiPoints {
  // 🔥 Base URL (local or production)

  static const String baseUrl = "https://socialtask-server.fly.dev";

  // ---------------- USER AUTH ----------------
  static String get authentication => "$baseUrl/register-or-authenticate";

  // ---------------- USER DATA ----------------
  static String get currentUserData => "$baseUrl/current-user";
  static String get referralsList => "$baseUrl/api/user/referrals";

  // ---------------- LEVEL SYSTEM -------------
  static String get levelUpDateAPI => "$baseUrl/updateUserLevel";
  static String get levelRewardAPI => "$baseUrl/claim-reward";

  // ---------------- CAMPAIGNS ----------------
  static String get campaignsPost => "$baseUrl/api/campaigns/post";
  static String get campaignsGet => "$baseUrl/api/campaigns/currentGet";
  static String get campaignFiltered => "$baseUrl/api/campaigns/filtered-campaigns";
  static String get campaignsViewers => "$baseUrl/api/campaigns/viewers";
  static String get campaignsPauseResume => "$baseUrl/api/campaigns";
  static String get campaignsCompletedDelete => "$baseUrl/api/campaigns/completed";

  // ---------------- TASKS --------------------
  static String get taskComplete => "$baseUrl/api/task/complete-task";

  // ---------------- ACTIVE USERS -------------
  static String get activeUsers => "$baseUrl/api/activeUsers/trackActiveUsers";

  // ---------------- LEADERBOARD --------------
  static String get leaderboardAPI => "$baseUrl/api/leaderboard/all";
  static String get leaderboardCheckReward => "$baseUrl/api/leaderboard/reward-popup";
  static String get leaderboardRewardClaim => "$baseUrl/api/leaderboard/claim-reward";

  // ---------------- DAILY REWARD -------------
  static String get dailyRewardAPI => "$baseUrl/api/dailyreward/claim";

  // ---------------- ADS REWARD ---------------
  static String get adReward => "$baseUrl/api/adsReward/verify-reward";

  // ---------------- SUPPORT ADMIN ------------
  static String get supportSendMsg => "$baseUrl/api/support";

  // ---------------- PREMIUM SUBSCRIPTION -----
  static String get premiumSubAPi => "$baseUrl/api/premium/subscribe";

  // ---------------- BUY TICKETS --------------
  static String get buyTickets => "$baseUrl/api/purchase/buy-tickets";

  // ---------------- SOCIAL DATA --------------
  static String get socialInstagramData => "$baseUrl/api/instagram";
  static String get tiktokTaskCheck => "$baseUrl/api/tiktok/tiktok-check-task";
  static String get tiktokTaskVerify => "$baseUrl/api/tiktok/tiktok-verify-task";
}
