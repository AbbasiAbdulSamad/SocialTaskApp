import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TiktokAppOverlay extends StatelessWidget {
  final String message;
  const TiktokAppOverlay({super.key, required this.message});

  Future<void> openSocialTaskApp() async {
    const packageName = 'com.socialtask.app';
    const componentName = 'com.socialtask.app.MainActivity';

    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
      componentName: componentName,
      flags: <int>[
        Flag.FLAG_ACTIVITY_NEW_TASK,
        Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
      ],
    );

    try {
      await intent.launch();
      FlutterOverlayWindow.closeOverlay();
      print('✅ Explicit intent launched');
    } catch (e) {
      print('❌ Error launching app: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin:const EdgeInsets.only(top: 165),
      decoration:const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent,Colors.transparent,Colors.black87, Colors.black87])
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: ()=> openSocialTaskApp(),
            child: Container(
              padding:const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration:const BoxDecoration(
                color: Color(0xff004664),
                borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25))
              ),
              child:const Row(spacing: 2,
                children: [
                  Icon(Icons.arrow_back_ios_sharp, color: Colors.white, size: 18,),
                  Text('Social Task', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: '3rdRoboto'),),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Text((message=="Likes"?"❤️ Like the video":(message=="Followers"?"👤 Follow the account":
            (message=="Comments"?"💬 Write a positive comment":(message=="Favorites"?"🔖 Favorite the video":"")))),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: '3rdRoboto'),
            ),
          ),
        ],
      ),
    );
  }
}
