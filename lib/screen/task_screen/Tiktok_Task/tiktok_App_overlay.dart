import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class TiktokAppOverlay extends StatelessWidget {
  const TiktokAppOverlay({super.key});

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
      margin: EdgeInsets.only(top: 140),
      color: Colors.redAccent,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Please Like ️',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          ElevatedButton(
            onPressed: () => FlutterOverlayWindow.closeOverlay(),
            child: const Text("Close"),
          ),

          ElevatedButton(onPressed: ()=> openSocialTaskApp(), child: Text("Back App"))
        ],
      ),
    );
  }
}
