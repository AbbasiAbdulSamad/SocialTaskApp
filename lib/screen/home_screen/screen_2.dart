import 'dart:async';
import 'dart:math';
import 'package:app/server_model/functions_helper.dart';
import 'package:app/server_model/provider/users_provider.dart';
import 'package:app/ui/ads.dart';
import 'package:app/ui/shimmer_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/fetch_taskts.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/review_mode.dart';
import '../../ui/bg_box.dart';
import '../../ui/button.dart';
import '../../ui/flash_message.dart';
import '../../ui/pop_alert.dart';
import '../../ui/ui_helper.dart';
import '../task_screen/Tiktok_Task/tiktok_task_handler.dart';
import '../task_screen/Web_Task/Web_task_handler.dart';
import '../task_screen/YT_Tasks/yt_auto_task_screen.dart';
import '../task_screen/YT_Tasks/yt_task_screen.dart';
import '../task_screen/instagram_Task/instagram_task_screen.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> with WidgetsBindingObserver{
  late Future<void> _fetchDataFuture;
  bool _internetCheck = true;
  int _currentIndex = 0;
  Random _random = Random();
  String? lastTikTokUrl;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = FetchDataService.fetchData(context, forceRefresh: true);

    WidgetsBinding.instance.addObserver(this);
   }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    TikTokTaskHandler.handleLifecycle(state, context, 1);
    // 🔹 Website task handle
    WebsiteTaskHandler.handleLifecycle(state, context);

    // App close → overlay close
    if (state == AppLifecycleState.detached || state == AppLifecycleState.resumed) {
      FlutterOverlayWindow.closeOverlay();
    }
  }


  void _showNextCampaign() {
    final allCampaignsProvider = Provider.of<AllCampaignsProvider>(context, listen: false);
    if (allCampaignsProvider.allCampaigns.isNotEmpty) {
      setState(() {
        _currentIndex = _random.nextInt(allCampaignsProvider.allCampaigns.length);
      });
    }
  }

  Future<void> _checkInternet() async {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    setState(() {
      _internetCheck = internetProvider.isConnected;
    });
  }

  void taskNavigation(String taskUrl, String selectedOption, int watchTime, int reward, String campaignId, bool autoTask, String social) async {
    await _checkInternet();
    if (_internetCheck) {
      if(autoTask){
        Helper.navigatePush(context, YT_Auto_Task_Screen(
          taskUrl: taskUrl,
          selectedOption: selectedOption,
          watchTime: watchTime,
          reward: reward,
          campaignId: campaignId,
          screenFrom: 0,
        ),);
      }else{
        if(social=="TikTok"){
          // 🟢 Check permission first, then show overlay
          await tiktokTaskOverlay(
              selectedOption,
              taskUrl,
              campaignId,
              reward);
        }else if(social=="Website") {
          WebsiteTaskHandler.startWebsiteTask(
            context: context,
            url: taskUrl,
            reward: reward,
            screenFrom: 0,
            seconds: watchTime,
            campaignId: campaignId,
          );
        }else if(social=="Instagram"){
          Helper.navigatePush(context, Instagram_Task_Screen(
            taskUrl: taskUrl,
            selectedOption: selectedOption,
            reward: reward,
            campaignId: campaignId,
            screenFrom: 0,));

        }else{
          Helper.navigatePush(context, YT_Task_Screen(
            taskUrl: taskUrl,
            selectedOption: selectedOption,
            watchTime: watchTime,
            reward: reward,
            campaignId: campaignId,
            screenFrom: 0,
          ),);

        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Color(0xff505050),
        content: Text("No internet connection. Please check and try again.",
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white),),
      ));
    }
  }

  Future<void> tiktokTaskOverlay(String selectOption, String tiktokUrl, String campaignId, int reward, ) async {
    bool? granted = await FlutterOverlayWindow.isPermissionGranted();

    // Draw Permission Popup Request
    if (granted != true) {
      showDialog(context: context,
        builder: (BuildContext context) {
          // pop class import from pop_box.dart
          return pop.backAlert(context: context,icon: Icons.app_settings_alt_sharp, title: 'Draw permission',
              bodyTxt:'We need Draw over other apps permission.\n\nUsing this feature you switch between SocialTask and TikTok app.',
              confirm: 'Grant Permission', onConfirm: () async{
                Navigator.pop(context);
                await FlutterOverlayWindow.requestPermission();
                granted = await FlutterOverlayWindow.isPermissionGranted();
              });
        },
      );
    }

    if (granted == true) {
      TikTokTaskHandler.startTikTokTask(
        contextPop: context,
        tiktokUrl: tiktokUrl,
        taskType: selectOption,
        campaignId: campaignId,
        reward: reward,
        screenFrom: 1,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give the permission\nDraw permission not granted')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isReview = AppReviewMode.isEnabled();
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser?.autoLimit ?? 0;
    // UserProvider Current User from API
    final userProvider = Provider.of<UserProvider>(context);

    // Unity Ad for premium check
    bool isPremiumActive(String? expiry) {
      if (expiry == null || expiry.isEmpty) return false;
      final expiryDate = DateTime.tryParse(expiry);
      if (expiryDate == null) return false;
      return expiryDate.toUtc().isAfter(DateTime.now().toUtc());
    }
    final expiry = userProvider.currentUser?.premiumExpiry.toString();
    final userIsPremium = isPremiumActive(expiry);


    return FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (!_internetCheck){
            return Ui.buildNoInternetUI(theme, textTheme,false, 'No internet connection',
                'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
                    ()=> FetchDataService.fetchData(context, forceRefresh: true));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoader.homeTasksShimmerLoading(context);
          }
          if (snapshot.hasError) {
            return Ui.buildNoInternetUI(theme, textTheme, true, "Error !",
                'Request timed out.\nSomething went wrong.', Icons.error,
                    ()=> FetchDataService.fetchData(context, forceRefresh: true));
          }

          return Consumer<AllCampaignsProvider>(
              builder: (context, allCampaignsProvider, child) {
                if (allCampaignsProvider.isLoading) {
                  return  Ui.loading(context);
                } else if (allCampaignsProvider.errorMessage == "User Error") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Helper.logout();
                  });
                  return SizedBox();
                } else if (allCampaignsProvider.errorMessage.isNotEmpty) {
                  return Ui.buildNoInternetUI(theme, textTheme, true, allCampaignsProvider.errorMessage.toString(),
                      'Unstable network connection. Request timed out. Please check your internet connection.', Icons.portable_wifi_off_rounded,
                          ()=> FetchDataService.fetchData(context, forceRefresh: true));
                  return SizedBox();
                } else if (allCampaignsProvider.allCampaigns.isEmpty) {
                  return Ui.buildNoInternetUI(theme, textTheme, false, 'No Tasks Found',
                      'Your tasks may be completed, please wait for new tasks and check back later.', Icons.content_paste_search_outlined,
                          ()=> FetchDataService.fetchData(context, forceRefresh: true));
                }

            final campaign = allCampaignsProvider.allCampaigns[_currentIndex];

            return RefreshIndicator(
              color: theme.onPrimaryContainer,
              onRefresh: () => FetchDataService.fetchData(context, forceRefresh: true),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Task Image
                    InkWell(onTap: ()=> taskNavigation(
                campaign['videoUrl'], campaign['selectedOption'],
                campaign['watchTime'], campaign['CostPer'], campaign['_id'], false, campaign['social']
              ),
                      child: BgBox(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        allRaduis: 7,
                        wth: double.infinity,
                        hgt: 300,

                        child: (campaign['selectedOption'] == 'Subscribers') ?
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.onPrimaryContainer, width: 1.0),
                              ),
                              child: ClipOval(
                                child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', 120, 120)
                              ),
                            ),
                            (isReview)?SizedBox():
                            Image.asset('assets/ico/${campaign['social'] == "YouTube"
                                ? 'youtube_icon.webp'
                                : campaign['social'] == "TikTok"
                                ? 'tiktok_icon.webp'
                                : 'insta_icon.webp'}', width: 30,),

                            const SizedBox(height: 10,),
                            Text('${campaign['title']?? 'Unknow'}', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: textTheme.displaySmall?.
                                copyWith(fontSize: 22,color: theme.onPrimaryContainer,)),
                          ],
                        )

                          : Stack(
                            children: [
                              ClipRRect(
                               child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', double.infinity, 300)
                               ),
                              Positioned(bottom: 5, left: 0, right: 0,
                                child: Container(
                                  width: double.infinity,
                                  color: Colors.black45,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text('${campaign['title']?? 'Unknow'}', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 15,color: Colors.white)),
                                ),
                              ),
                              Positioned(top: 5, left: 7, right: 0,
                                child:  Text('${campaign['catagory']?? ' '}', maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: textTheme.displaySmall?.
                                      copyWith(fontSize: 18,color: Colors.red, fontWeight: FontWeight.bold)),
                                ),

                              Center(
                                child:(isReview)?SizedBox(): Image.asset('assets/ico/${campaign['social'] == "YouTube"?'youtube_icon.webp':
                                campaign['social'] == "TikTok" ? "tiktok_icon.webp": campaign['social'] == "Website" ? "web.webp"
                                    : 'insta_icon.webp'}', width: 40,),
                              ),
                            ],
                          ),
                      ),
                    ),

                    // Task Details
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      allRaduis: 7,
                      child:Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/ico/1xTickets.webp', width: 35,),
                              SizedBox(width: 5,),
                              Text('${campaign['CostPer']}', style: textTheme.bodySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),),
                            ],),

                          Container(width: 3, height: 35, color: theme.shadow,),

                          (campaign['social']=="YouTube"|| campaign['social']=="Website")?
                          Row(spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${campaign['watchTime']}', style: textTheme.bodySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),),
                              Text('Seconds', style: textTheme.bodySmall?.copyWith(height: 2.2, fontWeight: FontWeight.bold)),
                            ],):Text(campaign['selectedOption'] == "Likes"
                              ? 'Like'
                              : campaign['selectedOption'] == "Favorites"
                              ? 'Favorite'
                              : campaign['selectedOption'] == "Comments"
                              ? 'Comment'
                              : 'Follow', style: textTheme.bodySmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                        ],),),

                    // Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Provider.of<UserProvider>(context).autoTask && (campaign['social']=="YouTube") &&
                (campaign['selectedOption']=="Likes" || campaign['selectedOption']=="Subscribers"|| campaign['selectedOption']=="WatchTime")
                          ?
                        Container(
                          width: double.infinity,
                          height: 45,
                          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          child: MyButton(
                            txt: "Start Auto Task",
                            shadowOn: true,
                            borderLineOn: true,
                            bgColor: theme.secondaryContainer,
                            txtSize: 16,
                            txtColor: Colors.white,
                            icoSize: 17,
                            borderRadius: 30,
                            ico: Icons.motion_photos_auto_outlined,
                            onClick: (){
                              if(userAutoLimit==0){
                                AlertMessage.errorMsg(context, "You've reached your Auto Task limit. You can still complete manual tasks to earn more!", "$userAutoLimit Limit");
                                Provider.of<UserProvider>(context, listen: false).setAutoTask(false);
                              }else{
                                taskNavigation(
                                    campaign['videoUrl'], campaign['selectedOption'],
                                    campaign['watchTime'], campaign['CostPer'], campaign['_id'], true, campaign['social']);
                              }
                            },),
                      ): Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              child: MyButton(
                                  txt: (isReview)? "":campaign['social'] == "YouTube" || campaign['social'] == "Website"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? 'Like'
                                      : campaign['selectedOption'] == "WatchTime"
                                      ? 'Watch'
                                      : campaign['selectedOption'] == "Comments"
                                      ? 'Comment'
                                      : campaign['selectedOption'] == "Visitors"
                                      ? 'Web Visit'
                                      : 'Subscribe')
                                      : campaign['social'] == "TikTok" || campaign['social'] == "Instagram"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? 'Like'
                                      : campaign['selectedOption'] == "Favorites"
                                      ? 'Favorite'
                                      : campaign['selectedOption'] == "Comments"
                                      ? 'Comment'
                                      : 'Follow')
                                      : 'Loading...',
                                  shadowOn: true,
                                  borderLineOn: true,
                                  shadowColor: theme.primaryFixed,
                                  bgColor: theme.onPrimary,
                                  txtSize: 16,
                                  icoSize: 18,
                                  borderRadius: 10,
                                  ico: campaign['social'] == "YouTube" || campaign['social'] == "Website"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? Icons.thumb_up
                                      : campaign['selectedOption'] == "WatchTime"
                                      ? Icons.ondemand_video_outlined
                                      : campaign['selectedOption'] == "Comments"
                                      ? Icons.comment
                                      : campaign['selectedOption'] == "Visitors"
                                      ? CupertinoIcons.globe
                                      : Icons.subscriptions_rounded)
                                      : campaign['social'] == "TikTok"|| campaign['social'] == "Instagram"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? Icons.favorite
                                      : campaign['selectedOption'] == "Favorites"
                                      ? Icons.bookmark
                                      : campaign['selectedOption'] == "Comments"
                                      ? Icons.comment
                                      : Icons.group)
                                      : Icons.help_outline,
                                onClick: (){
                                  taskNavigation(
                                    campaign['videoUrl'], campaign['selectedOption'],
                                    campaign['watchTime'], campaign['CostPer'], campaign['_id'], false, campaign['social']
                                  );

                                }),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              child: MyButton(
                                  txt: "Next Task",
                                  shadowOn: true,
                                  borderLineOn: true,
                                  shadowColor: theme.primaryFixed,
                                  bgColor: theme.onPrimary,
                                  ico: Icons.double_arrow_rounded,
                                  borderRadius: 10,
                                  txtSize: 16,
                                  icoSize: 17,
                                  onClick: _showNextCampaign),
                            ),
                          ),
                        ]),
                    ),

                    // if (!userIsPremium)
                    //   Container(
                    //     margin: EdgeInsets.only(top: 10), child: UnityAdsManager.bannerAd(),),

                  ]),
              ),
            );
          });
      });
  }
}
