import 'dart:math';

import 'package:app/screen/home.dart';
import 'package:app/ui/flash_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../server_model/functions_helper.dart';

class SocialLogins extends StatefulWidget {
  final String? loginSocial;

  const SocialLogins({super.key, required this.loginSocial,});
  @override
  State<SocialLogins> createState() => _SocialLoginsState();
}
class _SocialLoginsState extends State<SocialLogins> {
  late InAppWebViewController _controller;
  double progress = 0;
  String? loginLink;

  @override
  void initState() {
    super.initState();
    socialLogin();
  }
  void socialLogin(){
    if(widget.loginSocial=="YouTube"){
      loginLink = "https://accounts.google.com/ServiceLogin?service=youtube&continue=https://www.youtube.com";
    } else{
      loginLink = "https://www.instagram.com/accounts/login/";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            if (progress < 1.0)
              LinearProgressIndicator(value: progress, color: Colors.red, minHeight: 6),
      
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(loginLink!)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportMultipleWindows: true,
                  useHybridComposition: true,
                  userAgent: "Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/UP1A.240930.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/130.0.6560.90 Mobile Safari/537.36",
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                },
                onProgressChanged: (controller, progressValue) async{
                  setState(() {
                    progress = progressValue / 100;
                  });
      
                  String? currentUrl = (await controller.getUrl())?.toString();
                  if (currentUrl!.contains("youtube.com")) {
                  AlertMessage.snackMsg(context: context, message: "Please wait for youtube login checking...", time: 2);
                  } else if (currentUrl.contains("instagram.com")) {
                    AlertMessage.snackMsg(context: context, message: "Please wait for instagram login checking...", time: 2);
                  }
                },
                onLoadStop: (controller, url) async {
                  if (url == null) return;
                  final host = url.host.toLowerCase();
      
                  // --------------------
                  // YOUTUBE LOGIN CHECK
                  // --------------------
                  if (host.contains("youtube.com")) {
      
                    List<Cookie> cookies = await CookieManager.instance().getCookies(url: WebUri("https://www.youtube.com"));
                    bool loggedIn = cookies.any((c) => c.name == "LOGIN_INFO");
      
                    if (loggedIn) {
                      debugPrint("✅ YouTube login detected & saved");
      
                      AlertMessage.snackMsg(context: context, message: "YouTube Account Login Successfully!");
                      Helper.navigateAndRemove(context, const Home(onPage: 1));
      
                    } else {
                      Future.delayed(Duration(seconds: 3), () {
                        AlertMessage.snackMsg(context: context, message: "Login YouTube Account", time: 5);
                      });
      
                    }
                  }
      
                  // --------------------
                  // INSTAGRAM LOGIN CHECK
                  // --------------------
                  if (host.contains("instagram.com")) {
                    List<Cookie> cookies = await CookieManager.instance()
                        .getCookies(url: WebUri("https://www.instagram.com"));
      
                    // Instagram login cookie is usually `sessionid`
                    bool instaLoggedIn = cookies.any((c) => c.name == "sessionid");
      
                    // Facebook login cookie is `c_user`
                    bool fbLoggedIn = cookies.any((c) => c.name == "c_user");
      
                    if (instaLoggedIn || fbLoggedIn) {
                      debugPrint("✅ Instagram/Facebook login detected & saved");
      
                      AlertMessage.snackMsg(context: context, message: "Instagram Account Login Successfully!");
                      Helper.navigateAndRemove(context, const Home(onPage: 1));
                    } else {
                      Future.delayed(Duration(seconds: 3), () {
                        AlertMessage.snackMsg(context: context, message: "Login Instagram Account", time: 5);
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
