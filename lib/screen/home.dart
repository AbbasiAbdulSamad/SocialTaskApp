import 'package:app/screen/social_login.dart';
import 'package:app/ui/flash_message.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../pages/sidebar_pages/buy_tickets.dart';
import '../server_model/internet_provider.dart';
import '../server_model/provider/fetch_taskts.dart';
import '../server_model/provider/users_provider.dart';
import '../ui/button.dart';
import '../ui/pop_alert.dart';
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

    Future.microtask(() async {
      await Future.wait([
        Provider.of<AllCampaignsProvider>(context, listen: false).fetchAllCampaigns(context: context, forceRefresh: true),
        Provider.of<UserProvider>(context, listen: false).fetchCurrentUser(),
      ]);
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

    final List<String> socialList = ["YouTube", "TikTok", "Instagram"];
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
          style: const TextStyle(fontSize: 22, color: Colors.white),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> BuyTickets()));
                },
              child: Row(spacing: 5,
                children: [
                  Text("${userProvider.currentUser?.coin ?? 0}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
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

          // 🔝 Fixed Hearder Tools bar
          (_currentIndex==2)?
          SizedBox():
          Container(
            padding: const EdgeInsets.only(left: 5, right: 10),
            width: double.infinity,
            color: theme.shadow,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          SocialLogins(loginSocial: "YouTube")));
                                    }),

                                MyButton(txt: 'Instagram Login', img: 'instagram_icon.webp', bgColor: theme.secondary,
                                    borderLineOn: true, borderColor: theme.onPrimaryContainer, borderLineSize: 0.5, borderRadius: 20,
                                    txtColor: Colors.white, txtSize: 15, icoSize: 30, pading: EdgeInsets.symmetric(horizontal: 30),
                                    onClick: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          SocialLogins(loginSocial: "Instagram")));
                                    }),

                                MyButton(txt: 'Linkedin Login', img: 'linkedin_icon.webp', bgColor: theme.secondary,
                                    borderLineOn: true, borderColor: theme.onPrimaryContainer, borderLineSize: 0.5, borderRadius: 20,
                                    txtColor: Colors.white, txtSize: 15, icoSize: 30, pading: EdgeInsets.symmetric(horizontal: 30),
                                    onClick: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                          SocialLogins(loginSocial: "Linkedin")));
                                    })

                              ],),
                          ));

                    }, icon: Icon(Icons.login, size: 25, color: theme.onPrimaryContainer,)),
                  ),


                  Transform.scale(
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
                  Text(Provider.of<UserProvider>(context).autoTask==true? "$userAutoLimit": "Auto",
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

                                            const SizedBox(height: 20,),
                                            Ui.buildMultiSelectDropdown(context,
                                              title: "Categories", items: categoryList,
                                              selectedItems: selectedCategories, setState: setState,),

                                            const SizedBox(height: 20),
                                            Ui.buildMultiSelectDropdown(context,
                                              title: "Task Type", items: optionList,
                                              selectedItems: selectedOptions, setState: setState,
                                            ),

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
                    child: Tooltip(
                      message: "Task Filters",
                      child: Row(
                        children: [
                          Text('Filters', style: TextStyle(fontSize: 17, fontFamily: '3rdRoboto', color: theme.onPrimaryFixed),),
                          Icon(Icons.filter_alt, color: theme.onPrimaryFixed,),
                        ],
                      ),
                    ),
                  ),
                  Tooltip(
                    message: "Reset all filters",
                    child: IconButton(onPressed: (){
                      selectedSocial.clear();
                      selectedOptions.clear();
                      selectedCategories.clear();
                      provider.clearFilters();
                      AlertMessage.snackMsg(context: context, message: "Filters have been reset", time: 1);
                    }, icon: Icon(Icons.refresh, size: 25, color: theme.errorContainer,)),
                  ),

                ],
              ),
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
}
