import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/sidebar_pages/FAQ_page.dart';
import '../pages/sidebar_pages/buy_tickets.dart';
import '../pages/sidebar_pages/earn_rewards.dart';
import '../pages/sidebar_pages/invite.dart';
import '../pages/sidebar_pages/leaderboard.dart';
import '../pages/sidebar_pages/level.dart';
import '../pages/sidebar_pages/profile.dart';
import '../pages/sidebar_pages/premium_account.dart';
import '../pages/sidebar_pages/support.dart';
import '../server_model/signout.dart';
import '../server_model/provider/users_provider.dart';
import 'ui_helper.dart';

class Sidebar extends StatelessWidget{
  Sidebar({super.key});
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    //UserProvider Current User form API
    final userProvider = Provider.of<UserProvider>(context);
    ColorScheme theme = Theme.of(context).colorScheme;
    User? user = _auth.currentUser;
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
      
        //🔹Sidebar header in user profile info
            Container(
              height: 160,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(color: theme.secondaryFixed,),
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 160, height: 80,
                    child: Stack(alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            border: Border.all(color: theme.onPrimaryContainer, width: 1.0),),
                          child: ClipOval(
                            child: user?.photoURL != null
                                ? Ui.networkImage(context, user!.photoURL!, 'assets/ico/user_profile.webp', 80, 80)
                                : Image.asset('assets/ico/user_profile.webp'),
                          ),
                        ),
                        (userProvider.currentUser?.isPremium == true)?
                        Positioned(top: 0, child:
                        Ui.networkImage(context, 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgYqKTpfnpJ1JNuEWxru39AqdDDnMwrj_4O33AH3QqbH8nN24NV6j6phtZ_Yrs7ejjd7xmVmvK3u_VEyKnXB3UHlMs48sg1ToE4WaO1tg-DwUHnWRXm5FTLmsrdJjxGcKiq_yq9826vZoC2_U4lCzoHzXKiq7vqG-Fab961TSShCpkiOV9l_1Kl_Yd_Ee0/s320/premium_crown.png',
                            '', 150, 90)): SizedBox()
                      ],
                    ),
                  ),
                    Text(user?.displayName ?? 'Undefine', overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white, height: 2)),
                ],
              ),
            ),
      
        //🔹Sidebar in list of pages
      
            Ui.sidebarLabel(Icons.account_circle, 'My Profile', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> MyAccount())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.trending_up, 'Level', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Level())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.leaderboard, 'Leaderboard', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> LeaderboardScreen())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.payments_outlined, 'Earn Rewards', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> const EarnTickets()));}),
            Ui.line(),
            SizedBox(height: 25,),
            Ui.sidebarLabel(Icons.add_shopping_cart, 'Buy Tickets', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> BuyTickets())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.workspace_premium, 'Premium Account', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> PremiumAccount())); }),
            Ui.line(),
            SizedBox(height: 25,),
            Ui.sidebarLabel(Icons.share_outlined, 'Invite Friends', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> const Invite()));}),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.support_agent, 'Support', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> SupportPage())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.question_mark, 'FAQ', (){Navigator.push(context, MaterialPageRoute(builder: (context)=> FaqPage())); }),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.star_purple500, 'Rate App', (){launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.socialtask.app'));}),
            Ui.lightLine(),
            Ui.sidebarLabel(Icons.privacy_tip_outlined, 'Privacy Policy', (){launchUrl(Uri.parse('https://socialtask.xyz/privacy-policy/'));}),
            Ui.line(),
            Ui.sidebarLabel(Icons.logout, 'Logout', () async {
              SignOut().signOutFromFirebase(context);
            }),
      
          ],),
      ),
    );
  }
}
