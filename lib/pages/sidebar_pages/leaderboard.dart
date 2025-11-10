import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../screen/home.dart';
import '../../server_model/provider/leaderboard_provider.dart';
import '../../server_model/provider/leaderboard_reward.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/ui_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {

  List<dynamic> leaderboard = [];
  Map<String, dynamic>? topUser1;
  Map<String, dynamic>? topUser2;
  Map<String, dynamic>? topUser3;
  late UserProvider userProvider;
  late LeaderboardReward leaderboardProvider;
  int? currentUserRank;
  Map<String, dynamic>? currentUserDataMap;
  bool _isLoading = true;
  late ValueNotifier<String> countdownTextNotifier;
  late Timer _timer;
  DateTime? serverTimePk;


  @override
  void initState() {
    super.initState();
    countdownTextNotifier = ValueNotifier(" ");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final leaderboardProvider =
      Provider.of<LeaderboardProvider>(context, listen: false);
      await leaderboardProvider.fetchLeaderboard();

      final serverTimeStr = leaderboardProvider.serverTime;
      if (serverTimeStr != null && serverTimeStr.isNotEmpty) {
        DateTime serverTime = DateTime.parse(serverTimeStr);
        serverTimePk = serverTime.add(const Duration(hours: 5));

        countdownTextNotifier.value = getTimeUntilSundayNightText(serverTimePk!);

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          serverTimePk = serverTimePk!.add(const Duration(seconds: 1));
          countdownTextNotifier.value =
              getTimeUntilSundayNightText(serverTimePk!);
        });
      }
    });
  }


  // 🧮 Countdown until Sunday 11:59:59 PM (Pakistan time)
  String getTimeUntilSundayNightText(DateTime nowPk) {
    int daysUntilSunday = (DateTime.sunday - nowPk.weekday) % 7;

    DateTime targetSunday = DateTime(
      nowPk.year,
      nowPk.month,
      nowPk.day,
      nowPk.hour,
      nowPk.minute,
      nowPk.second,
    ).add(Duration(days: daysUntilSunday)).copyWith(hour: 28, minute: 58, second: 59);


    if (nowPk.isAfter(targetSunday)) {
      targetSunday = targetSunday.add(const Duration(days: 7));
    }

    Duration diff = targetSunday.difference(nowPk);
    int days = diff.inDays;
    int hours = diff.inHours.remainder(24);
    int minutes = diff.inMinutes.remainder(60);
    int seconds = diff.inSeconds.remainder(60);

    return "$days ${hours.toString().padLeft(2, '0')} "
        "${minutes.toString().padLeft(2, '0')} "
        "${seconds.toString().padLeft(2, '0')} ";
  }

  @override
  void dispose() {
    _timer.cancel();
    countdownTextNotifier.dispose();
    leaderboard.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final leaderboard = leaderboardProvider.leaderboard;
    final isLoading = leaderboardProvider.isLoading;

    final topUser1 = leaderboardProvider.topUser1;
    final topUser2 = leaderboardProvider.topUser2;
    final topUser3 = leaderboardProvider.topUser3;

    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final userProvider = context.watch<UserProvider>();

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Home(onPage: 1)), (route) => false,);
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Leaderboard'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,),
        ),

        body: (userProvider.currentUser == null && !userProvider.isCurrentUserLoading)?
        Center(child: Ui.buildNoInternetUI(theme, textTheme, false, 'Connection Issue',
            'We’re having trouble connecting right now. Please check your network or try again in a moment.', Icons.wifi_off,
                ()=> userProvider.fetchCurrentUser())):
        RefreshIndicator(
          onRefresh: ()=> leaderboardProvider.fetchLeaderboard(),
          child: Consumer<LeaderboardReward>(
          builder: (context, rewardProvider, child) {
      return Stack(
              children: [
                Column(
                      children: [
                        Container(
                          width: double.infinity, height: 180,
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          decoration: BoxDecoration(color: Colors.transparent,
                            border: Border(bottom: BorderSide(color: theme.primaryContainer, width: 2)),
                          ),
                          child: Stack(alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(height: 180,
                                child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // leaderboard widget box
                                    leaderboardTop3(70, Offset(-2, -2), BorderRadius.only(topLeft: Radius.circular(10)), 80,
                                        95, topUser3?['name']?.toString() ?? "loading...", topUser3?['leaderboardScore'].toString() ?? "0", "${topUser3?['profile'] ?? " "}",
                                        "${topUser3?['country']?? "NO"}", false),

                                    leaderboardTop3(120, Offset(0, -5), BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)), 35,
                                        5, "${topUser1?['name']?? "loading..."}", topUser1?['leaderboardScore'].toString() ?? "0", "${topUser1?['profile']?? " "}",
                                        "${topUser1?['country']?? "NO"}", true),

                                    leaderboardTop3(90, Offset(4, -5), BorderRadius.only(topRight: Radius.circular(10)), 60,
                                        55, "${topUser2?['name']?? "loading..."}", topUser2?['leaderboardScore'].toString() ?? "0", "${topUser2?['profile']?? " "}",
                                        "${topUser2?['country']?? "NO"}", false),
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: theme.background,
                                    boxShadow: [BoxShadow(color: theme.shadow, spreadRadius: 5, blurRadius: 20, offset: Offset(0, 10))],
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5))),
                                padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
                                margin: EdgeInsets.only(top: 0, left: 20, right: 20),
                                child:(countdownTextNotifier == null || countdownTextNotifier.value ==" ")?SizedBox(): Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        rewardNumImg("1xTickets.webp", "250"),
                                        rewardNumImg("8xTickets.webp", "1000"),
                                        rewardNumImg("3xTickets.webp", "500"),
                                      ],),
                                    Ui.lightLine(),
                                    SizedBox(height: 5,),
                                    Column(
                                      children: [
                                        ValueListenableBuilder<String>(
                                          valueListenable: countdownTextNotifier,
                                          builder: (context, value, _) {
                                            return Text(value, style: textTheme.displaySmall?.copyWith(color: theme.onPrimaryContainer,
                                                height: 0, wordSpacing: 30, fontSize: 18,), textAlign: TextAlign.end,);
                                          },),

                                        Text("Days Hours Mins   Sec", style: textTheme.labelSmall?.copyWith(color: theme.onPrimaryContainer,height: 0, wordSpacing: 23, fontSize: 14))
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                decoration: BoxDecoration(color: theme.onPrimaryFixed,
                                boxShadow: [BoxShadow(color: theme.shadow, spreadRadius: 5, blurRadius: 20, offset: Offset(0, 10))],
                                borderRadius: BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5))),
                                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text('Rank', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18),),
                                  Text('Name', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18)),
                                    const SizedBox(width: 20,),
                                  Text('Score', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18)),
                                ],),
                              ),
                              (isLoading || userProvider.isCurrentUserLoading)
                                  ? Container(alignment: Alignment.center, margin: EdgeInsets.only(top: 100), child: Ui.loading(context)):
                                (leaderboardProvider.leaderboard.isEmpty)?
                                Column(
                                  children: [
                                    const SizedBox(height: 30,),
                                    Ui.buildNoInternetUI(theme, textTheme, false, 'Connection Issue',
                                        'We’re having trouble connecting right now. Please check your network or try again in a moment.', Icons.wifi_off,
                                            ()=> leaderboardProvider.fetchLeaderboard()),
                                  ],
                                )
                                  : Expanded(
                                child: SingleChildScrollView(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: leaderboard.length,
                                    itemBuilder: (context, index) {
                                      final user = leaderboard[index];
                                      bool isCurrentUser = user['email'] == userProvider.currentUser?.email;
                                      return  Card(
                                        color: isCurrentUser ? theme.secondaryFixed : theme.background,
                                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                      elevation: 5,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(color: theme.shadow, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 7, bottom: 7, right: 5),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 45,
                                              child: Text((user['rank']==1)?"🥇":
                                              (user['rank']==2)?"🥈":
                                              (user['rank']==3)?"🥉":
                                              ('${user['rank'] ?? 0}'),
                                                style: textTheme.displaySmall?.copyWith(fontSize:(user['rank']==1 || user['rank']==2 || user['rank']==3)? 28: 18, color: isCurrentUser?Colors.white:theme.onPrimaryContainer),
                                                textAlign: TextAlign.center,),
                                            ),

                                            Container(
                                              margin: EdgeInsets.only(right: 10),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: theme.onPrimaryContainer, width: 0.5),
                                              ),
                                              child: ClipOval(
                                                child: user['profile'] != null
                                                    ? Ui.networkImage(context, user['profile'], 'assets/ico/user_profile.webp', 35, 35)
                                                    : Image.asset('assets/ico/user_profile.webp', width: 35, height: 35, fit: BoxFit.cover),),
                                            ),

                                            Expanded(child: Text(isCurrentUser ? "You":user['name'],
                                                maxLines: 1, overflow: TextOverflow.ellipsis, style: isCurrentUser?TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                                                  :textTheme.displaySmall?.copyWith(fontSize:17),),
                                            ),

                                            SizedBox(width: 20,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: SizedBox(width: 20, height: 20, child: Ui.countryFlag(user['country'])),
                                              ),),

                                            SizedBox(width: 55,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text('${user['leaderboardScore'] ?? 0}',
                                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.displaySmall?.copyWith(fontSize: 17, color: isCurrentUser?Colors.white:theme.onPrimaryContainer),),
                                              ),),
                                          ],)

                                      ),);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                (rewardProvider.animation)
                    ? Positioned(
                  left: 0, right: 0, top: 40,
                  child: Ui.bgShineRays(context, rewardProvider.reward ?? 0),
                ) : const SizedBox(),

              ],
            );
      })
        ),
      ),
    );
  }

  rewardNumImg(String ticketImg, String rewardNum){
    return Row(spacing: 2,
      children: [
        Image.asset('assets/ico/$ticketImg', width: 18,),
        Text(rewardNum, style: TextStyle(color: Theme.of(context).colorScheme.errorContainer,
            fontFamily: '3rdRoboto', fontSize: 16),),
      ],
    );
  }

  // Leaderboard Top3 users widgets
  Widget leaderboardTop3(double boxHeight, Offset shadowOffset, BorderRadius radius, double topProfile,
      double topCountry, String name, String score, String profile, String country, bool centerBox){
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Stack(alignment: Alignment.bottomLeft,
        children: [
          Container(height: boxHeight, width: double.infinity,
            decoration: BoxDecoration(color: theme.primaryFixed,
                boxShadow: [BoxShadow(color: theme.shadow, blurRadius: 10, spreadRadius: 1, offset: shadowOffset)],
                borderRadius: radius),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 35,),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: Text(name, textAlign: TextAlign.center, style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis,)),
                Ui.lightLine(),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: Text(score, textAlign: TextAlign.center, style: textTheme.displaySmall, maxLines: 1, overflow: TextOverflow.ellipsis,)),
              ],),),

          Positioned(top: topProfile, left: 0, right: 0,
            child:  Container(alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.onPrimaryContainer, width: 0.5),),
              child: ClipOval(
                child: (profile.isNotEmpty)
                    ? Ui.networkImage(context, profile, 'assets/ico/user_profile.webp', 55, 55)
                    : Image.asset('assets/ico/user_profile.webp', width: 50, height: 50, fit: BoxFit.cover),
              ),
            ),
          ),

          Container(alignment: Alignment.center,
            margin: EdgeInsets.only(top: topCountry),
            child:SizedBox(width: 18, height: 18, child: Ui.countryFlag(country)),
          ),
          (centerBox)?
           Positioned(top: 12, left: 0, right: 0,
            child: Center(
              child: SizedBox(width: 40,
                child: Image.asset('assets/ico/crown-icon.webp'),
              ),
            ),
          ): const SizedBox(),
        ],
      ),
    );
  }
}
