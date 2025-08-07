import 'dart:convert';
import 'package:app/server_model/functions_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../server_model/provider/leaderboard_reward.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/ui_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {

  List<dynamic> _leaderboard = [];
  Map<String, dynamic>? topUser1;
  Map<String, dynamic>? topUser2;
  Map<String, dynamic>? topUser3;
  late UserProvider userProvider;
  late LeaderboardReward leaderboardProvider;
  late int leaderboardReward;
  int? currentUserRank;
  Map<String, dynamic>? currentUserDataMap;
  bool _isLoading = true;



// ✅ Fetch Leaderboard Data with Current User
  Future<void> fetchLeaderboard() async {
    setState(() => _isLoading = true);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    leaderboardProvider = Provider.of<LeaderboardReward>(context, listen: false);
    leaderboardReward = leaderboardProvider.reward ?? 0;
    try {
      String? token = await Helper.getAuthToken();
      if (token == null) throw Exception("Firebase token not found");

      final response = await http.get(
        Uri.parse(ApiPoints.leaderboardAPI),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _leaderboard = data['leaderboard'] ?? [];

          // ✅ Find Current User
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final currentUserData = _leaderboard.firstWhere(
                  (user) => user['email'] == userProvider.currentUser!.email,
              orElse: () => null,
            );
            currentUserRank = currentUserData['rank'] ?? _leaderboard.length; // Current User Rank Get
            currentUserDataMap = currentUserData;
            if (currentUserData == null) {
              _leaderboard.add({
                'email': currentUser.email,
                'name': currentUser.displayName ?? "You",
                'profile': currentUser.photoURL ?? userProvider.currentUser!.profile,
                'leaderboardScore': 0,
                'rank': _leaderboard.length + 1,
              });
            }
          }

          // ✅ Sort Leaderboard by Rank (Ensure backend sends correct rank)
          _leaderboard.sort((a, b) => (a['rank'] ?? 9999).compareTo(b['rank'] ?? 9999));

          // ✅ Top 3 users
          topUser1 = _leaderboard.isNotEmpty ? _leaderboard[0] : {};
          topUser2 = _leaderboard.length > 1 ? _leaderboard[1] : {};
          topUser3 = _leaderboard.length > 2 ? _leaderboard[2] : {};

        });
        await userProvider.fetchCurrentUser();
      } else {
        throw Exception("Failed to load leaderboard (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      setState(() => _leaderboard = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  String formatLargeNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toString();
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      fetchLeaderboard();
    });
  }
  @override
  void dispose() {
    _leaderboard.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),
      ),

      body: (userProvider.currentUser == null)?
      Center(child: Ui.buildNoInternetUI(theme, textTheme, false, 'No internet connection',
          'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
              ()=> userProvider.fetchCurrentUser())):
      RefreshIndicator(
        onRefresh: fetchLeaderboard,
        child: Consumer<LeaderboardReward>(
    builder: (context, leaderboardProvider, child) {
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
                              decoration: BoxDecoration(color: theme.onPrimaryFixed,
                              boxShadow: [BoxShadow(color: theme.shadow, spreadRadius: 5, blurRadius: 20, offset: Offset(0, 10))],
                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5))),
                              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                              margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                Text('Rank', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18),),
                                Text('Name', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18)),
                                SizedBox(width: 20,),
                                Text('Score', style: textTheme.labelSmall?.copyWith(color: theme.primaryFixed, fontSize: 18)),
                              ],),
                            ),
                            (_isLoading || userProvider.isCurrentUserLoading)? Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 100),
                                child: CircularProgressIndicator(color: theme.onPrimaryContainer,)):
                            Expanded(
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _leaderboard.length,
                                  itemBuilder: (context, index) {
                                    final user = _leaderboard[index];
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
                                            formatLargeNumber(user['rank'] ?? 0),
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
                                              child: Text(formatLargeNumber(user['leaderboardScore'] ?? 0),
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
              (leaderboardProvider.animation)?
           Positioned(left: 0, right: 0, top: 40,
              child: Ui.bgShineRays(context, leaderboardReward))
                  :SizedBox()
            ],
          );
    })
      ),
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
                SizedBox(height: 35,),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    child: Text(name, textAlign: TextAlign.center, style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
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
