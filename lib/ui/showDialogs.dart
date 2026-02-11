import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'button.dart';
class ShowDialogs {

  static Future<dynamic> taskNotComplete({required BuildContext contextPop, required String body,
    required String onContinueText, required String closeText,
    required VoidCallback onContinue, required VoidCallback close,
  }) async {
    final theme = Theme.of(contextPop).colorScheme;
    final textStyle = Theme.of(contextPop).textTheme;

    return showDialog(
      context: contextPop,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: theme.secondaryFixed,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white54, width: 0.5),
          borderRadius: BorderRadius.circular(7),),
        title: Row(spacing: 5,
          children: [
            Icon(Icons.task_alt, size: 28, color: Colors.orangeAccent),
            Text("Task Not Completed",
              style: Theme.of(contextPop).textTheme.displaySmall?.copyWith(fontSize: 20, color: Colors.orange),),
          ],
        ),
        content: Text(body, style: Theme.of(contextPop).textTheme.displaySmall?.copyWith(wordSpacing: 0.6, height: 1.3, fontSize: 15,color: Colors.white)),
        actions: [
          SizedBox(height: 36,
              child: TextButton(onPressed: close,
                  child: Text(closeText, style: textStyle.displaySmall?.copyWith(color: Color(0xFFA6C4EA)),))),

          SizedBox(height: 38,
            child: MyButton(txt: onContinueText, borderRadius: 40, pading: const EdgeInsets.only(left: 25, right: 25), shadowOn: true,
                bgColor: Colors.white70, borderLineOn: false, borderColor: Colors.black, txtSize: 15, txtColor: Colors.black,
                onClick: onContinue),
          ),
        ],
      ),
    );
}

}