import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../../server_model/internet_provider.dart';
import '../../../server_model/provider/fetch_taskts.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../server_model/provider/users_provider.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../../ui/pop_alert.dart';
import '../../home.dart';
import '../../social_login.dart';
import 'insta_comment_list.dart';

class Instagram_Auto_Task_Screen extends StatefulWidget {
  final String taskUrl;
  final String selectedOption;
  final int reward;
  final String campaignId;
  final int screenFrom;

  const Instagram_Auto_Task_Screen({Key? key, required this.taskUrl, required this.selectedOption,
    required this.reward, required this.campaignId, required this.screenFrom,}) : super(key: key);

  @override
  _Instagram_Auto_Task_ScreenState createState() => _Instagram_Auto_Task_ScreenState();
}

class _Instagram_Auto_Task_ScreenState extends State<Instagram_Auto_Task_Screen> {
  late String taskUrl;
  late String selectedOption;
  late int watchTime;
  late int reward;
  late String campaignId;
  late int screenFrom;


  InAppWebViewController? _controller;
  bool _isLoading = true;
  final CookieManager _cookieManager = CookieManager();
  double progress = 0;
  late int _remainingTime;
  bool _isUserLoggedIn = false;
  bool _loginChecked = false;
  bool _showOverlay = true;
  bool _justLoggedIn = false;
  Timer? _timer;
  bool _isPaused = false;
  bool _buttonLoading = false;
  bool _timerInitialized = false;
  late final allCampaignsProvider;
  int _currentIndex = 0;
  bool _isFirstTask = true;
  bool _saveInfoClicked = false;


  @override
  void initState() {
    taskUrl = widget.taskUrl;
    selectedOption = widget.selectedOption;
    watchTime = getRandomWatchTime();
    reward = widget.reward;
    campaignId = widget.campaignId;
    screenFrom = widget.screenFrom;

    _remainingTime = watchTime;
    super.initState();
  }
  int getRandomWatchTime() {
    final random = Random();
    return 16 + random.nextInt(30 - 16 + 1);
  }

  void _startTimer() {
    _timer?.cancel();

    final random = Random();
    int min = 5;
    int max = (watchTime - 5);
    if (max <= min) {max = min + 1;}
    int _actionTriggerTime = min + random.nextInt(max - min);

    debugPrint('Random: $_actionTriggerTime \n  watchTime: $watchTime');

    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      final internetProvider = Provider.of<InternetProvider>(context, listen: false);
      if (!internetProvider.isConnected) {
        setState(() {_isPaused = true;});
        timer.cancel();
        return;
      }

      if (_remainingTime > 0) {
        setState(() {_remainingTime--;});
        if(_remainingTime == _actionTriggerTime && selectedOption == "Followers"){
          debugPrint("follow start");
          checkInstagramFollow();
        }else if(_remainingTime == _actionTriggerTime && selectedOption == "Likes"){
          debugPrint("like start");
          autoLikeInstagramPost();
        }else if(_remainingTime == 0){
          await Future.delayed(Duration(seconds: 2));
          _handleTaskCompletion(context);
        }

      } else {
        timer.cancel();
      }
    });
  }

  void loadNextTask() async {
    final allCampaignsProvider = Provider.of<AllCampaignsProvider>(context, listen: false);
    await Provider.of<UserProvider>(context, listen: false).fetchCurrentUser();
    final _userAutoLimit = Provider.of<UserProvider>(context, listen: false).currentUser!.autoLimit;

    if (allCampaignsProvider.allCampaigns.isEmpty) {
      AlertMessage.snackMsg(context: context, message: 'No tasks found.', time: 3);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home(onPage: widget.screenFrom)),
            (route) => false,
      );
      return;
    }

    if (_userAutoLimit == 0) {
      AlertMessage.snackMsg(
        context: context,
        message: "You've reached your Auto Task limit. You can still complete manual tasks to earn more!",
        time: 3,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home(onPage: widget.screenFrom)),
            (route) => false,
      );
      return;
    }

    final instagramTasks = allCampaignsProvider.allCampaigns
        .where((task) => task['social'] == 'Instagram' &&
        (task['selectedOption'] == 'Likes' || task['selectedOption'] == 'Followers'))
        .toList();


    // 🛠️ Skip current task if already playing
    if (_isFirstTask) {
      _isFirstTask = false;
      _currentIndex++; // move index forward to avoid repeating current
    }

    if (_currentIndex >= instagramTasks.length) {
      AlertMessage.snackMsg(context: context, message: 'All Instagram tasks completed!', time: 3);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home(onPage: widget.screenFrom)),
            (route) => false,
      );
      return;
    }

    final campaign = instagramTasks[_currentIndex];

    setState(() {
      _currentIndex++;
      taskUrl = campaign['videoUrl'];
      selectedOption = campaign['selectedOption'];
      watchTime = 15;
      reward = campaign['CostPer'];
      campaignId = campaign['_id'];

      _loginChecked = false;
      _isUserLoggedIn = true;
      _showOverlay = true;
      _remainingTime = watchTime;
    });

    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(taskUrl)));
    AlertMessage.snackMsg(context: context, message: 'Next task started!', time: 1);
  }



  void _handleInternetChange() {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    if (internetProvider.isConnected) {
      if (_isPaused) {setState(() {_isPaused = false;});
      _timer?.cancel();
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internet Reconnected', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF007306),
          duration: Duration(seconds: 3),),);
      }
    } else {
      _timer?.cancel(); // Internet off hone pe timer pause karein
      setState(() {_isPaused = true;});
      // ✅ Internet off hone par SnackBar show karein
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet Connection!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF8B0E16),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _checkLoginStatus() async {

    List<Cookie> cookies = await _cookieManager.getCookies(
      url: WebUri("https://www.instagram.com"),
    );

    bool isInstagramLoggedIn = cookies.any((cookie) =>
    cookie.name.toLowerCase() == "sessionid" &&
        cookie.value.isNotEmpty) &&
        cookies.any((cookie) =>
        cookie.name.toLowerCase() == "ds_user_id" &&
            cookie.value.isNotEmpty);

    // Check Facebook session cookies (for login via FB)
    List<Cookie> fbCookies = await _cookieManager.getCookies(
      url: WebUri("https://www.facebook.com"),
    );

    bool isFacebookLoggedIn = fbCookies.any((cookie) =>
    (cookie.name.toLowerCase() == "c_user" ||
        cookie.name.toLowerCase() == "fr") &&
        cookie.value.isNotEmpty);

    bool isLoggedIn = isInstagramLoggedIn || isFacebookLoggedIn;

    debugPrint("User is logged in: $isLoggedIn");

    if (!isLoggedIn) {
      debugPrint("🔴 User not logged in. Redirecting to Instagram Login...");

      Navigator.push(context, MaterialPageRoute(builder: (context)=>
          SocialLogins(loginSocial: "Instagram")));

    } else {
      setState(() {_isUserLoggedIn = true;});

      if (!_loginChecked) {
        _loginChecked = true;
        if (_controller != null) {
          await _controller!.loadUrl(
            urlRequest: URLRequest(url: WebUri(widget.taskUrl)),
          );
        }
      }
    }
  }

  void _handleTaskCompletion(BuildContext context) async {
    setState(() {_buttonLoading = true;});

    final internetProvider = Provider.of<InternetProvider>(context, listen: false);

    // 🔌 Check internet
    if (!internetProvider.isConnected) {AlertMessage.snackMsg(context: context,
        message: 'No internet connection. Please connect to the network.', time: 3);

    setState(() {_buttonLoading = false;});return;}
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.completeTaskAuto(
      context: context,
      campaignId: campaignId,
      rewardCoins: reward,
    );
    loadNextTask();
    setState(() {_buttonLoading = false;});
  }


  Future<void> checkInstagramFollow() async {
    String? result = await _controller?.evaluateJavascript(source: '''
    (function() {
      const buttons = Array.from(document.querySelectorAll('button'));
      for (let btn of buttons) {
        const text = btn.innerText.trim();
        if (text === "Follow") {
          btn.click(); // auto click follow
          return "clicked_follow";
        }
        if (text === "Following") {
          return "already_following";
        }
      }
      return "not_found";
    })();
  ''');

    result = result?.replaceAll('"', '');
    debugPrint("Instagram follow status: $result");

    if (result == "already_following") {
      AlertMessage.snackMsg(context: context, message: "Following");
    }
  }


  Future<void> autoLikeInstagramPost() async {
    String? result = await _controller?.evaluateJavascript(source: '''
    (function() {
      const likeSvg = document.querySelector('svg[aria-label="Like"], svg[aria-label="Unlike"]');
      if (!likeSvg) return "not_found";

      const aria = likeSvg.getAttribute("aria-label");
      if (aria === "Like") {
        // Post not liked, click to like
        likeSvg.parentElement.click();
        return "liked_now";
      }
      if (aria === "Unlike") {
        // Already liked
        return "already_liked";
      }
      return "unknown";
    })();
  ''');

    result = result?.replaceAll('"', '');
    debugPrint("Instagram like result: $result");

    if (result == "liked_now" || result == "already_liked") {

      AlertMessage.snackMsg(context: context, message: "Liked");

    } else if (result == "not_found") {
      AlertMessage.snackMsg(
        context: context,
        message: "Like button not found. Please check the post.",
        time: 3,
      );
    }
  }

  Future<void> clickClosePopupButton(InAppWebViewController controller) async {
    if (_saveInfoClicked) return;
    _saveInfoClicked = true;

    await Future.delayed(const Duration(seconds: 5));
    try {
      String result = await controller.evaluateJavascript(source: """
      (function(){
        var closeBtn = document.querySelector('div[aria-label="Close"][role="button"]');
        if(closeBtn){
          closeBtn.click();
          return "Popup Close button clicked ✅";
        }
        return "Popup Close button not found ❌";
      })();
    """);

      debugPrint("JS Result: $result");
    } catch (e) {
      debugPrint("Error clicking Close button: $e");
    }
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textStyle = Theme.of(context).textTheme;
    return
      Stack(
        children: [
          WillPopScope(
            onWillPop: () async {
              if (_remainingTime <= 0) {
                _handleTaskCompletion(context);
                return true;
              } else {
                return await showDialog(context: context,
                  builder: (BuildContext context) {
                    return pop.backAlert(context:context, bodyTxt:'The task is not completed. You will not receive the task reward.');},
                ) ?? false;
              }
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF2c2c2c),
                automaticallyImplyLeading: false,
                title: Column(
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 0),
                      child: Row(children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xff505050),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lock, size: 15, color: Colors.white,),
                                const SizedBox(width: 5),
                                Text('instagram.com', maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Row(children: [
                          Image.asset('assets/ico/1xTickets.webp', width: 30,),
                          Text("${widget.reward}", style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 22,))
                        ],),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Icon(
                              widget.selectedOption == "Likes"
                                  ? Icons.favorite
                                  : widget.selectedOption == "Comments"
                                  ? Icons.comment
                                  : widget.selectedOption == "Followers"
                                  ? Icons.supervised_user_circle_outlined
                                  : Icons.supervised_user_circle_outlined,
                              size: 20,
                              color: widget.selectedOption == "Likes"
                                  ? Colors.pink
                                  : Colors.red,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.selectedOption == "Likes"
                                  ? 'Like'
                                  : widget.selectedOption == "Comments"
                                  ? 'Comment'
                                  : widget.selectedOption == "Followers"
                                  ? 'Follow'
                                  : 'Follow',
                              style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  if (progress < 1.0)
                    LinearProgressIndicator(value: progress, color: Colors.red, minHeight: 6),
                  Expanded(
                    child: Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri(taskUrl)),
                          initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              supportMultipleWindows: true,
                              userAgent: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.6478.120 Mobile Safari/537.36"
                          ),
                          onWebViewCreated: (controller) {
                            _controller = controller;
                          },
                          onLoadStart: (controller, url) {
                            setState(() {
                              _isLoading = true;
                            });
                          },
                          onProgressChanged: (controller, progressValue) {
                            setState(() {
                              progress = progressValue / 100;
                            });
                          },
                          onLoadStop: (controller, url) async {
                            _startTimer();
                            if (!_loginChecked) {
                              _checkLoginStatus();
                              setState(() {
                                _isLoading = false;
                                _loginChecked = true;
                              });
                            }
                            // ✅ Initialize timer only once
                            if (!_timerInitialized) {
                              debugPrint("✅ Starting timer once");
                              setState(() {
                                _remainingTime = watchTime;
                                _timerInitialized = true;
                              });
                            } else {
                              debugPrint("⏳ Timer already initialized. Skipping reset.");
                            }
                            await clickClosePopupButton(controller);
                          },
                        ),

                        if (_showOverlay && _remainingTime > 0)
                          InkWell(
                            onTap: ()=> AlertMessage.snackMsg(context: context, message: 'Please wait\nInstagram auto task is running...'),
                            child: Container(color: Colors.black.withOpacity(0.0)),
                          ),


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fullscreen loading overlay
          if (_buttonLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),

        ],
      );
  }
}
