import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../../server_model/internet_provider.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../../ui/pop_alert.dart';
import 'insta_comment_list.dart';

class Instagram_Task_Screen extends StatefulWidget {
  final String taskUrl;
  final String selectedOption;
  final int reward;
  final String campaignId;
  final int screenFrom;

  const Instagram_Task_Screen({Key? key, required this.taskUrl, required this.selectedOption,
    required this.reward, required this.campaignId, required this.screenFrom}) : super(key: key);

  @override
  _Instagram_Task_ScreenState createState() => _Instagram_Task_ScreenState();
}

class _Instagram_Task_ScreenState extends State<Instagram_Task_Screen> {
  late InAppWebViewController _controller;
  bool _isLoading = true;
  final CookieManager _cookieManager = CookieManager();
  bool _showReturnButton = false;
  bool _isUserLoggedIn = false;
  bool _loginChecked = false;
  bool _justLoggedIn = false;
  bool _buttonLoading = false;
  bool _timerInitialized = false;
  bool _hasUserCommented = false;
  bool _hasLiked =  false;


  @override
  void initState() {
    super.initState();
    Provider.of<InternetProvider>(context, listen: false).addListener(_handleInternetChange);
  }

  void taskListening(){

    if(widget.selectedOption=="Comments"){
      _startListeningForInstagramCommentBox();

    }else{
      Future.delayed(Duration(seconds: 3), () {
        setState(() {_showReturnButton = true;});
      });
    }
  }

  void _handleInternetChange() {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    if (internetProvider.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internet Reconnected', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF007306),
          duration: Duration(seconds: 3),),);
    } else {
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
    setState(() {_showReturnButton = false;});

    List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri("https://www.instagram.com"),);

    // Instagram direct login cookies
    bool isInstagramLoggedIn = cookies.any((cookie) =>
    cookie.name.toLowerCase() == "sessionid" || cookie.name.toLowerCase() == "ds_user_id");

    // Facebook via Instagram login cookies
    bool isFacebookLoggedIn = cookies.any((cookie) => cookie.name.toLowerCase() == "csrftoken" ||
        cookie.name.toLowerCase() == "mid");

    bool isLoggedIn = isInstagramLoggedIn || isFacebookLoggedIn;
    debugPrint("User is logged in: $isLoggedIn");

    if (!isLoggedIn) {
      debugPrint("🔴 User not logged in. Redirecting to Instagram Login...");
      if (_controller != null) {
        await _controller.loadUrl(
          urlRequest: URLRequest(
            url: WebUri("https://www.instagram.com/accounts/login/"),
          ),);

        AlertMessage.snackMsg(context: context,
          message: 'Please log in to your Instagram or Facebook account to continue.', time: 10,);
      }
    } else {
      setState(() {
        _isUserLoggedIn = true;
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
    if (!internetProvider.isConnected) {
      AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
    setState(() {_buttonLoading = false;});
    return;}

    if(widget.selectedOption=="Likes"){
      checkInstagramLikeAndCompleteTask();
    }else if(widget.selectedOption=="Followers"){
      checkInstagramFollow();
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


  Future<void> checkInstagramFollow() async {
    String? result = await _controller.evaluateJavascript(source: '''
    (function() {
      const buttons = Array.from(document.querySelectorAll('button'));
      for (let btn of buttons) {
        const text = btn.innerText.trim();
        if(text === "Follow") return "not_followed";
        if(text === "Following") return "followed";
      }
      return "not_found";
    })();
  ''');

    result = result?.replaceAll('"', '');
    debugPrint("Instagram follow status: $result");

    if(result == "followed") {
        taskDone();
    } else if(result == "not_followed") {
      AlertMessage.snackMsg(
        context: context,
        message: "Please follow this account to complete the task.",
        time: 3,
      );
    } else {
      AlertMessage.snackMsg(
        context: context,
        message: "Follow button not found. Please check the account.",
        time: 3,
      );
    }
  }




  Future<void> checkInstagramLikeAndCompleteTask() async {
    String? result = await _controller.evaluateJavascript(source: '''
    (function() {
      const likeSvg = document.querySelector('svg[aria-label="Like"], svg[aria-label="Unlike"]');
      if(!likeSvg) return "not_found";

      const aria = likeSvg.getAttribute("aria-label");
      if(aria === "Like") return "not_liked";
      if(aria === "Unlike") return "liked";
      return "unknown";
    })();
  ''');

    result = result?.replaceAll('"', '');
    debugPrint("Instagram like status: $result");

    if(result == "liked") {
      setState(() {_hasLiked = true;});
      taskDone();
    } else if(result == "not_liked") {
      AlertMessage.flashMsg(context, "Please like this post to complete the task.", "Like", Icons.favorite, 3);
    } else {
      debugPrint("Like button not found or unknown status");
      AlertMessage.snackMsg(context: context, message: "Like button not found. Please check the post.",
        time: 3,);
    }
  }

  void _startListeningForInstagramCommentBox() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (_hasUserCommented) {
        timer.cancel();
        return;
      }

      String? result = await _controller.evaluateJavascript(source: '''
      (function() {
        // Instagram comment box selectors
        const textarea = document.querySelector('textarea[aria-label="Add a comment…"]') 
                      || document.querySelector('textarea[placeholder="Add a comment…"]') 
                      || document.querySelector('div[contenteditable="true"]');

        if (textarea && document.activeElement === textarea) {
          return "user_started_typing";
        }
        return "not_yet";
      })();
    ''');

      if (result != null && result.contains("user_started_typing")) {
        // Random comment select karo
        final comments = InstaComment();
        final randomComment = comments.instagramComments[
        DateTime.now().millisecondsSinceEpoch % comments.instagramComments.length];

        // Comment fill karna input me
        await _controller.evaluateJavascript(source: '''
        (function() {
          const textarea = document.querySelector('textarea[aria-label="Add a comment…"]') 
                        || document.querySelector('textarea[placeholder="Add a comment…"]') 
                        || document.querySelector('div[contenteditable="true"]');
          if (textarea) {
            textarea.focus();
            textarea.value = "$randomComment";
            const event = new Event('input', { bubbles: true });
            textarea.dispatchEvent(event);
          }
        })();
      ''');

        // 10 second after state update complete task
        Future.delayed(Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _hasUserCommented = true;
              _showReturnButton = true;
            });
          }
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
                return await showDialog(context: context,
                  builder: (BuildContext context) {
                    return pop.backAlert(context:context, bodyTxt:'The task is not completed. You will not receive the task reward.');},
                ) ?? false;
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
                        (_justLoggedIn==false)?SizedBox():
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
                                  : 'Follow',
                              style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 18),
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
                            if (!_loginChecked) {_checkLoginStatus();
                              setState(() {_isLoading = false;_loginChecked = true;});}
                            taskListening();


                          },
                        ),

                      ],
                    ),
                  ),

                  if (_showReturnButton)
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
