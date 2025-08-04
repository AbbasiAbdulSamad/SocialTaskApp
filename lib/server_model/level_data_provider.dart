import 'package:flutter/material.dart';

class LevelDataProvider extends ChangeNotifier {
  int _level = 0;
  int _referral = 0;
  int _campaigns = 0;
  int _targetScore = 0;
  int _userScore = 0;
  int _reward = 0;
  int get level => _level;
  int get referral => _referral;
  int get campaigns => _campaigns;
  int get targetScore => _targetScore;
  int get userScore => _userScore;
  int get reward => _reward;
  List<Map<String, dynamic>> _levelStep = [];
  List<Map<String, dynamic>> _levelData = [];
  List<Map<String, dynamic>> get levelStep => _levelStep;
  List<Map<String, dynamic>> get levelData => _levelData;

  LevelDataProvider(){
    _updateLevelData();
    notifyListeners();
  }

  // Get Leve from APi to Show Icons and other level data
  void findLevelFromAPI(int getLevel, int getReferral, int getCampaigns, int getTargetScore, int getreward, int getuserScore) {
    _level=getLevel;
    _referral=getReferral;
    _campaigns=getCampaigns;
    _targetScore=getTargetScore;
    _reward=getreward;
    _userScore=getuserScore;
    _updateLevelData();
    notifyListeners();
  }

  // Level basis par list update karna
  void _updateLevelData() {
    int targetLevelCampaign = _level == 10 ? 3
        : _level == 11 ? 5 : _level == 12 ? 8 : _level == 13 ? 10 : _level == 14 ? 12
        : _level == 15 ? 15 : _level == 16 ? 16 : _level == 17 ? 17 : _level == 18 ? 18
        : _level == 19 ? 19 : _level == 20 ? 20 : _level == 21 ? 25 : _level == 22 ? 30
        : _level == 23 ? 35 : _level == 24 ? 40 : _level == 25 ? 41 : _level == 26 ? 42
        : _level == 27 ? 44 : _level == 28 ? 45 : _level == 29 ? 49 : _level == 30 ? 50
        : _level == 31 ? 55 : _level == 32 ? 60 : _level == 33 ? 70 : _level == 34 ? 75
        : _level == 35 ? 80 : _level == 36 ? 85 : _level == 37 ? 90 : _level == 38 ? 95
        : _level == 39 ? 98 : _level == 40 ? 100 : _level == 41 ? 110 : _level == 42 ? 115
        : _level == 43 ? 120 : _level == 44 ? 125 : _level == 45 ? 130 : _level == 46 ? 140
        : _level == 47 ? 150 : _level == 48 ? 165 : _level == 49 ? 180 : _level == 50 ? 200
        : _level == 51 ? 201 : _level == 52 ? 215 : _level == 53 ? 230 : _level == 54 ? 234
        : _level == 55 ? 245 : _level == 56 ? 256 : _level == 57 ? 260 : _level == 58 ? 270
        : _level == 59 ? 275 : _level == 60 ? 280 : _level == 61 ? 290 : _level == 62 ? 300
        : _level == 63 ? 320 : _level == 64 ? 330 : _level == 65 ? 340 : _level == 66 ? 350
        : _level == 67 ? 370 : _level == 68 ? 380 : _level == 69 ? 390 : _level == 70 ? 400
        : _level == 71 ? 405 : _level == 72 ? 410 : _level == 73 ? 415 : _level == 74 ? 422
        : _level == 75 ? 425 : _level == 76 ? 430 : _level == 77 ? 440 : _level == 78 ? 450
        : _level == 79 ? 460 : _level == 80 ? 480 : _level == 81 ? 490 : _level == 82 ? 500
        : _level == 83 ? 520 : _level == 84 ? 540 : _level == 85 ? 560 : _level == 86 ? 580
        : _level == 87 ? 600 : _level == 88 ? 630 : _level == 89 ? 660 : _level == 90 ? 700
        : _level == 91 ? 740 : _level == 92 ? 780 : _level == 93 ? 820 : _level == 94 ? 860
        : _level == 95 ? 740 : _level == 96 ? 780 : _level == 97 ? 820 : _level == 98 ? 860
        : _level == 99 ? 900 : _level == 100 ? 999: 1000;

    int targetReferral = _level == 70 ? 1 : _level == 71 ? 2 : _level == 72 ? 3 : _level == 73 ? 4
        : _level == 74 ? 5 : _level == 75 ? 5 : _level == 76 ? 6 : _level == 77 ? 6 : _level == 78 ? 7
        : _level == 79 ? 7 : _level == 80 ? 8 : _level == 81 ? 9 : _level == 82 ? 10 : _level == 83 ? 11
        : _level == 84 ? 11 : _level == 85 ? 12 : _level == 86 ? 12 : _level == 87 ? 13 : _level == 88 ? 13
        : _level == 89 ? 14 : _level == 90 ? 14 : _level == 91 ? 15 : _level == 92 ? 15 : _level == 16 ? 23
        : _level == 94 ? 17 : _level == 95 ? 17 : _level == 96 ? 18 : _level == 97 ? 18 : _level == 98 ? 19
        : _level == 99 ? 19 : _level == 100 ? 20 : 0;
    
    if (_level <= 9) {
      _levelData = [{'marquee': '$_level level 🎁 $_reward Tickets Reward, you need to reach the $_targetScore target score.'},];
      _levelStep = [
        {'icon': Icons.leaderboard_outlined, 'txt': 'Level $_level', 'title': 'Level', 'ans':'The current level is $_level\nand next level will be ${_level+1}.'},
        {'icon': Icons.sports_score, 'txt': 'Score', 'title': 'Score', 'ans':'Target Score: $targetScore\nReach Score: $_userScore\n\n1 point of score is equal to 1 second of task time.\nIf you complete a 1-minute task, you will get 60 score points.'},
        {'icon': Icons.card_giftcard, 'txt': 'Reward','title': 'Claim Reward', 'ans':'Completing the challenges, you will get 🎫 $reward Tickets Reward.'}
      ];
    } else if (_level <= 69) {
      _levelData = [{'marquee': '$_level level 🎁 $_reward Tickets Reward, you need to reach the $_targetScore target score & create $targetLevelCampaign campaigns.'},];
      _levelStep = [
        {'icon': Icons.leaderboard, 'txt': 'Level $_level', 'title': 'Level', 'ans':'The current level is $_level\nand next level will be ${_level+1}.'},
        {'icon': Icons.sports_score, 'txt': 'Score', 'title': 'Score', 'ans':'Target Score: $targetScore\nReach Score: $_userScore\n\n1 point of score is equal to 1 second of task time.\nIf you complete a 1-minute task, you will get 60 score points.'},
        {'icon': Icons.campaign, 'txt': '$targetLevelCampaign camaigns', 'title': 'Campaigns', 'ans':'You have currently created $campaigns campaigns.\nYou must create $targetLevelCampaign campaigns.'},
        {'icon': Icons.card_giftcard, 'txt': 'Reward','title': 'Claim Reward', 'ans':'Completing the challenges, you will get 🎫 $reward Tickets Reward.'}
      ];
    }else if (_level >= 70) {
        _levelData = [{'marquee': '$_level level 🎁 $_reward Tickets Reward, you need to reach the  $_targetScore target score, create $targetLevelCampaign campaigns and invite $targetReferral new users.'},];
      _levelStep = [
        {'icon': Icons.leaderboard, 'txt': 'Level $_level', 'title': 'Level', 'ans':'The current level is $_level\nand next level will be ${_level+1}.'},
        {'icon': Icons.sports_score, 'txt': 'Score', 'title': 'Score', 'ans':'Target Score: $targetScore\nReach Score: $_userScore\n\n1 point of score is equal to 1 second of task time.\nIf you complete a 1-minute task, you will get 60 score points.'},
        {'icon': Icons.campaign, 'txt': '$targetLevelCampaign camaigns', 'title': 'Campaigns', 'ans':'You have currently created $campaigns campaigns.\nYou must create $targetLevelCampaign campaigns.'},
        {'icon': Icons.share, 'txt': 'Invite $targetReferral user', 'title': 'Referral', 'ans':'You currently have $referral new users invited. You must invite $targetReferral referrals.'},
        {'icon': Icons.card_giftcard, 'txt': 'Reward','title': 'Claim Reward', 'ans':'Completing the challenges, you will get 🎫 $reward Tickets Reward.'}
      ];
    }else{
      _levelData = [{'marquee': ''},];
      _levelStep = [
        {'icon': Icons.front_loader, 'txt': '', 'title': '', 'ans':''},
        {'icon': Icons.front_loader, 'txt': '', 'title': '', 'ans':''},
        {'icon': Icons.front_loader, 'txt': '', 'title': '', 'ans':''},
        {'icon': Icons.front_loader, 'txt': '', 'title': '', 'ans':''},
        {'icon': Icons.front_loader, 'txt': '','title': '', 'ans':''}
      ];
    }
  }
}

