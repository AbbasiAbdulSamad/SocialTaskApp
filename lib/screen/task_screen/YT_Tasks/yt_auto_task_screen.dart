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
import 'comment_list.dart';

class YT_Auto_Task_Screen extends StatefulWidget {
  final String taskUrl;
  final String selectedOption;
  final int watchTime;
  final int reward;
  final String campaignId;
  final int screenFrom;

  const YT_Auto_Task_Screen({Key? key, required this.taskUrl, required this.selectedOption, required this.watchTime,
    required this.reward, required this.campaignId, required this.screenFrom,}) : super(key: key);

  @override
  _YT_Auto_Task_ScreenState createState() => _YT_Auto_Task_ScreenState();
}

class _YT_Auto_Task_ScreenState extends State<YT_Auto_Task_Screen> {
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


  @override
  void initState() {
    taskUrl = widget.taskUrl;
    selectedOption = widget.selectedOption;
    watchTime = widget.watchTime;
    reward = widget.reward;
    campaignId = widget.campaignId;
    screenFrom = widget.screenFrom;

    _remainingTime = widget.watchTime;
    super.initState();
    Provider.of<InternetProvider>(context, listen: false).addListener(_handleInternetChange);
  }

  void _startTimer() {
    _timer?.cancel();

    final random = Random();
    int min = 5;
    int max = (watchTime - 6);
    if (max <= min) {max = min + 2;}
    int _actionTriggerTime = min + random.nextInt(max - min);
    debugPrint('Random: $_actionTriggerTime \n Time: $watchTime');

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

        if(_remainingTime == _actionTriggerTime && selectedOption == "Subscribers"){
          autoSubscribe();
        }else if(_remainingTime == _actionTriggerTime && selectedOption == "Likes"){
          autoLike();
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

    final youtubeTasks = allCampaignsProvider.allCampaigns
        .where((task) => task['social'] == 'YouTube' &&
        (task['selectedOption'] == 'Likes' || task['selectedOption'] == 'Subscribers'))
        .toList();

    // 🛠️ Skip current task if already playing
    if (_isFirstTask) {
      _isFirstTask = false;
      _currentIndex++;
    }

    if (_currentIndex >= youtubeTasks.length) {
      AlertMessage.snackMsg(context: context, message: 'All YouTube tasks completed!', time: 3);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => Home(onPage: widget.screenFrom)),
            (route) => false,
      );
      return;
    }

    final campaign = youtubeTasks[_currentIndex];

    setState(() {
      _currentIndex++;
      taskUrl = campaign['videoUrl'];
      selectedOption = campaign['selectedOption'];
      watchTime = campaign['watchTime'];
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
    setState(() {
      _showOverlay = false;
    });

    List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri("https://www.youtube.com"));
    bool isLoggedIn = cookies.any((cookie) =>
    cookie.name == "LOGIN_INFO" || cookie.name == "SAPISID" || cookie.name == "SSID");

    debugPrint("User is logged in: $isLoggedIn");

    if (!isLoggedIn) {
      debugPrint("🔴 User not logged in. Redirecting to YouTube Login...");
      if (_controller != null) {
        await _controller?.loadUrl(
          urlRequest: URLRequest(
            url: WebUri("https://accounts.google.com/ServiceLogin?service=youtube&continue=https://www.youtube.com"),
          ),
        );
        _remainingTime = 999;
        AlertMessage.snackMsg(context: context, message: 'Please log in YouTube account then complete the task.', time: 8);
      }
    } else {
      setState(() {
        _isUserLoggedIn = true;
        _showOverlay = true;
        _justLoggedIn = true;
      });

      if (!_loginChecked) {
        _loginChecked = true;
        if (_controller != null) {
          await _controller?.loadUrl(
            urlRequest: URLRequest(url: WebUri(taskUrl)),
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
      autoTask: true,
    );
    loadNextTask();
    setState(() {_buttonLoading = false;});
  }


  Future<void> autoLike() async{
    if (selectedOption == "Likes") {
      String? likeCheck = await _controller?.evaluateJavascript(source: '''
    (function() {
      const likeButton = document.querySelector('button[aria-label*="like this video"]');
      if (!likeButton) return "not_found";
      return likeButton.getAttribute("aria-pressed");
    })();
  ''');

      debugPrint("👍 Like button pressed status: $likeCheck");
      likeCheck = likeCheck?.replaceAll('"', '');

      if (likeCheck != "true") {
        // ✅ Automatically click the Like button
        await _controller?.evaluateJavascript(source: '''
      (function() {
        const likeButton = document.querySelector('button[aria-label*="like this video"]');
        if (likeButton) {
          likeButton.click();
          return "clicked";
        }
        return "button_not_found";
      })();
    ''');

        // Optional feedback
        AlertMessage.snackMsg(context: context, message: 'Liked');
        // Optional delay
      }
    }
  }


  Future<void> autoSubscribe() async {
    if (selectedOption == "Subscribers") {
      try {
        String? subscribeCheck = await _controller?.evaluateJavascript(source: '''
        (function() {
          function getText(el) {
            return el?.innerText?.trim()?.toLowerCase() || "";
          }

          // 🔎 Try to detect "Subscribe" or "Subscribed"
          let btns = Array.from(document.querySelectorAll('button, yt-button-shape, tp-yt-paper-button, span.yt-core-attributed-string'));
          let subscribeBtn = btns.find(b => getText(b) === "subscribe");
          let subscribedBtn = btns.find(b => getText(b) === "subscribed");

          if (subscribedBtn) return "subscribed";
          if (subscribeBtn) return "not_subscribed";

          return "not_found";
        })();
      ''');

        debugPrint("🔍 Subscribe button status: $subscribeCheck");
        subscribeCheck = subscribeCheck?.replaceAll('"', '');

        if (subscribeCheck == "not_subscribed") {
          // ✅ Auto-click the Subscribe button
          String? clickResult = await _controller?.evaluateJavascript(source: '''
          (function() {
            function getText(el) {
              return el?.innerText?.trim()?.toLowerCase() || "";
            }
            let btns = Array.from(document.querySelectorAll('button, yt-button-shape, tp-yt-paper-button, span.yt-core-attributed-string'));
            let subscribeBtn = btns.find(b => getText(b) === "subscribe");
            if (subscribeBtn) {
              subscribeBtn.click();
              return "clicked";
            }
            return "button_not_found";
          })();
        ''');
          debugPrint("▶️ Subscribe click result: $clickResult");

          if (clickResult?.contains("clicked") == true) {
            AlertMessage.snackMsg(context: context, message: 'Subscribed ✅');
          }
        }
      } catch (e) {
        debugPrint("❌ Error autoSubscribe: \$e");
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    internetProvider.removeListener(_handleInternetChange);
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
                                Text(
                                  'youtube.com',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        (_justLoggedIn==false)?SizedBox():

                        (_remainingTime>0)?Row(children: [
                          Icon(Icons.access_time_outlined),
                          const SizedBox(width: 1),
                          Text('$_remainingTime',
                            style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 24),),
                          const SizedBox(width: 2),
                          Text('sec', style: TextStyle(fontSize: 15)),
                        ],):SizedBox(),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            Icon(
                              selectedOption == "Likes"
                                  ? Icons.thumb_up
                                  : selectedOption == "WatchTime"
                                  ? Icons.ondemand_video_outlined
                                  : Icons.subscriptions_rounded,
                              size: 18,
                              color: selectedOption == "Likes"
                                  ? Colors.blueAccent
                                  : selectedOption == "WatchTime"
                                  ? Colors.red
                                  : Colors.red,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              selectedOption == "Likes"
                                  ? 'Like'
                                  : selectedOption == "WatchTime"
                                  ? 'Watch Video'
                                  : 'Subscribe',
                              style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 16),
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

                            // ✅ Detect login page
                            String? currentUrl = url?.toString().trim();
                            bool isLoginPage = currentUrl != null &&
                                (currentUrl.contains("accounts.google.com") ||
                                    currentUrl.contains("accounts.youtube.com/accounts/"));
                            if (isLoginPage) {
                              debugPrint("🔴 Login page detected");
                              setState(() {
                                _remainingTime = 999;
                              });
                              return;
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

                            // ✅ Handle YouTube homepage auto-close
                            bool isHomePage = currentUrl == "https://www.youtube.com" ||
                                currentUrl == "https://m.youtube.com" ||
                                currentUrl == "https://.youtube.com/" ||
                                currentUrl == "https://m.youtube.com/";
                            if (isHomePage) {
                              setState(() {
                                _loginChecked = false;
                                _isUserLoggedIn = true;
                                _showOverlay = true;
                                _remainingTime = watchTime;
                              });
                              await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(taskUrl)),);
                              _startTimer();
                              AlertMessage.snackMsg(context: context, message: 'Login to YouTube successfully.', time: 2);
                            }
                          },
                        ),

                        if (_showOverlay && _remainingTime > 0)
                          InkWell(
                            onTap: ()=> AlertMessage.snackMsg(context: context, message: 'Please Wait\nYouTube Auto Task is running...\nReward ${reward} tickets.'),
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
