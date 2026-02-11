import 'package:app/pages/sidebar_pages/buy_tickets.dart';
import 'package:app/pages/sidebar_pages/level.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:app/ui/bg_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/leaderboard_provider.dart';
import '../../server_model/provider/users_provider.dart';
import '../../server_model/review_mode.dart';
import '../../ui/ui_helper.dart';
class MyAccount extends StatefulWidget {
  const MyAccount({super.key});
  @override
  State<MyAccount> createState() => _MyAccountState();
}
class _MyAccountState extends State<MyAccount> {
  late final UserProvider? _userProvider;
  bool _isDataLoaded = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  int campaignLimit = 10;
  int autoLimit = 20;
  String formattedJoinDate = 'loading...';
  late int tickets = 0;
  late int level = 0;
  late int yt = 0;
  late int insta = 0;
  late int tiktok = 0;
  late int website = 0;
  late String country = "loading...";
  late String email = "loading...";
  late int totalTasks = 0;


  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    final user = _userProvider!.currentUser;
    if (user != null) {
      // 👇 yahan turant data set ho jaye bina API call ke
      tickets = user.coin;
      level = user.levelData.level;
      yt = user.youtubeTasks;
      insta = user.instagramTasks;
      tiktok = user.tiktokTasks;
      website = user.websiteTasks;
      country = user.country;
      email = FirebaseAuth.instance.currentUser?.email ?? user.email;
      totalTasks = insta + tiktok + yt + website;

      if (user.isPremium) {
        campaignLimit = 100;
        autoLimit = 1000;
      }

      // date format bhi turant chala do
      dateFormate();
    }

    // ✅ leaderboard optional: sirf jab pehle se loaded na ho tab fetch karo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
      if (leaderboardProvider.currentUserData == null) {
        await leaderboardProvider.fetchLeaderboard();
      }
      FetchDataService.fetchData(context, forceRefresh: true);
    });
  }


  void dateFormate(){
    try {
      final user = _userProvider!.currentUser;
      if (user!.accountCreate != null && user.accountCreate!.trim().isNotEmpty) {
        DateTime joinDate = DateTime.parse(user.accountCreate!).toLocal();
        formattedJoinDate = DateFormat('dd MMM yyyy').format(joinDate);
      }
    } catch (e) {
      formattedJoinDate = 'Undefine';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isReview = AppReviewMode.isEnabled();
    final User? user = auth.currentUser;
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final currentUserRank = leaderboardProvider.currentUserRank ?? 0;
    final isLeaderboardLoading = leaderboardProvider.isLoading;


    // 🔹 Show loading indicator while fetching
    if (_userProvider!.isCurrentUserLoading && _userProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontSize: 18)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Ui.loading(context),
      );
    }

    // 🔹 Show "No Internet" UI if loading is done and user is null
    if (_userProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontSize: 18)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Center(
          child: Ui.buildNoInternetUI(
            theme,
            textTheme,
            false,
            'Connection Issue',
            'We’re having trouble connecting right now. Please check your network or try again in a moment.',
            Icons.wifi_off,
                () => _userProvider.fetchCurrentUser(),
          ),
        ),
      );
    }

    return Scaffold( backgroundColor: theme.primaryFixed,
        appBar: AppBar(title: Text('My Profile', style: textTheme.displaySmall?.copyWith(fontSize: 20, color: Colors.white)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,),
        ),
        body: RefreshIndicator(
            color: theme.onPrimaryContainer,
            onRefresh: () async {
              await _userProvider.fetchCurrentUser(forceRefresh: true);
            },
            child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [BoxShadow(color: theme.onPrimaryFixed, blurRadius: 10, spreadRadius: 3, offset: Offset(0, 5))]
                                      ),
                                      child: Image.asset("assets/ico/profile_bg.webp", width: double.infinity,)),

                                  Center(
                                    child: Container(
                                    margin: const EdgeInsets.only(top: 30),
                                    width: 90, height: 90,
                                                    decoration: BoxDecoration(shape: BoxShape.circle,
                                                      border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                                                    child: ClipOval(
                                                      child: user?.photoURL != null
                                                      ? Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 90, 90)
                                                      : Image.asset('assets/ico/user_profile.webp'),
                                                    ),),
                                  ),

                                  (_userProvider.currentUser?.isPremium == true)?
                                  Center(
                                    child: Container(
                                        margin: const EdgeInsets.only(top: 33),
                                        width: 170, height: 100,
                                        child: Ui.networkImage(context, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgYqKTpfnpJ1JNuEWxru39AqdDDnMwrj_4O33AH3QqbH8nN24NV6j6phtZ_Yrs7ejjd7xmVmvK3u_VEyKnXB3UHlMs48sg1ToE4WaO1tg-DwUHnWRXm5FTLmsrdJjxGcKiq_yq9826vZoC2_U4lCzoHzXKiq7vqG-Fab961TSShCpkiOV9l_1Kl_Yd_Ee0/s320/premium_crown.png',
                                        '', 130, 90)),
                                  ): SizedBox(),
                                ],
                              ),
                  const SizedBox(height: 05,),
                  Text(_userProvider.currentUser!.name, style: textTheme.labelMedium?.copyWith(fontSize: 25, color: theme.onPrimaryContainer),),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      children: [
                        Ui.DisableInput(context,
                          "Email", Icons.email, defaultValue: email,),

                        const SizedBox(height: 15,),
                        Row(spacing: 15,
                          children: [
                          Expanded(
                            child: InkWell(
                              onTap: (){
                                if(isReview==false){
                                  Helper.navigatePush(context, const BuyTickets());
                                }},
                              child: BgBox(
                                padding:const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                                  allRaduis: 10,
                                  child: Row(spacing: 10,
                                    children: [
                                      Image.asset('assets/ico/3xTickets.webp', width: 40,),
                                      Column(spacing: 2,
                                        children: [
                                        Text('$tickets', style: textTheme.displaySmall?.copyWith(fontSize: 25),),
                                        Text("Tickets", style: textTheme.displaySmall?.copyWith(fontSize: 16),)
                                      ],),
                                    ],
                                  )),
                            ),
                          ),

                          Expanded(
                            child: InkWell(
                              onTap: ()=> Helper.navigatePush(context, const Level()),
                              child: BgBox(
                                  padding:const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                  allRaduis: 10,
                                  child: Row(spacing: 17,
                                    children: [
                                      Icon(Icons.trending_up, size: 30, color: theme.errorContainer,),
                                      Column(spacing: 2,
                                        children: [
                                        Text('$level', style: textTheme.displaySmall?.copyWith(fontSize: 30),),
                                        Text("Level", style: textTheme.displaySmall?.copyWith(fontSize: 16),)
                                      ],),
                                    ],
                                  )),
                            ),
                          )
                        ],),

                        BgBox(
                          margin:const EdgeInsets.symmetric(vertical: 15),
                            padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            allRaduis: 10,
                            child: Column(spacing: 10,
                              children: [
                           Row(spacing: 5,
                                children: [
                                  Text("$totalTasks", style: textTheme.displaySmall?.copyWith(fontSize: 20, color: theme.errorContainer, fontWeight: FontWeight.bold)),
                                  Text("Tasks Completed", style: textTheme.displaySmall?.copyWith(fontSize: 15)),
                                  Icon(Icons.done_outline, color: theme.onPrimaryContainer, size: 17,),
                                ],
                              ),
                              Ui.lightLine(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                               Column(children: [
                                 Text('$yt', style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                 Text("YouTube", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                               ],),

                                  const SizedBox(
                                    width: 0.5,
                                    height: 50,
                                    child: DecoratedBox(decoration: BoxDecoration(color: Color(0xff505050),),),),

                                Column(children: [
                                  Text('$insta', style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                  Text("Instagram", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                                ],),

                              ],),

                                Ui.lightLine(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(children: [
                                      Text('$tiktok', style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                      Text("TikTok", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                                    ],),
                                    const SizedBox(
                                      width: 0.5,
                                      height: 50,
                                      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xff505050),),),),

                                    Column(children: [
                                      Text('$website', style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                      Text("Website", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                                    ],),

                                  ],),
                        ],)),

                        BgBox(
                            padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            allRaduis: 10,
                            child: Column(spacing: 10,
                              children: [
                                Row(spacing: 5,
                                  children: [
                                    Text("Weekly Performance", style: textTheme.displaySmall?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Icon(Icons.stacked_line_chart, color: theme.onPrimaryContainer, size: 17,),
                                  ],
                                ),
                                Ui.lightLine(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(spacing: 15,
                                      children: [
                                        Icon(Icons.leaderboard_rounded, size: 30, color: theme.errorContainer,),
                                        Column(children: [
                                          isLeaderboardLoading
                                              ? const Text("...", style: TextStyle(fontSize: 25))
                                              : Text("#$currentUserRank", style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                          Text("RANK", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                                        ],),
                                      ],
                                    ),

                                    const SizedBox(
                                      width: 0.5,
                                      height: 50,
                                      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xff505050),),),),

                                    Row(spacing: 15,
                                      children: [
                                        Icon(Icons.sports_score, size: 30, color: theme.errorContainer,),
                                        Column(children: [
                                          Text("${_userProvider.currentUser?.leaderboardScore ?? 0}",
                                              style: textTheme.displaySmall?.copyWith(fontSize: 25)),
                                          Text("SCORE", style: textTheme.displaySmall?.copyWith(fontSize: 14))
                                        ],),
                                      ],
                                    ),

                                  ],),
                              ],)),

                        BgBox(
                          margin: const  EdgeInsets.symmetric(vertical: 15),
                            padding: const  EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            allRaduis: 10,
                            child: Column(spacing: 10,
                              children: [
                                Row(spacing: 5,
                                  children: [
                                    Text("Daily Limits", style: textTheme.displaySmall?.copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Icon(Icons.restore, color: theme.onPrimaryContainer, size: 18,),
                                  ],
                                ),
                                Ui.lightLine(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(spacing: 15,
                                      children: [
                                        Icon(Icons.auto_awesome, size: 30, color: theme.errorContainer,),
                                        Column(spacing: 5,
                                          children: [
                                            Text("20/$autoLimit", style: textTheme.displaySmall?.copyWith(fontSize: 20)),
                                            Text("Auto Task", style: textTheme.displaySmall?.copyWith(fontSize: 12))
                                          ],),
                                      ],
                                    ),

                                    const SizedBox(
                                      width: 0.5,
                                      height: 50,
                                      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xff505050),),),),

                                    Row(spacing: 15,
                                      children: [
                                        Icon(Icons.campaign, size: 30, color: theme.errorContainer,),
                                        Column(spacing: 5,
                                          children: [
                                            Text("10/$campaignLimit", style: textTheme.displaySmall?.copyWith(fontSize: 20)),
                                            Text("Campaigns", style: textTheme.displaySmall?.copyWith(fontSize: 12))
                                          ],),
                                      ],
                                    ),
                                  ],),
                              ],)),
                        const SizedBox(height: 5,),
                        Row(spacing: 10,
                          children: [
                            Expanded(child: Ui.DisableInput(context,
                              "Country", Icons.location_on, defaultValue: '$country',),),

                            Expanded(child: Ui.DisableInput(context,
                              "Join At", Icons.date_range_sharp, defaultValue: formattedJoinDate,),)

                          ],
                        ),
                        const SizedBox(height: 10,)
                      ]
                    ),
                  ),
                            ],),
                )
        )
    );
  }
}