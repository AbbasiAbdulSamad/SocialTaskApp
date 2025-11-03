import 'dart:async';
import 'dart:ui' as ui;
import 'package:app/server_model/rate_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/fetch_taskts.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/bg_box.dart';
import '../../ui/flash_message.dart';
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
    TikTokTaskHandler.handleLifecycle(state, context);
  }

  Future<void> _checkInternet() async {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    setState(() {
      _internetCheck = internetProvider.isConnected;
    });
  }


  Future<void> showOverlayWithPermission() async {
    bool? granted = await FlutterOverlayWindow.isPermissionGranted();

    if (granted != true) {
      await FlutterOverlayWindow.requestPermission();
      granted = await FlutterOverlayWindow.isPermissionGranted();
    }

    if (granted == true) {
      await FlutterOverlayWindow.showOverlay(
        width: WindowSize.matchParent,
        height: 600,
        alignment: OverlayAlignment.topLeft,
        flag: OverlayFlag.defaultFlag,
        enableDrag: false,
        overlayTitle: "Social Task Overlay",
        overlayContent: "overlayMain", // 👈 must match entrypoint
        visibility: NotificationVisibility.visibilityPublic,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Overlay permission not granted!')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    ColorScheme _theme = Theme.of(context).colorScheme;
    TextTheme _textTheme = Theme.of(context).textTheme;
    final userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser?.autoLimit ?? 0;

    // ✅ Internet Provider
    return FutureBuilder(
      future: _fetchDataFuture,
      builder: (context, snapshot) {
        if (!_internetCheck){
          return Ui.buildNoInternetUI(_theme, _textTheme,false, 'No internet connection',
              'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
                  ()=> FetchDataService.fetchData(context, forceRefresh: true));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoader.buildShimmerLoading();
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
                    onTap: () async{
                      await _checkInternet();
                      // Check Task Click Internet
                      if (_internetCheck) {
                        // Tiktok Task
                        if(campaign['social']=="TikTok"){
                          TikTokTaskHandler.startTikTokTask(
                            context: context,
                            tiktokUrl: campaign['videoUrl'],
                            taskType: campaign['selectedOption'],
                            campaignId: campaign['_id'],
                            reward: campaign['CostPer'],
                            screenFrom: 1,
                          );

// 🟢 Check permission first, then show overlay
                          await showOverlayWithPermission();

                          // Instagram Task Navigate
                        }else if(campaign['social']=="Instagram"){
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Instagram_Task_Screen(
                              taskUrl: campaign['videoUrl'], selectedOption: campaign['selectedOption'],
                              reward: campaign['CostPer'], campaignId: campaign['_id'], screenFrom: 1,),
                          ),);
                        }
                        else{
                          //  YT Auto Task Conditions
                          final autoButton = Provider.of<UserProvider>(context, listen: false).autoTask;
                          if(autoButton && (campaign['social']=="YouTube") &&
                              (campaign['selectedOption']=="Likes" || campaign['selectedOption']=="Subscribers"
                                  || campaign['selectedOption']=="WatchTime")){

                            // if Auto Limit 0 Alert
                            if(userAutoLimit==0){
                              AlertMessage.errorMsg(context, "You've reached your Auto Task limit. You can still complete manual tasks to earn more!", "$userAutoLimit Limit");
                              Provider.of<UserProvider>(context, listen: false).setAutoTask(false);
                            }else{
                              //  YT Auto Task Navigate
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => YT_Auto_Task_Screen(
                                  taskUrl: campaign['videoUrl'], selectedOption: campaign['selectedOption'], watchTime: campaign['watchTime'],
                                  reward: campaign['CostPer'], campaignId: campaign['_id'], screenFrom: 1,),
                              ),);
                            }
                          }else{
                            //  YT Simple Task Navigate
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> YT_Task_Screen(taskUrl: campaign['videoUrl'], selectedOption: campaign['selectedOption'],
                              watchTime: campaign['watchTime'], reward: campaign['CostPer'], campaignId: campaign['_id'], screenFrom: 1,)));
                          }
                        }
                      } else {
                        //  No Internet Alert
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Color(0xff505050),
                            content: Text("No internet connection. Please check and try again.",
                              style: _textTheme.displaySmall?.copyWith(color: Colors.white),),),);}
                    },
                    child: BgBox(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                        allRaduis: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(spacing: 10,
                            children: [
                              (campaign['campaignImg'] != '')
                                  ? (campaign['selectedOption'] == 'Subscribers')
                                  ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _theme.onPrimaryContainer, width: 1.0),
                                ),
                                child: ClipOval(
                                    child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', 60, 60)
                                ),
                              )
                                  : ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', 80, 55)
                              )
                                  : Image.asset('assets/ico/image_loading.png',
                                  width: 75, height: 50, color: _theme.onPrimaryContainer),


                              Expanded(
                                child: Column(spacing:5,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start, // Left align everything
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Row(spacing: 3,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Image.asset("assets/ico/${(campaign["social"]=="YouTube") ?"youtube_icon.webp":
                                          (campaign["social"]=="TikTok")?"tiktok_icon.webp":
                                          "instagram_icon.webp"}",width: 20,),
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
                                    ),

                                    Ui.lightLine(),
                                    Row(spacing: 2,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 5),
                                          child: Text('${campaign['catagory']?? 'Unknow'}', maxLines: 1, overflow: TextOverflow.ellipsis,
                                              style: _textTheme.displaySmall?.
                                              copyWith(fontSize: 14, height: 0, color: _theme.onPrimaryContainer,)),
                                        ),

                                        (campaign['social']=="YouTube")?
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_filled, size: 16,),
                                            Text('${campaign['watchTime']}',  maxLines: 1, overflow: TextOverflow.ellipsis, style: _textTheme.displaySmall?.
                                            copyWith(fontSize: 16,  height: 0, fontWeight: FontWeight.bold, color: _theme.onPrimaryContainer,)),
                                            const SizedBox(width: 2,),
                                            Text('Sec', style: TextStyle(fontSize: 10),),
                                          ],):const SizedBox()
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                child: Column(
                                  children: [
                                    Text('${campaign['CostPer']}', style: _textTheme.displaySmall?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),),
                                    Text('Tickets', style: _textTheme.displaySmall,),
                                  ],
                                ),)

                            ],),
                        ) // End Container
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}