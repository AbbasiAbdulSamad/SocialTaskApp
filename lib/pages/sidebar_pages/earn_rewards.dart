import 'package:app/pages/sidebar_pages/invite.dart';
import 'package:app/screen/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/provider/reward_services.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/ads.dart';
import '../../ui/bg_box.dart';
import '../../ui/flash_message.dart';
import '../../ui/pop_reward.dart';
import '../../ui/ui_helper.dart';
class EarnTickets extends StatelessWidget {
  BuildContext context;
   EarnTickets({super.key, required this.context}){
     Provider.of<RewardProvider>(context, listen: false).setLoading(false);
  }

  void showRewardPopup(BuildContext context) {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (internetProvider.isConnected) {
      if(userProvider.currentUser != null){
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => RewardPop.rewardPop(
                context: dialogContext,
                img: "assets/animations/gift.json",
                reward: userProvider.currentUser!.isPremium?"+100 Tickets": "+20 Tickets",
                description: "You have received your daily reward!",
                buttonIcon: Icons.payments_outlined,
                buttonText: 'Claim Reward',
                    apiCall: ()=> Provider.of<RewardProvider>(context, listen: false).claimDailyReward(context)
            ));
      }else{
        AlertMessage.snackMsg(context: context, message: 'Something went wrong due to which the Social Task is not working.', time: 3);
      }
    } else {
      AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
    }
  }

  void serviceNotFound(BuildContext context){
    AlertMessage.snackMsg(context: context, message: 'not found coming soon');
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Theme and text styles
    final rewardProviderLoading = Provider.of<RewardProvider>(context).isLoading;
    ColorScheme theme = Theme.of(context).colorScheme;
    final userProvider = Provider.of<UserProvider>(context);
    final isLoading = userProvider.isCurrentUserLoading;

    if (userProvider.currentUser == null && !isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Earn Rewards')),
        body: Center(
          child: Ui.buildNoInternetUI(
            theme,
            Theme.of(context).textTheme,
            false,
            'Connection Issue',
            'We’re having trouble loading your profile. Please check your network or try again.',
            Icons.wifi_off,
                () => userProvider.fetchCurrentUser(),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Helper.navigateAndRemove(context, const Home(onPage: 1));
        }
        return false;
      },
      child: Scaffold(backgroundColor: theme.primaryFixed,
          appBar: AppBar(title: Text('Earn Rewards', style: textTheme.displaySmall?.copyWith(fontSize: 22, color: Colors.white)),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: theme.surfaceTint,
              statusBarIconBrightness: Brightness.light,),
          ),
          body:  Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                  BgBox(
                      wth: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      allRaduis: 8,
                      child: Column(children: [
                  // Box heading icon/text function
                        boxHeading(context, 'challenge.svg', 'Regular Challenges'),
                        Ui.line(),
                  // Childs
                        earnReward(context, Icons.wallet_giftcard_sharp, 'Daily Reward', '+20', ()=> showRewardPopup(context), Colors.green),
                        Ui.lightLine(),
                        earnReward(context, Icons.video_collection, 'Watch a short video', '+20', ()=> UnityAdsManager.showRewardedAd(context),
                         Colors.indigo),
                        Ui.lightLine(),
                        earnReward(context, Icons.message, 'Invite and Earn', '+1000', ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> const Invite())),
                          theme.onPrimaryFixed),
                        Ui.lightLine(),
                        earnReward(context, Icons.download, 'Download App', '+1000', ()=> serviceNotFound(context), theme.onPrimaryFixed),
                      ],)
                  ),

                    Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(children: [
                    //Box heading icon/text function
                         boxHeading(context, 'heart.svg', 'Follow Offical Social'),
                          Ui.line(),
                    // Childs
                          earnReward(context, Icons.link_outlined, "LinkedIn", '+5', (){ launchUrl(Uri.parse('https://www.linkedin.com/in/asamada/'));}, Colors.blue, svg: 'assets/ico/linkedin.svg',),
                          Ui.lightLine(),
                          earnReward(context, Icons.facebook, 'Facebook Page', '+5', (){ launchUrl(Uri.parse('https://web.facebook.com/SocialTaskApp'));}, Colors.blueAccent),
                          Ui.lightLine(),
                          earnReward(context, Icons.play_arrow, 'Subscribe Channel', '+5', (){ launchUrl(Uri.parse('https://www.youtube.com/@Social_Task'));}, Colors.red),
                          Ui.lightLine(),
                          earnReward(context, Icons.tiktok, 'Follow TikTok', '+5', (){ launchUrl(Uri.parse('https://www.tiktok.com/@socialtaskapp'));}, theme.onPrimaryFixed),
                          Ui.lightLine(),
                          earnReward(context, Icons.telegram, 'Join Telegram', '+5', (){ launchUrl(Uri.parse('https://t.me/SocialTaskApp'));}, Colors.lightBlue),
                        ],)
                    ),
                    const SizedBox(height: 100,)
                ],),
              ),

              // 🔄 Loading overlay
              if (isLoading || rewardProviderLoading)
                Ui.screenLoading(context)
            ],
          )
      ),
    );
  }



  //heading
  boxHeading(BuildContext context, String svgImg, String text){
    return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(spacing: 7,
    children: [
    SvgPicture.asset('assets/ico/$svgImg', width: 30,),
    Text(text, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize:20),),
    ],),
    );
  }

// Childs Widgets
  earnReward(BuildContext context,IconData icon, String text, String coin, VoidCallback onClick, Color iconColor, {String svg=""}){
    ColorScheme theme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onClick,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(spacing: 15,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(spacing: 10,
                  children: [
                    (svg=="")?Icon(icon, size: 25, color: iconColor,):
                    SvgPicture.asset(svg, width: 30, height: 30,),
                    Text(text, style:Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 17, wordSpacing: 1, color: theme.onPrimaryFixed),),
                  ],
                ),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        color: theme.primaryFixed,
                        borderRadius: BorderRadius.circular(6),),
                    child: Row(spacing: 5,
                      children: [
                        Text(coin, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 17, color: theme.onPrimaryFixed),),
                        Icon(Icons.payments_outlined, size: 20, color: theme.errorContainer)
                      ],)),
              ],),
          ),
    );
  }

}
