import 'dart:async';
import 'package:app/server_model/functions_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/fetch_taskts.dart';
import '../../server_model/provider/users_provider.dart';
import '../../server_model/rate_app.dart';
import '../../server_model/review_mode.dart';
import '../../ui/bg_box.dart';
import '../../ui/flash_message.dart';
import '../../ui/pop_alert.dart';
import '../../ui/shimmer_loading.dart';
import '../../ui/ui_helper.dart';
import '../task_screen/Tiktok_Task/tiktok_task_handler.dart';
import '../task_screen/YT_Tasks/yt_auto_task_screen.dart';
import '../task_screen/YT_Tasks/yt_task_screen.dart';
import '../task_screen/instagram_Task/instagram_task_screen.dart';

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  _Screen3State createState() => _Screen3State();
}
class _Screen3State extends State<Screen3> with WidgetsBindingObserver{
  late Future<void> _fetchDataFuture;
  bool _internetCheck = true;
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

    // 🔹 Jab app close / background me jaye:
    if (state == AppLifecycleState.detached) {
      debugPrint("🧩 App closed or minimized → closing overlay");
      FlutterOverlayWindow.closeOverlay();
    }
  }


  Future<void> _checkInternet() async {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    setState(() {
      _internetCheck = internetProvider.isConnected;
    });
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
    ColorScheme _theme = Theme.of(context).colorScheme;
    TextTheme _textTheme = Theme.of(context).textTheme;
    final userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser?.autoLimit ?? 0;

    // ✅ Internet Provider
    return WillPopScope(
        onWillPop: () async {
          if (Provider.of<AllCampaignsProvider>(context, listen: false).isSelectionMode) {
            Provider.of<AllCampaignsProvider>(context, listen: false).clearSelectionMode();
            return false;
          }
          return true;
      },
      child: FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (!_internetCheck){
            return Ui.buildNoInternetUI(_theme, _textTheme,false, 'No internet connection',
                'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
                    ()=> FetchDataService.fetchData(context, forceRefresh: true));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoader.homeTasksShimmerLoading(context);
          }

          return Consumer<AllCampaignsProvider>(
            builder: (context, allCampaignsProvider, child) {
              if (allCampaignsProvider.isLoading) {
                return  Ui.loading(context);
              } else if (allCampaignsProvider.errorMessage.isNotEmpty) {
                return Ui.buildNoInternetUI(_theme, _textTheme, true, allCampaignsProvider.errorMessage.toString(),
                    'Unstable network connection. Request timed out. Please check your internet connection.', Icons.portable_wifi_off_rounded,
                        ()=> FetchDataService.fetchData(context, forceRefresh: true));
              } else if (allCampaignsProvider.allCampaigns.isEmpty) {
                return Ui.buildNoInternetUI(_theme, _textTheme, false, 'No Tasks Found',
                    'Your tasks may be completed, please wait for new tasks and check back later.', Icons.content_paste_search_outlined,
                        ()=> FetchDataService.fetchData(context, forceRefresh: true));
              }

              return RefreshIndicator(
                color: _theme.onPrimaryContainer,
                onRefresh: () => FetchDataService.fetchData(context, forceRefresh: true),
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: allCampaignsProvider.allCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = allCampaignsProvider.allCampaigns[index];



                    return InkWell(
                      onLongPress: () {
                        allCampaignsProvider.enterSelectionMode(campaign['_id'].toString());
                      },
                      onTap: () async {
                        await _checkInternet();

                        if (allCampaignsProvider.isSelectionMode) {
                          allCampaignsProvider.toggleTaskSelection(campaign['_id'].toString());
                        } else {
                          if (_internetCheck) {
                            // Tiktok Task
                            if (campaign['social'] == "TikTok") {
                              // TikTok Check permission first, then show overlay
                              await tiktokTaskOverlay(
                                  campaign['selectedOption'],
                                  campaign['videoUrl'],
                                  campaign['_id'],
                                  campaign['CostPer']);

                              // Instagram Task Navigate
                            } else if (campaign['social'] == "Instagram") {
                              Helper.navigatePush(context,
                                Instagram_Task_Screen(
                                taskUrl: campaign['videoUrl'],
                                selectedOption: campaign['selectedOption'],
                                reward: campaign['CostPer'],
                                campaignId: campaign['_id'],
                                screenFrom: 1,),);
                            }
                            else {
                              //  YT Auto Task Conditions
                              final autoButton = Provider
                                  .of<UserProvider>(context, listen: false)
                                  .autoTask;
                              if (autoButton &&
                                  (campaign['social'] == "YouTube") &&
                                  (campaign['selectedOption'] == "Likes" ||
                                      campaign['selectedOption'] ==
                                          "Subscribers"
                                      || campaign['selectedOption'] ==
                                          "WatchTime")) {
                                // if Auto Limit 0 Alert
                                if (userAutoLimit == 0) {
                                  AlertMessage.errorMsg(context,
                                      "You've reached your Auto Task limit. You can still complete manual tasks to earn more!",
                                      "$userAutoLimit Limit");
                                  Provider.of<UserProvider>(
                                      context, listen: false).setAutoTask(
                                      false);
                                } else {
                                  //  YT Auto Task Navigate
                                  Helper.navigatePush(context,
                                    YT_Auto_Task_Screen(
                                      taskUrl: campaign['videoUrl'],
                                      selectedOption: campaign['selectedOption'],
                                      watchTime: campaign['watchTime'],
                                      reward: campaign['CostPer'],
                                      campaignId: campaign['_id'],
                                      screenFrom: 1,),);
                                }
                              } else {
                                //  YT Simple Task Navigate
                                Helper.navigatePush(context,
                                    YT_Task_Screen(
                                      taskUrl: campaign['videoUrl'],
                                      selectedOption: campaign['selectedOption'],
                                      watchTime: campaign['watchTime'],
                                      reward: campaign['CostPer'],
                                      campaignId: campaign['_id'],
                                      screenFrom: 1,));

                              }
                            }
                          } else {
                            //  No Internet Alert
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(backgroundColor: Color(0xff505050),
                                content: Text(
                                  "No internet connection. Please check and try again.",
                                  style: _textTheme.displaySmall?.copyWith(
                                      color: Colors.white),),),);
                          }
                        }
                        },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: allCampaignsProvider.selectedTaskIds
                              .contains(campaign['_id'].toString())
                              ? Colors.blue.withOpacity(0.2)
                              : _theme.background,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: _theme.onPrimaryFixed, width: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: _theme.shadow,
                              offset: const Offset(0, 4),
                              blurRadius: 3,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IntrinsicHeight( // ⭐ KEY FIX
                          child: Row(
                            children: [

                              // ---------- IMAGE ----------
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: (campaign['campaignImg'] != '')
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Ui.networkImage(
                                    context,
                                    "${campaign['campaignImg']}",
                                    'assets/ico/image_loading.png',
                                    80,
                                    55,
                                  ),
                                )
                                    : Image.asset(
                                  'assets/ico/image_loading.png',
                                  width: 75,
                                  height: 50,
                                  color: _theme.onPrimaryContainer,
                                ),
                              ),

                              // ---------- MAIN CONTENT ----------
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(spacing: 3,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          (isReview)? Text((campaign["social"]=="YouTube") ?"YT":
                                          (campaign["social"]=="TikTok")?"TT":
                                          "Insta", style: TextStyle(fontWeight: FontWeight.w800),)

                                              :Image.asset("assets/ico/${(campaign["social"]=="YouTube") ?"youtube_icon.webp":
                                          (campaign["social"]=="TikTok")?"tiktok_icon.webp":
                                          "insta_icon.webp"}",width: 20,),
                                          Icon(Icons.arrow_forward_ios, size: 16, color: _theme.onPrimaryContainer,),

                                          Icon(campaign["social"] == "YouTube"
                                              ? (campaign['selectedOption'] == "Likes"
                                              ? Icons.thumb_up
                                              : campaign['selectedOption'] == "WatchTime"
                                              ? Icons.video_collection
                                              : campaign['selectedOption'] == "Comments"
                                              ? Icons.comment
                                              : Icons.subscriptions)

                                              : campaign["social"] == "TikTok" || campaign["social"] == "Instagram"
                                              ? (campaign['selectedOption'] == "Likes"
                                              ? Icons.favorite
                                              : campaign['selectedOption'] == "Favorites"
                                              ? Icons.bookmark
                                              : campaign['selectedOption'] == "Comments"
                                              ? Icons.chat_bubble_outline
                                              : Icons.person_add_alt_1)
                                              : Icons.help_outline, size: 15,

                                            color: campaign["social"] == "YouTube"
                                                ? (campaign['selectedOption'] == "Likes"
                                                ? Colors.blueAccent
                                                : campaign['selectedOption'] == "Subscribers"
                                                ? Colors.red
                                                : _theme.onPrimaryContainer)

                                                : campaign["social"] == "TikTok" || campaign["social"] == "Instagram"
                                                ? (campaign['selectedOption'] == "Likes"
                                                ? Colors.pinkAccent
                                                : campaign['selectedOption'] == "Favorites"
                                                ? Colors.deepOrange
                                                : campaign['selectedOption'] == "Comments"
                                                ? Colors.purple
                                                : _theme.onPrimaryContainer)
                                                : _theme.onPrimaryContainer,),
                                          (isReview)?SizedBox():
                                          Text(
                                            campaign["social"] == "YouTube"
                                                ? campaign['selectedOption'] == "Likes"
                                                ? 'Like Video'
                                                : campaign['selectedOption'] == "WatchTime"
                                                ? 'Watch Video'
                                                : campaign['selectedOption'] == "Comments"
                                                ? 'Comment'
                                                : 'Subscribe'
                                                : campaign["social"] == "TikTok" || campaign["social"] == "Instagram"
                                                ? campaign['selectedOption'] == "Likes"
                                                ? 'Like'
                                                : campaign['selectedOption'] == "Comments"
                                                ? 'Comment'
                                                : campaign['selectedOption'] == "Favorites"
                                                ? 'Favorite'
                                                : 'Follow'
                                                : '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: _textTheme.displaySmall?.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: _theme.onPrimaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Ui.lightLine(),

                                      Row(spacing: 2,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text('${campaign['catagory']?? 'Unknow'}', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: _textTheme.displaySmall?.
                                                copyWith(fontSize: 15, height: 0, color: _theme.onPrimaryContainer,)),
                                          ),

                                          (campaign['social']=="YouTube")?
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time, size: 15,),
                                              Text('${campaign['watchTime']}',  maxLines: 1, overflow: TextOverflow.ellipsis, style: _textTheme.displaySmall?.
                                              copyWith(fontSize: 16,  height: 0, color: _theme.onPrimaryContainer,)),
                                              const SizedBox(width: 2,),
                                              Text('Sec', style: TextStyle(fontSize: 12),),
                                            ],):const SizedBox()
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),

                              // ---------- TICKETS (FULL HEIGHT, NO OVERFLOW) ----------
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 5),
                                decoration: BoxDecoration(
                                  color: _theme.background,
                                  border: Border(left: BorderSide(width: 0.5, color: _theme.onPrimaryFixed),
                                  top: BorderSide(width: 0.5, color: _theme.onPrimaryFixed), bottom: BorderSide(width: 0.5, color: _theme.onPrimaryFixed)),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10),

                                      topLeft: Radius.circular(100),
                                      bottomLeft: Radius.circular(100)
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${campaign['CostPer']}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: _theme.onPrimaryContainer,
                                      ),
                                    ),
                                     Row( spacing: 2,
                                       children: [
                                         Image.asset('assets/ico/1xTickets.webp', width: 12,),
                                         Text('Tickets',
                                          style: TextStyle(color: _theme.onPrimaryContainer, fontSize: 10),
                                                                             ),
                                       ],
                                     ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}