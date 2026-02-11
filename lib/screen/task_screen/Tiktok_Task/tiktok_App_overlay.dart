import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:app/server_model/overlay_timer_provider.dart'; // your Provider file

class AppOverlay extends StatelessWidget {
  final ValueNotifier<String> messageNotifier;

  const AppOverlay({super.key, required this.messageNotifier});

  /// Open Social Task App
  Future<void> openSocialTaskApp() async {
    const packageName = 'com.socialtask.app';
    const componentName = 'com.socialtask.app.MainActivity';

    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
      componentName: componentName,
      flags: const [
        Flag.FLAG_ACTIVITY_NEW_TASK,
        Flag.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED,
      ],
    );

    try {
      await intent.launch();
      FlutterOverlayWindow.closeOverlay();
    } catch (e) {
      debugPrint('❌ Error launching app: $e');
    }
  }

  /// Map message to readable task text
  String _taskText(String msg) {
    switch (msg) {
      case "Web":
        return "";
      case "Likes":
        return "❤️ Like the video";
      case "Followers":
        return "👤 Follow the account";
      case "Comments":
        return "💬 Write a positive comment";
      case "Favorites":
        return "🔖 Favorite the video";
      default:
        return msg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TaskTimerProvider>();

    return Container(
      margin: const EdgeInsets.only(top: 165),
      decoration: BoxDecoration(
       gradient: (messageNotifier.value == "Web")?
       LinearGradient(colors: [Colors.transparent, Colors.transparent]):
       LinearGradient(colors: [Colors.transparent,Colors.transparent,Colors.black87, Colors.black87])
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 🔹 "Social Task" button — only show if timer is 0

          if(messageNotifier.value == "Web")
            if(timerProvider.secondsLeft > 0)
          Stack(
            children: [
              SizedBox(width: 150, height: 100,),
                Container(
                  margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    color: Colors.black,
                    child: Image.asset('assets/animations/OverlayScrollDown.gif', width: 80,)),

                Positioned(left: 80, right: 0, top: 0,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white12, width: 1.0),
                    ),
                    child: Consumer<TaskTimerProvider>(
                      builder: (_, timerProvider, __) {
                        return Text(
                          " ${timerProvider.secondsLeft}s", textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: '3rdRoboto',),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),

          (timerProvider.secondsLeft == 0)?
            InkWell(
              onTap: openSocialTaskApp,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: const BoxDecoration(
                  color: Color(0xff004664),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_sharp, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text('Social Task', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: '3rdRoboto'),),
                  ],
                ),
              ),
            ):SizedBox(),

          // 🔹 MESSAGE + TIMER display
          if(messageNotifier.value != "Web")
            Expanded(child: SizedBox()),
         ValueListenableBuilder<String>(
           valueListenable: messageNotifier,
           builder: (_, msg, __) {
             return Text("${_taskText(msg)}  ",
               style: const TextStyle(
                 color: Colors.white,
                 fontSize: 16,
                 fontFamily: '3rdRoboto',
               ),
             );
           },
         ),

        ],
      ),
    );
  }
}
