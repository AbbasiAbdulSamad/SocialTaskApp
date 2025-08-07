import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../server_model/level_data_provider.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/ui_helper.dart';
class MyAccount extends StatefulWidget {
  MyAccount({super.key});
  @override
  State<MyAccount> createState() => _MyAccountState();
}
class _MyAccountState extends State<MyAccount> {
  late final UserProvider? _userProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  List<Map<String, dynamic>> _profileData = [];
  int campaignLimit = 10;
  int autoLimit = 20;
  String formattedJoinDate = 'Undefine';

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dateFormate();
      final user = _userProvider!.currentUser;
      if (user != null) {
        if (user.isPremium) {
          setState(() {campaignLimit = 100;autoLimit = 200;});
        }
        setState(() {
          _profileData = [
            {'title': 'Email', 'icon': Icons.mail_outline, 'data': user.email},
            {'title': 'Tickets','icon': Icons.payments_outlined, 'data': "${user.coin}"},
            {'title': 'Level','icon': Icons.trending_up, 'data': "${user.levelData.level}"},
            {'title': 'YouTube Tasks','icon': Icons.done_outline, 'data': "${user.youtubeTasks}"},
            {'title': 'TikTok Tasks','icon': Icons.done_outline, 'data': "${user.tiktokTasks}"},
            {'title': 'Total Campaigns','icon': Icons.payments_outlined, 'data': "${user.campaigns}"},
            {'title': 'Weekly Score', 'icon': Icons.sports_score, 'data': user.leaderboardScore},
            {'title': 'Campaign Limit', 'icon': Icons.campaign, 'data': "$campaignLimit/${user.campaignLimit}"},
            {'title': 'Auto Limit', 'icon': Icons.motion_photos_auto_outlined, 'data': "$autoLimit/${user.autoLimit}"},
            {'title': 'Country', 'icon': Icons.location_on_outlined, 'data': user.country ?? ""},
            {'title': 'Join At', 'icon': Icons.date_range, 'data': formattedJoinDate ?? ""},
          ];
        });
      }
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
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;
    final User? user = auth.currentUser;
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 🔹 Show loading indicator while fetching
    if (userProvider.isCurrentUserLoading && currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontSize: 18)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: theme.onPrimaryContainer)),
      );
    }

    // 🔹 Show "No Internet" UI if loading is done and user is null
    if (currentUser == null) {
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
            'No internet connection',
            'Can\'t reach server. Please check your internet connection',
            Icons.wifi_off,
                () => userProvider.fetchCurrentUser(),
          ),
        ),
      );
    }

    return Scaffold( backgroundColor: theme.primaryFixed,
        appBar: AppBar(title: const Text('My Profile', style: TextStyle(fontSize: 18)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,),
        ),
        body: RefreshIndicator(
            color: theme.onPrimaryContainer,
            onRefresh: () async {
              await userProvider.fetchCurrentUser();
            },
            child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              Center(
                                child: Container(
                                margin: EdgeInsets.only(top: 20),
                                width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                  child: ClipOval(
                    child: user?.photoURL != null
                    ? Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 90, 90)
                    : Image.asset('assets/ico/user_profile.webp'),
                  ),
                                ),
                              ),
                  SizedBox(height: 10,),
                  Text(userProvider.currentUser!.name, style: textTheme.labelMedium?.copyWith(fontSize: 25, color: theme.onPrimaryContainer),),
                  
                  Column(
                    children: List.generate(_profileData.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        child: Ui.DisableInput(
                          context,
                          "${_profileData[index]['title']}",
                          _profileData[index]['icon'],
                          defaultValue: _profileData[index]['data'],
                        ),
                      );
                    }),
                  ),
                            ],),
                )
        )
    );
  }
}