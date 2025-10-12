import 'dart:convert';
import 'package:app/config/config.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:app/ui/bg_box.dart';
import 'package:app/ui/button.dart';
import 'package:app/ui/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/ui_helper.dart';

class Invite extends StatefulWidget {
  const Invite({super.key});

  @override
  State<Invite> createState() => _InviteState();
}
class _InviteState extends State<Invite> {
  List<Map<String, dynamic>> referrals = [];
  bool isLoading = false;
  bool _isDataLoaded = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User? user;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDataLoaded) {
        _isDataLoaded = true;
        _loadData();
      }
    });
  }
  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchCurrentUser();
    await fetchReferralData();
  }

  Future<void> fetchReferralData() async {
    setState(() {isLoading = true;});
    final data = await fetchReferrals();
    setState(() {
      referrals = data;
      isLoading = false;
    });
  }

  static Future<List<Map<String, dynamic>>> fetchReferrals() async {
    final url = Uri.parse(ApiPoints.referralsList);
    try {
      final token = await Helper.getAuthToken();

      if (token == null) {
        throw Exception('Auth token not available');
      }
      final response = await http.get(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint(token);
        if (data['status'] == true && data['referrals'] != null) {
          return List<Map<String, dynamic>>.from(data['referrals']);
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load referrals');
      }
    } catch (e) {
      debugPrint('❌ Error fetching referrals: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Invite & Earn")),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
          child: SingleChildScrollView(
            child: (userProvider.currentUser == null && !userProvider.isCurrentUserLoading)
                ? Container(width: double.infinity, height: 600, alignment: Alignment.center,
                child: Ui.buildNoInternetUI(theme, textTheme, false, 'Connection Issue',
                    'We’re having trouble connecting right now. Please check your network or try again in a moment.', Icons.wifi_off,
                    () async{
                    setState(() => isLoading = true);
                    await userProvider.fetchCurrentUser();
                    await fetchReferralData();
                    setState(() => isLoading = false);
                  },))
                : Column(children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                      decoration: BoxDecoration(
                          color: theme.primaryFixed,
                          border: Border(bottom: BorderSide(color: theme.onPrimaryFixed, width: 1)),
                          boxShadow: [BoxShadow(color: theme.shadow, spreadRadius: 30, blurRadius: 50)],
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))
                      ),
                      child: Column(spacing: 10,
                        children: [
                          Stack(
                            children: [
                              Center(child: Image.asset('assets/ico/invite_users_icon.webp', width: 143)),
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 33.3),
                                  width: 75, height: 75,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF32A1D8), width: 5),),
                                  child: ClipOval(
                                    child: Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 90, 90),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text('Invite your friends and earn tickets for each referral that joins!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.2),),
                          const SizedBox(height: 20,),
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                              decoration: BoxDecoration(color: Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 0.5, color: Colors.deepPurple)),
                              child: Row(spacing: 6,
                                children: [
                                Image.asset('assets/ico/3xTickets.webp', width: 40,),
                                Text('Get', style: textTheme.labelSmall?.copyWith(fontSize: 23, color: Colors.black),),
                                Text('+1000 Tickets', style: textTheme.displaySmall?.copyWith(fontSize: 20, color: const Color(
                                    0xFF006002)),)
                              ],),),
                          ),
                          const SizedBox(height: 10,),
                          SizedBox(width: 225, height: 40,
                            child: MyButton(txt: 'Copy Link', shadowOn: true, shadowColor: theme.shadow, bgColor: theme.surfaceDim, borderLineOn: true,
                                borderColor: theme.secondary, borderLineSize: 1, borderRadius: 10, ico: Icons.link,icoSize: 18, txtSize: 15, txtColor: theme.onPrimaryContainer,
                                onClick: (){
                                  userProvider.isCurrentUserLoading
                                      ? Positioned.fill(child: Container(
                                    color: Colors.black.withOpacity(0.6),
                                    child:const Center(child: CircularProgressIndicator(color: Colors.white),),
                                  ),)
                                      : Clipboard.setData(
                                    ClipboardData(text: "https://socialtask.xyz/join/${userProvider.currentUser!.referralCode}",),);
                                 AlertMessage.snackMsg(context: context, message: 'Link copied to clipboard.');
                                }),
                          ),
                          SizedBox(width: 225, height: 40,
                            child: MyButton(txt: 'Share Link', shadowOn: true, shadowColor: theme.shadow, bgColor: theme.surfaceDim, borderLineOn: true,
                                borderColor: theme.secondary, borderLineSize: 1, borderRadius: 10, ico: Icons.share, icoSize: 18, txtSize: 15, txtColor: theme.onPrimaryContainer,
                                onClick: (){
                                  userProvider.isCurrentUserLoading
                                      ?  Positioned.fill(child: Container(
                                      color: Colors.black.withOpacity(0.6),
                                      child: Center(child: const CircularProgressIndicator(color: Colors.white),),
                                    ),)
                                      : Share.share(
                                      "🚀 Want to grow your social media and earn rewards?\n"
                                          "Join Social Task — a unique platform for boosting your content organically.\n\n"
                                          "Download link: 🔗\n"
                                          "https://socialtask.xyz/join/${userProvider.currentUser!.referralCode}"
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
              isLoading
                  ? Container(width: double.infinity, height: 200, alignment: Alignment.center,child: CircularProgressIndicator( color: theme.onPrimaryContainer,))
                  : referrals.isEmpty
                  ? const Column(
                children: [
                  const SizedBox(height: 100,),
                  Text("No referrals", style: TextStyle(fontSize: 18),),
                ],):Column(
                      children: [
                        const SizedBox(height: 50,),
                        Text('${referrals.length} referrals have joined', style: textTheme.displaySmall?.copyWith(fontSize: 22, color: theme.onPrimaryFixed),),
                        const SizedBox(height: 10,),
                        Text('You have received a total of ${referrals.length * 1000} tickets', style: textTheme.displaySmall?.copyWith(fontSize: 14, color: theme.errorContainer),),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 2),
                          height: 1,
                          width: double.infinity,
                          decoration: BoxDecoration(
                          color: theme.onPrimaryFixed,
                          boxShadow: [BoxShadow(
                            color: theme.onPrimaryFixed,
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: const Offset(0, 6)
                          )]
                        ),),
                        const SizedBox(height: 30,),
                        Column(
                           children: referrals.map((ref) {
                           return BgBox(
                                   margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                                   allRaduis: 5,
                                       child: ListTile(
                                         minTileHeight: 0,
                                         leading: CircleAvatar(
                                           backgroundImage: NetworkImage(ref['profile']),
                                         ),
                                         title: Text(ref['name']),
                                         subtitle: Text(ref['email'], style: TextStyle(fontSize: 12),),
                                         trailing: Text(ref['accountCreate'], style: TextStyle(fontSize: 14),),
                                       ),
                                     );
                                   }).toList(),
                                 ),
                      ],
                    ),

              const SizedBox(height: 100,),
            ],),
                ),
        )
    );
  }
}
