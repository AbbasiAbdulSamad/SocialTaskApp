import 'dart:async';
import 'dart:math';
import 'package:app/server_model/provider/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/fetch_taskts.dart';
import '../../server_model/internet_provider.dart';
import '../../ui/bg_box.dart';
import '../../ui/button.dart';
import '../../ui/flash_message.dart';
import '../../ui/ui_helper.dart';
import '../task_screen/Tiktok_Task/tiktok_task_handler.dart';
import '../task_screen/YT_Tasks/yt_auto_task_screen.dart';
import '../task_screen/YT_Tasks/yt_task_screen.dart';
import '../task_screen/instagram_Task/insta_auto_task_screen.dart';
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
    TikTokTaskHandler.handleLifecycle(state, context);
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
        if(social=="Instagram" && selectedOption=="Followers" || selectedOption=="Likes"){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => Instagram_Auto_Task_Screen(
              taskUrl: taskUrl, selectedOption: selectedOption,
              reward: reward, campaignId: campaignId, screenFrom: 0,),
          ),);
        }else{
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => YT_Auto_Task_Screen(
              taskUrl: taskUrl,
              selectedOption: selectedOption,
              watchTime: watchTime,
              reward: reward,
              campaignId: campaignId,
              screenFrom: 0,
            ),
          ),);
        }
      }else{
        if(social=="TikTok"){
          TikTokTaskHandler.startTikTokTask(
            context: context,
            tiktokUrl: taskUrl,
            taskType: selectedOption,
            campaignId: campaignId,
            reward: reward,
            screenFrom: 0,
          );
        }else if(social=="Instagram"){
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Instagram_Task_Screen(
            taskUrl: taskUrl,
            selectedOption: selectedOption,
            reward: reward,
            campaignId: campaignId,
            screenFrom: 0,)
          ),);

        }else{
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => YT_Task_Screen(
              taskUrl: taskUrl,
              selectedOption: selectedOption,
              watchTime: watchTime,
              reward: reward,
              campaignId: campaignId,
              screenFrom: 0,
            ),
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


  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser?.autoLimit ?? 0;

    return FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (!_internetCheck){
            return Ui.buildNoInternetUI(theme, textTheme,false, 'No internet connection',
                'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
                    ()=> FetchDataService.fetchData(context, forceRefresh: true));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Ui.loading(context);
          }

          return Consumer<AllCampaignsProvider>(
              builder: (context, allCampaignsProvider, child) {
                if (allCampaignsProvider.isLoading) {
                  return  Center(child: CircularProgressIndicator(color: theme.onPrimaryContainer,),);
                } else if (allCampaignsProvider.errorMessage.isNotEmpty) {
                  return Ui.buildNoInternetUI(theme, textTheme, true, allCampaignsProvider.errorMessage.toString(),
                      'Unstable network connection. Request timed out. Please check your internet connection.', Icons.portable_wifi_off_rounded,
                          ()=> FetchDataService.fetchData(context, forceRefresh: true));
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
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                            Image.asset('assets/ico/${campaign['social'] == "YouTube"
                                ? 'youtube_icon.webp'
                                : campaign['social'] == "TikTok"
                                ? 'tiktok_icon.webp'
                                : 'instagram_icon.webp'}', width: 30,),

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
                                child: Image.asset('assets/ico/${campaign['social'] == "YouTube"?'youtube_icon.webp':
                                campaign['social'] == "TikTok" ? "tiktok_icon.webp"
                                    : 'instagram_icon.webp'}', width: 80,),
                              ),
                            ],
                          ),
                      ),
                    ),

                    // Task Details
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                      allRaduis: 7,
                      child:Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${campaign['CostPer']}', style: textTheme.bodySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),),
                              Text('Tickets', style: textTheme.bodySmall?.copyWith(height: 2.2, fontWeight: FontWeight.bold)),
                            ],),

                          Container(width: 3, height: 35, color: theme.shadow,),

                          (campaign['social']=="YouTube")?Row(spacing: 3,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${campaign['watchTime']}', style: textTheme.bodySmall?.copyWith(fontSize: 30, fontWeight: FontWeight.bold),),
                              Text('Seconds', style: textTheme.bodySmall?.copyWith(height: 2.2, fontWeight: FontWeight.bold)),
                            ],):Text('${campaign['selectedOption'] == "Likes"
                              ? 'Like'
                              : campaign['selectedOption'] == "Favorites"
                              ? 'Favorite'
                              : campaign['selectedOption'] == "Comments"
                              ? 'Comment'
                              : 'Follow'}', style: textTheme.bodySmall?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                        ],),),

                    // Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Provider.of<UserProvider>(context).autoTask &&
                          (campaign['social'] == "YouTube" ||
                          (campaign['social'] == "Instagram" &&
                          (campaign['selectedOption'] == "Followers" || campaign['selectedOption'] == "Likes")))
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
                                  txt: campaign['social'] == "YouTube"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? 'Like'
                                      : campaign['selectedOption'] == "WatchTime"
                                      ? 'Watch'
                                      : campaign['selectedOption'] == "Comments"
                                      ? 'Comment'
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
                                  icoSize: 17,
                                  borderRadius: 10,
                                  ico: campaign['social'] == "YouTube"
                                      ? (campaign['selectedOption'] == "Likes"
                                      ? Icons.thumb_up
                                      : campaign['selectedOption'] == "WatchTime"
                                      ? Icons.ondemand_video_outlined
                                      : campaign['selectedOption'] == "Comments"
                                      ? Icons.comment
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
                  ]),
              ),
            );
          });
      });
  }
}
