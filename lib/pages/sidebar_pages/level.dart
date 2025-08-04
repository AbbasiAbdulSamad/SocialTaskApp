import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/level_data_provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/leaderboard_reward.dart';
import '../../server_model/provider/level_update_api.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/flash_message.dart';
import '../../ui/timeLine_ui.dart';
import '../../ui/ui_helper.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  late LevelDataProvider _levelDataProvider;
  late UserProvider _userProvider;
  late LevelUpProvider _levelUpAPI;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _fetchData(forceRefresh: true);
    });
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _levelDataProvider = Provider.of<LevelDataProvider>(context, listen: false);
    _levelUpAPI = Provider.of<LevelUpProvider>(context, listen: false);
    await _userProvider.fetchCurrentUser();

    // ✅ Only fetch if user exists
    if (_userProvider.currentUser != null) {
      int getLevel = _userProvider.currentUser!.levelData.level;
      int getReferral = _userProvider.currentUser!.referral.length;
      int getCampaigns = _userProvider.currentUser!.campaigns;
      int getTargetScore = _userProvider.currentUser!.levelData.targetScore;
      int getReward = _userProvider.currentUser!.levelData.levelReward;
      int getUserScore = _userProvider.currentUser!.levelData.achieveScore;

      _levelDataProvider.findLevelFromAPI(getLevel, getReferral, getCampaigns, getTargetScore, getReward, getUserScore);
      await _levelUpAPI.updateUserLevel();
    }
    Future.delayed(Duration(milliseconds: 2200), () async {
      await _userProvider.fetchCurrentUser();
    });
    Future.delayed(Duration(seconds: 5), () async {
      await _userProvider.fetchCurrentUser();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final titleText = textTheme.labelMedium;

    final userProvider = context.watch<UserProvider>();
    final levelProvider = context.watch<LevelDataProvider>();
    final currentUser = userProvider.currentUser;

    // ✅ If user is null, show message in body (but app bar stays)
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Level'),),
        body: Center(child: Ui.buildNoInternetUI(theme, textTheme, false, 'No internet connection',
            'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
                ()=> userProvider.fetchCurrentUser())),
      );}

    // ✅ Now it's safe to use currentUser!
    double levelProgress = (currentUser.levelData.achieveScore >= currentUser.levelData.targetScore) ? 1.0
        : currentUser.levelData.achieveScore / currentUser.levelData.targetScore;

    double leveScoreProgress = double.parse(levelProgress.toStringAsFixed(4));
    double percentageValue = leveScoreProgress * 100;

    int stepCount = currentUser.levelData.levelSteps.first.isNotEmpty
        ? currentUser.levelData.levelSteps.first.length
        : 3;

    return Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Consumer<LevelUpProvider>(
              builder: (context, levelUpProvider, child) {
                return Stack(
                  children: [
                    Scaffold(
                      appBar: AppBar(title: Text('Level'),
                        systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: theme.surfaceTint,
                          statusBarIconBrightness: Brightness.light,),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: TextButton(
                              onPressed: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=> BuyTickets()));
                              },
                              child: Row(spacing: 5,
                                children: [
                                  Text("${userProvider.currentUser?.coin ?? 0}",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontSize: 22,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                  Image.asset('assets/ico/ticket_icon.webp', width: 38,),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      body: Stack(
                        children: [
                          /* 🔹 Part 2 (Scrollable below Part 1) */
                          Column(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(top: 260),
                                        child: Image.asset('assets/images/reward_bg.webp', fit: BoxFit.cover, width: double.infinity,)),


                                    (_levelUpAPI.levelTreasureBox)?
                                    SizedBox():
                                    Positioned(bottom: 15, left: 0, right: 0,
                                      child: SizedBox(width: 150, height: 150,
                                          child: GestureDetector(
                                              onTap: (){
                                                FetchDataService.fetchData(context, forceRefresh: true);
                                                return AlertMessage.flashMsg(context, 'Complete level and earn reward', 'Reward 🎫 ${userProvider.currentUser!.levelData.levelReward} Tickets', Icons.card_giftcard, 5);
                                                },
                                              child: Image.asset('assets/animations/lock_reward_box.gif'))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Column(
                            children: [
                              /* 🔹 Part 1 (Fixed at the top) */
                              Container(width: double.infinity,
                                padding: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.background, theme.primaryFixed, theme.primaryFixed, theme.primaryFixed,],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  boxShadow: [BoxShadow(color: Colors.yellow.shade100, spreadRadius: 1, blurRadius: 20, offset: const Offset(0, 8),)],),
                                child: Column(
                                  children: [

                                    //🔹1st start postion marque
                                    Stack(
                                      children: [
                                        Container(margin: const EdgeInsets.only(top: 5),
                                          height: 30,
                                          width: double.infinity,

                                          //🔹 Marquee text moving line text from level list
                                          child:Marquee(
                                            text: '${levelProvider.levelData[0]['marquee']}',
                                            style: TextStyle(fontWeight: FontWeight.w300, color: theme.primaryContainer),
                                            scrollAxis: Axis.horizontal,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            blankSpace: 20.0,
                                            velocity: 50.0,
                                            pauseAfterRound: const Duration(seconds: 1),
                                            startPadding: 10.0,
                                            accelerationDuration: const Duration(seconds: 1),
                                            accelerationCurve: Curves.linear,
                                            decelerationDuration: const Duration(milliseconds: 500),
                                            decelerationCurve: Curves.easeOut,
                                          ),
                                        ),

                                        //🔹 leve budget row with both side score coun number
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [

                                            //🔹 left side Achieve score
                                            Flexible(flex: 25,
                                              child: Container(margin: const EdgeInsets.only(top:70),
                                                child: Column(
                                                  children: [
                                                    // Get Score form API CurrentUser Score
                                                    Text('${userProvider.currentUser?.levelData.achieveScore ?? 0}', style: Theme.of(context).textTheme.labelLarge),
                                                    const Text('Achieve score', style: TextStyle(fontSize: 10),),
                                                  ],),
                                              ),
                                            ),

                                            //🔹 center lavel budget logo
                                            Flexible(flex: 50, child: SizedBox(width: 160, child:
                                            Stack(alignment: Alignment.center,
                                              children: [
                                                Image.asset('assets/ico/leve_budget.webp'),

                                                //🔹 level number show center in budget logo
                                                Container(alignment: Alignment.center,
                                                    margin: const EdgeInsets.only(right: 9),
                                                    //🔹Level Get from API
                                                    child: Text("${userProvider.currentUser?.levelData.level ?? 0}", style: const TextStyle(fontSize: 40,fontFamily: 'BoostAudience', color: Colors.black,),)),
                                              ],
                                            ))),

                                            //🔹 right side target score
                                            Flexible(flex: 25,
                                              child: Container(margin: const EdgeInsets.only(top: 70),
                                                child: Column(
                                                  children: [
                                                    //🔹target score display
                                                    Text("${userProvider.currentUser?.levelData.targetScore ?? 0}", style: Theme.of(context).textTheme.labelLarge),
                                                    const Text('Target score', style: TextStyle(fontSize: 10),),
                                                  ],),
                                              ),
                                            )
                                          ],),

                                      ],),


                                    const SizedBox(height: 8),
                                    Text('Steps to complete level',
                                      style: titleText?.copyWith(fontSize: 18, color: theme.errorContainer),),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: Ui.progressBar(levelProgress, "SCORE $percentageValue%", 10, 8),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 90,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: levelProvider.levelStep.length,
                                        itemBuilder: (context, index) {
                                          return  SizedBox(
                                            width: MediaQuery.of(context).size.width / stepCount,
                                            child: InkWell(
                                              child: TimeLine.timelineLevelSteps(
                                                context,
                                                userProvider.currentUser!.levelData.levelSteps.first[index],
                                                userProvider.currentUser!.levelData.levelSteps.last[index],
                                                userProvider.currentUser!.levelData.levelSteps.past[index],
                                                levelProvider.levelStep[index]['icon'] ?? Icons.error,
                                                levelProvider.levelStep[index]['txt'] ?? 'Error',
                                              ),
                                              onTap: () {
                                                AlertMessage.flashMsg(
                                                  context,
                                                  levelProvider.levelStep[index]['ans'],
                                                  levelProvider.levelStep[index]['title'],
                                                  levelProvider.levelStep[index]['icon'],
                                                  10,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    (_levelUpAPI.levelTreasureBox)?
                    Positioned(left: 0, right: 0, top: 55,
                            child: Lottie.asset("assets/animations/red.json")):SizedBox(),

                     (_levelUpAPI.rewardLastAnimation)?
                    Positioned(left: 0, right: 0, top: 300,
                        child: Ui.bgShineRays(context, levelProvider.reward))
                         :SizedBox()
                  ],
                );
              });
        },
    );
  }
}
