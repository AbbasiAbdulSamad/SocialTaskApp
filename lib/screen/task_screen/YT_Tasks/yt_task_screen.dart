import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../../server_model/internet_provider.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../../ui/pop_alert.dart';
import 'comment_list.dart';

class YT_Task_Screen extends StatefulWidget {
  final String taskUrl;
  final String selectedOption;
  final int watchTime;
  final int reward;
  final String campaignId;
  final int screenFrom;

  const YT_Task_Screen({Key? key, required this.taskUrl, required this.selectedOption, required this.watchTime,
    required this.reward, required this.campaignId, required this.screenFrom}) : super(key: key);

  @override
  _YT_Task_ScreenState createState() => _YT_Task_ScreenState();
}

class _YT_Task_ScreenState extends State<YT_Task_Screen> {
  late InAppWebViewController _controller;
  bool _isLoading = true;
  final CookieManager _cookieManager = CookieManager();
  late int _remainingTime;
  bool _showReturnButton = false;
  bool _isUserLoggedIn = false;
  bool _loginChecked = false;
  bool _showOverlay = true;
  bool _justLoggedIn = false;
  Timer? _timer;
  bool _isPaused = false;
  bool _buttonLoading = false;
  String? _lastBaseUrl;
  bool _timerInitialized = false;
  bool _hasUserCommented = false;


  @override
  void initState() {
    _remainingTime = widget.watchTime;
    super.initState();
    _startTimer();
    Provider.of<InternetProvider>(context, listen: false).addListener(_handleInternetChange);
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final internetProvider = Provider.of<InternetProvider>(context, listen: false);
      if (!internetProvider.isConnected) {
        setState(() {
          _isPaused = true; // Timer pause ho jaye
        });
        timer.cancel();
        return;
      }

      if (_remainingTime > 0) {
        setState(() {_remainingTime--;});

        if (_remainingTime == 3 && widget.selectedOption == "Comments") {
          AlertMessage.flashMsg(context, "Write a positive comment.", "Comment on the video", Icons.comment, 8);
      _startListeningForCommentBox();
        }


      } else {
        timer.cancel();
        setState(() {_showReturnButton = true;});
      }
    });
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
      _showReturnButton = false;
    });

    List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri("https://www.youtube.com"));
    bool isLoggedIn = cookies.any((cookie) =>
    cookie.name == "LOGIN_INFO" || cookie.name == "SAPISID" || cookie.name == "SSID");

    debugPrint("User is logged in: $isLoggedIn");

    if (!isLoggedIn) {
      debugPrint("🔴 User not logged in. Redirecting to YouTube Login...");
      if (_controller != null) {
        await _controller.loadUrl(
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
        _showReturnButton = _remainingTime == 0;
        _justLoggedIn = true;
      });

      if (!_loginChecked) {
        _loginChecked = true;
        if (_controller != null) {
          await _controller.loadUrl(
            urlRequest: URLRequest(url: WebUri(widget.taskUrl)),
          );
        }
      }
    }
  }

  void _taskChecking(BuildContext context) async {
    setState(() {_buttonLoading = true;});
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    // 🔌 Check internet
    if (!internetProvider.isConnected) {AlertMessage.snackMsg(context: context,
        message: 'No internet connection. Please connect to the network.', time: 3);
    setState(() {_buttonLoading = false;});
    return;}
    if(widget.selectedOption=="Subscribers"){
      await checkSubscribe();
    }else if(widget.selectedOption=="Likes"){
      await checkLike();
    }else{
      taskDone();
    }
    setState(() {_buttonLoading = false;});
  }

  void taskDone() async{
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.completeTask(
      context: context,
      campaignId: widget.campaignId,
      rewardCoins: widget.reward,
      onPage: widget.screenFrom,
    );
  }


  Future<void> checkLike() async {
    if (widget.selectedOption == "Likes") {
      await Future.delayed(Duration(seconds: 1)); // Let the video load

      String? likeCheck = await _controller.evaluateJavascript(source: '''
      (function() {
        const isShort = window.location.pathname.includes("/shorts/");
        if (isShort) return "short_video";

        const buttons = Array.from(document.querySelectorAll('button[aria-pressed]'));
        const likeBtn = buttons.find(btn =>
          btn.getAttribute('aria-label')?.toLowerCase().includes('like this video')
        );

        if (!likeBtn) return "not_found";

        const isLiked = likeBtn.getAttribute('aria-pressed');
        return isLiked === "true" ? "liked" : "not_liked";
      })();
    ''');

      likeCheck = likeCheck?.replaceAll('"', '');
      debugPrint("👍 Like check result: $likeCheck");

      if (likeCheck == "liked") {
        taskDone();
      } else if (likeCheck == "not_liked") {
        AlertMessage.snackMsg(
          context: context,
          message: 'Please like the video to complete this task.',
          time: 3,
        );
      } else if (likeCheck == "short_video") {
        debugPrint("🎬 This is a YouTube Short — skipping like check.");
        taskDone();
      } else {
        AlertMessage.snackMsg(
          context: context,
          message: 'Like button not found.',
          time: 3,
        );
      }
    }
  }



  Future<void> checkSubscribe() async {
    if (widget.selectedOption == "Subscribers") {
      await Future.delayed(Duration(seconds: 1)); // allow video to load

      String? subscribeCheck = await _controller.evaluateJavascript(source: '''
      (function() {
        const isShort = window.location.pathname.includes("/shorts/");
        if (isShort) return "short_video";

        const spans = Array.from(document.querySelectorAll('span.yt-core-attributed-string'));
        let foundSubscribe = false;
        let foundSubscribed = false;

        for (let span of spans) {
          const text = span.innerText.trim().toLowerCase();
          if (text === "subscribe") foundSubscribe = true;
          if (text === "subscribed") foundSubscribed = true;
        }

        if (foundSubscribed) return "subscribed";
        if (foundSubscribe) return "not_subscribed";

        const btns = Array.from(document.querySelectorAll('button'));
        const shortsBtn = btns.find(btn => btn.innerText.trim().toLowerCase() === "subscribe");
        if (shortsBtn) return "not_subscribed";

        const shortsSubscribed = btns.find(btn => btn.innerText.trim().toLowerCase() === "subscribed");
        if (shortsSubscribed) return "subscribed";

        return "not_found";
      })();
    ''');

      subscribeCheck = subscribeCheck?.replaceAll('"', '');
      debugPrint("🔍 Subscribe button status: $subscribeCheck");

      if (subscribeCheck == "subscribed") {
        taskDone();
      } else if (subscribeCheck == "not_subscribed") {
        AlertMessage.snackMsg(
          context: context,
          message: 'Please subscribe to complete this task.',
          time: 3,
        );
      } else if (subscribeCheck == "short_video") {
        debugPrint("⏭️ Skipping subscribe check (YouTube Short)");
        taskDone();
      } else {
        AlertMessage.snackMsg(
          context: context,
          message: 'Subscribe button not found.',
          time: 3,
        );
      }
    }
  }


  void _startListeningForCommentBox() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_hasUserCommented) {
        timer.cancel();
        return;
      }

      String? result = await _controller.evaluateJavascript(source: '''
      (function() {
        const textarea = document.querySelector('textarea.comment-simplebox-reply');
        if (textarea && document.activeElement === textarea) {
          return "user_started_typing";
        }
        return "not_yet";
      })();
    ''');

      if (result != null && result.contains("user_started_typing")) {
        setState(() {
          _hasUserCommented = true;
          _showReturnButton = true;
        });
        timer.cancel();
      }
    });
  }



  @override
  void dispose() {
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
                _taskChecking(context);
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
                              widget.selectedOption == "Likes"
                                  ? Icons.thumb_up
                                  : widget.selectedOption == "WatchTime"
                                  ? Icons.ondemand_video_outlined
                                  : widget.selectedOption == "Comments"
                                  ? Icons.comment
                                  : Icons.subscriptions_rounded,
                              size: 18,
                              color: widget.selectedOption == "Likes"
                                  ? Colors.blueAccent
                                  : widget.selectedOption == "WatchTime"
                                  ? Colors.red
                                  : widget.selectedOption == "Comments"
                                  ? Colors.white
                                  : Colors.red,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.selectedOption == "Likes"
                                  ? 'Like'
                                  : widget.selectedOption == "WatchTime"
                                  ? 'Watch Video'
                                  : widget.selectedOption == "Comments"
                                  ? 'Comment'
                                  : 'Subscribe',
                              style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                      ),
                    ),
                    if (_isLoading)
                      LinearProgressIndicator(
                        backgroundColor: Color(0xFF2c2c2c),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri(widget.taskUrl)),
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
                          onLoadStop: (controller, url) async {
                            if (!_loginChecked) {
                              _checkLoginStatus();
                              setState(() {
                                _isLoading = false;
                                _loginChecked = true;
                              });
                            }
                            controller.evaluateJavascript(source: "navigator.userAgent").then((value) {
                              print("User Agent: $value");
                            });

                            // ✅ Detect login page
                            String? currentUrl = url?.toString().trim();
                            bool isLoginPage = currentUrl != null &&
                                (currentUrl.contains("accounts.google.com") ||
                                    currentUrl.contains("accounts.youtube.com/accounts/"));
                            if (isLoginPage) {
                              debugPrint("🔴 Login page detected");
                              setState(() {
                                _remainingTime = 999;
                                _showReturnButton = false;
                              });
                              return;
                            }

                            // ✅ Initialize timer only once
                            if (!_timerInitialized) {
                              debugPrint("✅ Starting timer once");
                              setState(() {
                                _remainingTime = widget.watchTime;
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
                                _remainingTime = widget.watchTime;
                              });
                              await _controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.taskUrl)),);
                              _startTimer();
                              AlertMessage.snackMsg(context: context, message: 'Login to YouTube successfully.', time: 2);
                            }
                          },
                        ),
                        if (_showOverlay && _remainingTime > 0)
                          InkWell(
                            onTap: ()=> AlertMessage.snackMsg(context: context, message: 'Wait for the time to collect ${widget.reward} tickets and complete the task.'),
                            child: Container(color: Colors.black.withOpacity(0.0)),
                          ),


                      ],
                    ),
                  ),

                  if (_showReturnButton && (widget.selectedOption != "Comments" || _hasUserCommented))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      color: theme.background,
                      child: Column(
                        children: [
                          SizedBox(height: 30, width: 180,
                            child: MyButton(txt: 'Complete Task', ico: Icons.check_circle_rounded, txtSize: 15, icoSize: 17, borderLineOn: true, borderRadius: 8, bgColor: theme.onPrimary,
                              onClick:(){
                                _taskChecking(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 12,),
                          Text('Please complete this task and collect ${widget.reward} Tickets', style: textStyle.displaySmall?.
                          copyWith(fontSize: 15, color: theme.onPrimaryContainer),),
                          const SizedBox(height: 12,),
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
