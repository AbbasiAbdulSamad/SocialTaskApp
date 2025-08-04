class AppUser {
  final String uid;
  final String name;
  final String email;
  final String profile;
  final int coin;
  final int leaderboardScore;
  final int youtubeTasks;
  final int tiktokTasks;
  final int instagramTasks;
  final int webTasks;
  final int campaigns;
  final int campaignLimit;
  final int autoLimit;
  final DateTime premiumExpiry;
  final String referralCode;
  final List<String> referral;
  final String country;
  final String dailyRewardAt;
  final String accountCreate;
  final LevelData levelData;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profile,
    required this.coin,
    required this.leaderboardScore,
    required this.youtubeTasks,
    required this.tiktokTasks,
    required this.instagramTasks,
    required this.webTasks,
    required this.campaigns,
    required this.campaignLimit,
    required this.autoLimit,
    required this.premiumExpiry,
    required this.referralCode,
    required this.referral,
    required this.country,
    required this.dailyRewardAt,
    required this.accountCreate,
    required this.levelData,
  });

  bool get isPremium => premiumExpiry.isAfter(DateTime.now());

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final tasks = json['tasks'] as Map<String, dynamic>? ?? {};

    return AppUser(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      email: json['email'] as String? ?? 'No Email',
      profile: json['profile'] as String? ?? 'No Profile',
      coin: json['coin'] as int? ?? 0,
      leaderboardScore: json['leaderboardScore'] as int? ?? 0,
      youtubeTasks: tasks['youtubeTasks'] as int? ?? 0,
      tiktokTasks: tasks['tiktokTasks'] as int? ?? 0,
      instagramTasks: tasks['instagramTasks'] as int? ?? 0,
      webTasks: tasks['webTasks'] as int? ?? 0,
      campaigns: json['campaigns'] as int? ?? 0,
      campaignLimit: json['campaignLimit'] as int? ?? 10,
      autoLimit: json['autoLimit'] as int? ?? 25,
      premiumExpiry: DateTime.tryParse(json['premiumExpiry'] ?? '') ?? DateTime(2000),
      referralCode: json['referralCode'] as String? ?? '',
      referral: (json['referral'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      country: json['country'] as String? ?? "Pakistan",
      dailyRewardAt: json['dailyRewardAt'] as String? ?? DateTime.now().toIso8601String(),
      accountCreate: json['accountCreate'] as String? ?? DateTime.now().toIso8601String(),
      levelData: LevelData.fromJson(json['levelData'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class LevelData {
  final int level;
  final int levelReward;
  final bool rewardClaim;
  final int targetScore;
  final int achieveScore;
  final LevelSteps levelSteps;

  LevelData({
    required this.level,
    required this.levelReward,
    required this.rewardClaim,
    required this.targetScore,
    required this.achieveScore,
    required this.levelSteps,
  });

  factory LevelData.fromJson(Map<String, dynamic> json) {
    return LevelData(
      level: json['level'] as int? ?? 1,
      levelReward: json['levelReward'] as int? ?? 0,
      rewardClaim: json['rewardClaim'] as bool? ?? false,
      targetScore: json['targetScore'] as int? ?? 200,
      achieveScore: json['achieveScore'] as int? ?? 0,
      levelSteps: LevelSteps.fromJson(json['levelSteps'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class LevelSteps {
  final List<bool> first;
  final List<bool> last;
  final List<bool> past;

  LevelSteps({
    required this.first,
    required this.last,
    required this.past,
  });

  factory LevelSteps.fromJson(Map<String, dynamic> json) {
    return LevelSteps(
      first: (json['first'] as List<dynamic>? ?? [true, false, true])
          .map((e) => e as bool)
          .toList(),
      last: (json['last'] as List<dynamic>? ?? [false, false, true])
          .map((e) => e as bool)
          .toList(),
      past: (json['past'] as List<dynamic>? ?? [true, false, false])
          .map((e) => e as bool)
          .toList(),
    );
  }
}
