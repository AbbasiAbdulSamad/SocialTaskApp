import 'package:app/pages/sidebar_pages/earn_rewards.dart';
import 'package:app/pages/sidebar_pages/invite.dart';
import 'package:app/pages/sidebar_pages/level.dart';
import 'package:app/pages/sidebar_pages/premium_account.dart';
import 'package:app/pages/sidebar_pages/support.dart';
import 'package:app/screen/social_login.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:app/ui/bg_box.dart';
import 'package:app/ui/flash_message.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../pages/sidebar_pages/buy_tickets.dart';
import '../pages/sidebar_pages/leaderboard.dart';
import '../server_model/LocalNotificationManager.dart';
import '../server_model/internet_provider.dart';
import '../server_model/provider/fetch_taskts.dart';
import '../server_model/provider/users_provider.dart';
import '../server_model/review_mode.dart';
import '../ui/ads.dart';
import '../ui/button.dart';
import '../ui/pop_alert.dart';
import '../ui/shortPageOpen.dart';
import '../ui/sidebar.dart';
import '../ui/ui_helper.dart';
import 'home_screen/screen_1.dart';
import 'home_screen/screen_2.dart';
import 'home_screen/screen_3.dart';
import 'home_screen/screen_4.dart';
import 'home_screen/screen_5.dart';

class Home extends StatefulWidget {
  final int onPage;
  const Home({super.key, required this.onPage});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _pageController;
  late int _currentIndex;
  bool _internetCheck = true;
  int notificationCount = 0;

  // List of Pages
  final List<Widget> _pages = [
    // const screen1(),
    const Screen2(),
    const Screen3(),
    // const screen4(),
    const screen5(),
  ];

  // Page Labels & Icons
  final List<Map<String, dynamic>> _pageLabel = [
    // {'title': 'Category', 'icon': Icons.safety_divider},
    {'title': 'Tasks', 'icon': Icons.add_task},
    {'title': 'Home', 'icon': Icons.home},
    // {'title': 'Traffic', 'icon': Icons.group},
    {'title': 'Campaign', 'icon': Icons.campaign},
  ];

  @override
  void initState() {
    super.initState();
    checkInternet();
    _currentIndex = widget.onPage;
    _pageController = PageController(initialPage: widget.onPage);
    _loadNotificationCount();

    Future.microtask(() async {
      await Future.wait([
        Provider.of<AllCampaignsProvider>(context, listen: false).fetchAllCampaigns(context: context, forceRefresh: true),
        Provider.of<UserProvider>(context, listen: false).fetchCurrentUser(),
      ]);
    });
  }

  Future<void> _loadNotificationCount() async {
    final count = await LocalNotificationManager.getNotificationCount();
    setState(() {
      notificationCount = count;
    });
  }
  // Call this method when page opens to reset
  void _resetCount() async {
    await LocalNotificationManager.resetNotificationCount();
    setState(() {
      notificationCount = 0;
    });
  }

  Future<void> checkInternet() async {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    setState(() {
      _internetCheck = internetProvider.isConnected;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isReview = AppReviewMode.isEnabled();
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // UserProvider Current User from API
    final userProvider = Provider.of<UserProvider>(context);
    final userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser?.autoLimit ?? 0;

    // Filter Pop
    final provider = context.read<AllCampaignsProvider>();
    List<String> selectedSocial = List.from(provider.selectedSocial ?? []);
    List<String> selectedCategories = List.from(provider.selectedCategories ?? []);
    List<String> selectedOptions = List.from(provider.selectedOptions ?? []);

    final List<String> socialList = ["YouTube", "TikTok", "Instagram", "Website"];
    final List<String> optionList = ["Likes", "Subscribers",  "Followers", "Comments", "Favorites", "WatchTime"];
    final List<String> categoryList = [
      "Education", "Gaming", "Technology", "Entertainment", "Health",
      "Business", "Lifestyle", "Motivation", "News & Politics", "Sports",
    ];


    return Scaffold(
      backgroundColor: theme.primaryFixed,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),

        title: Text(_pageLabel[_currentIndex]['title'],
          style: textTheme.displaySmall?.copyWith(fontSize: 23, color: Colors.white),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                if(isReview==false){Helper.navigatePush(context, const BuyTickets());}
                },
              child: Row(spacing: 5,
                children: [
                  Text("${userProvider.currentUser?.coin ?? 0}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: textTheme.displaySmall?.copyWith(
                      fontSize: 22,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                  Image.asset('assets/ico/ticket_icon.webp', width: 38,),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sidebar include
      drawer: Sidebar(),

      // PageView for Navigation
      body: (!_internetCheck)?
      Ui.buildNoInternetUI(theme, textTheme,false, 'No internet connection',
    'Can\'t reach server. Please check your internet connection', Icons.wifi_off,
              ()=> checkInternet()):
      Column(
        children: [

          // 🔝 Header Tools bar
          (_currentIndex==2)?
          const SizedBox():
      Consumer<AllCampaignsProvider>(
          builder: (context, allCampaignsProvider, child) {
            return Container(
              padding: Provider.of<AllCampaignsProvider>(context, listen: false).isSelectionMode?
              const EdgeInsets.only(top: 2, bottom: 2, right: 20, left: 25):
              const EdgeInsets.only(left: 5, right: 10),
              width: double.infinity,
              color: theme.shadow,
              child:
              Provider.of<AllCampaignsProvider>(context, listen: false).isSelectionMode?

            // If Select any task show this Bar tools
              Row(
                children: [
                  InkWell(
                    onTap: (){Provider.of<AllCampaignsProvider>(context, listen: false).clearSelectionMode();},
                    child: Row(spacing: 3,
                      children: [
                        Icon(Icons.select_all, size: 20, color: theme.onPrimaryContainer),
                        Text("Unselect", style: Theme.of(context).textTheme.displaySmall?.
                        copyWith(fontSize: 18, color: theme.onPrimaryContainer),),
                      ],
                    ),
                  ),
                 const Expanded(child: SizedBox()),
                  SizedBox(width: 142,
                    child: DropdownButton<String>(
                      hint: Row(spacing: 3,
                        children: [
                          Icon(Icons.visibility_off, size: 19, color: theme.onPrimaryContainer),
                          Text("Hide Selected", style: Theme.of(context).textTheme.displaySmall?.
                          copyWith(fontSize: 17, color: theme.onPrimaryContainer),),
                        ],
                      ),
                      isExpanded: true,
                      underline:const  SizedBox(),
                      items: ["1 day", "3 day", "5 day", "7 day"].map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          final provider = Provider.of<AllCampaignsProvider>(context, listen: false);
                          provider.hideSelectedTasks(value);
                          provider.clearSelectionMode();
                          AlertMessage.snackMsg(context: context, message: "Selected Tasks Hidden");
                        }
                      },
                    ),
                  )
                ],
              ):

              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(isReview==false) Tooltip(
                      message: "Social Logins",
                      child: IconButton(onPressed: (){
                        Ui.Add_campaigns_pop(context, "Login Your Social Accounts",
                            Container(
                              width: double.infinity,
                              height: 250,
                              color: theme.primaryFixed,
                              child: Column(spacing: 15,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MyButton(txt: 'YouTube Login', img: 'youtube_icon.webp', bgColor: theme.secondary,
                                      borderLineOn: true, borderColor: theme.onPrimaryContainer, borderLineSize: 0.5, borderRadius: 20,
                                      txtColor: Colors.white, txtSize: 15, icoSize: 30, pading: EdgeInsets.symmetric(horizontal: 30),
                                      onClick: (){
                                    Helper.navigatePush(context, const  SocialLogins(loginSocial: "YouTube"));
                                      }),

                                  MyButton(txt: 'Instagram Login', img: 'insta_icon.webp', bgColor: theme.secondary,
                                      borderLineOn: true, borderColor: theme.onPrimaryContainer, borderLineSize: 0.5, borderRadius: 20,
                                      txtColor: Colors.white, txtSize: 15, icoSize: 30, pading: EdgeInsets.symmetric(horizontal: 30),
                                      onClick: (){
                                        Helper.navigatePush(context, const  SocialLogins(loginSocial: "Instagram"));
                                      }),

                                ],),
                            ));

                      }, icon: Icon(Icons.login, size: 25, color: theme.onPrimaryContainer,)),
                    ),


                    if(isReview==false) Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: Provider.of<UserProvider>(context).autoTask,
                        activeColor: theme.errorContainer,
                        inactiveThumbColor: Colors.red,
                        onChanged: (value) {
                          Provider.of<UserProvider>(context, listen: false).setAutoTask(value);
                          if(value==true){
                            AlertMessage.snackMsg(context: context, message: "Auto YouTube Like/Subscribe Tasks Supported.", time: 2);
                          }
                        },
                      ),
                    ),
                    if(isReview==false)Text(Provider.of<UserProvider>(context).autoTask==true? "$userAutoLimit": "Auto",
                      style:Provider.of<UserProvider>(context).autoTask==true?TextStyle(fontSize: 23):
                      textTheme.labelMedium?.copyWith(fontSize: 20, color: theme.onPrimaryContainer)
                      ,),
                    const Expanded(child: SizedBox()),

                    InkWell(
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  insetPadding: const EdgeInsets.all(20),
                                  shape:  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                                  content: SingleChildScrollView(
                                    child: Container(
                                      height: 350,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [theme.secondary, theme.secondaryContainer,],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Row(spacing: 5,
                                                children: [
                                                  const Icon(Icons.filter_alt, color: Colors.white,),
                                                  Text("Task Filters", style: Theme.of(context).textTheme.displaySmall?.
                                                  copyWith(fontSize: 20, color: Colors.white),),
                                                ],
                                              ),
                                              const SizedBox(height: 50),
                                              Ui.buildMultiSelectDropdown(context,
                                                title: "Social Task", items: socialList,
                                                selectedItems: selectedSocial, setState: setState,
                                              ),

                                              const SizedBox(height: 20),
                                              Ui.buildMultiSelectDropdown(context,
                                                title: "Task Type", items: optionList,
                                                selectedItems: selectedOptions, setState: setState,
                                              ),

                                              const SizedBox(height: 20,),
                                              Ui.buildMultiSelectDropdown(context,
                                                title: "Categories", items: categoryList,
                                                selectedItems: selectedCategories, setState: setState,),

                                            ],
                                          ),

                                          Row(mainAxisAlignment: MainAxisAlignment.end,
                                            spacing: 10,
                                            children: [
                                              TextButton(
                                                child: const Row(spacing: 2,
                                                  children: [
                                                    Icon(Icons.refresh, color: Colors.orange, size: 20,),
                                                    Text("Reset", style: TextStyle(color: Colors.orange, fontSize: 20, fontFamily: "3rdRoboto"),),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  selectedSocial.clear();
                                                  selectedOptions.clear();
                                                  selectedCategories.clear();
                                                  provider.clearFilters();
                                                  Navigator.of(context).pop(false);
                                                },
                                              ),
                                              SizedBox(height: 35, width: 100,
                                                child: MyButton(txt: "Apply", borderRadius: 40, pading: const EdgeInsets.only(left: 20, right: 20), shadowOn: true,
                                                    bgColor: theme.onPrimary, borderLineOn: true, borderLineSize: 0.5, borderColor: theme.onPrimaryContainer, txtSize: 16, txtColor: Colors.black,
                                                    onClick: (){
                                                      provider.setSelectedSocial(selectedSocial);
                                                      provider.setSelectedCategories(selectedCategories);
                                                      provider.setSelectedOptions(selectedOptions);
                                                      Navigator.of(context).pop(true);
                                                    } ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Tooltip(message: "Task Filters",
                        child: Row(
                          children: [
                            Icon(Icons.filter_alt, color: theme.onPrimaryFixed,),
                            Text('Filters', style: TextStyle(fontSize: 17, fontFamily: '3rdRoboto', color: theme.onPrimaryFixed),),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),

                    if(provider.hasHiddenTasks)Tooltip(
                        message: "Show Hidden Tasks",
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async{
                          showDialog(context: context,
                            builder: (BuildContext context) {
                              // pop class import from pop_box.dart
                              return pop.backAlert(context: context,icon: Icons.task_alt_sharp, title: 'Hidden Tasks Show',
                                  bodyTxt:'Are you sure you want to make all hidden tasks visible again?',
                                  confirm: 'Yes Show', onConfirm: () async{
                                    await provider.resetHiddenTasks();
                                    Navigator.pop(context);
                                    AlertMessage.snackMsg(context: context, message: "Hidden Tasks Shown", time: 3);
                                  } );
                            },
                          );
                        }, icon: Icon(Icons.restart_alt, size: 27, color: theme.onPrimaryFixed),)),
                    Tooltip(message: "Notifications",
                      child: Stack(
                        children: [
                          IconButton(icon: Icon(Icons.notifications, size: 27,), color: theme.onPrimaryFixed,
                            onPressed: (){
                              _resetCount();
                            Shortpageopen.shortPage(context, Icons.notifications, 'Notifications', _notificationsWidget(context));
                            } ,),

                          if(notificationCount>0)
                          Positioned(right: 10, top: 10,
                              child: Text(
                                (notificationCount>=100)?"99+":
                                "$notificationCount", style: textTheme.displaySmall?.
                              copyWith(color: theme.errorContainer, fontWeight: FontWeight.w800, fontSize: 13),))

                        ],
                      ),
                    ),
                  ],
                ),
            );
            }
          ),


          // 📄 PageView below
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _pages,
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: theme.secondaryContainer,
        buttonBackgroundColor: theme.primary,
        height: 55,
        items: List.generate(_pageLabel.length, (index) {
          return (_currentIndex == index)
              ? Icon(_pageLabel[index]['icon'], size: 30,
            color: _currentIndex == index ? theme.onSecondary : Colors.black,
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(_pageLabel[index]['icon'], size: 24,
                  color: _currentIndex == index ? Colors.blueAccent : theme.primary,
                ),
              ),
              Text(
                _pageLabel[index]['title'],
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: const Color(0xFFD7E8FF),
                ),
              ),
            ],
          );
        }),
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }


  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    return await LocalNotificationManager.getNotifications();
  }

  Widget _notificationsWidget(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!;
        if (notifications.isEmpty) {
          return const Center(child: Text("No notifications yet."));
        }

        // Map screen names to actual Widgets
        final Map<String, Widget> screenMap = {
          'LeaderboardScreen':const LeaderboardScreen(),
          'Campaigns':const Home(onPage: 2),
          'DailyReward': EarnTickets(context: context),
          'Ads': EarnTickets(context: context,),
          'Level':const Level(),
          'BuyTickets':const BuyTickets(),
          'PremiumAccount':const PremiumAccount(),
          'Invite':const Invite(),
          'SupportPage':const SupportPage(),
          // Add all your screens here
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final title = notif['title'] ?? '';
              final body = notif['body'] ?? '';
              final dateStr = notif['date'] ?? '';
              final date = DateTime.tryParse(dateStr);
              final screenId = notif['screenId'] ?? '';

              return InkWell(
                onTap: () async{
                  if(screenId=="" || screenId=="Login" || screenId==null){
                    return;
                  }else if(screenId=="Update"){
                    final Uri url = Uri.parse("https://play.google.com/store/apps/details?id=com.socialtask.app",);

                    if (await canLaunchUrl(url)) {
                  await launchUrl(url,mode: LaunchMode.externalApplication,);
                  } else {
                  debugPrint("Could not launch $url");
                  }
                  }else{
                    Helper.navigatePush(context, screenMap[screenId]!);
                  }
                      },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:const  EdgeInsets.only(top: 2, bottom: 10, left: 10, right: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.background,
                      border: Border(bottom: BorderSide(width: 0.4, color: theme.onPrimaryContainer), right: BorderSide(width: 0.5, color: theme.onPrimaryContainer)),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                      boxShadow: [BoxShadow(color: theme.shadow, blurRadius: 8, spreadRadius: 2, offset: Offset(5, 5))]
                                ),
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 0.5, color: theme.onPrimaryFixed))
                        ),
                        child: Text(date != null
                            ? "${date.hour}:${date.minute.toString().padRight(2, '0')}  ${date.day}-${date.month}-${date.year}"
                            : '', style: textTheme.displaySmall?.copyWith(color: theme.onPrimaryFixed, fontSize: 12), textAlign: TextAlign.right,),
                      ),

                      const SizedBox(height: 16,),
                      Row( spacing: 15,
                        children: [
                          Icon((screenId=="Campaigns")?Icons.campaign:
                          (screenId=="Level")?Icons.trending_up:
                          (screenId=="DailyReward")?Icons.card_giftcard:
                          (screenId=="LeaderboardScreen")?Icons.leaderboard:
                          (screenId=="Login")?Icons.login:
                          (screenId=="BuyTickets")?Icons.payments_outlined:
                          (screenId=="PremiumAccount")?Icons.workspace_premium:
                          (screenId=="Invite")?Icons.share:
                          (screenId=="Update")?Icons.download:
                          (screenId=="SupportPage")?Icons.support_agent:
                          (screenId=="Ads")?Icons.ads_click:Icons.notifications, size: 32,),

                          Expanded(
                            child: Column( spacing: 4,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: textTheme.displaySmall?.copyWith(fontSize: 16),
                                ),

                                Text(body, maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

}