import 'dart:convert';
import 'dart:async';
import 'package:app/config/config.dart';
import 'package:app/server_model/functions_helper.dart';
import 'package:app/server_model/page_load_fetchData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../server_model/provider/fetch_taskts.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../../ui/pop_alert.dart';

class TikTokTaskHandler {
  static bool _taskLaunched = false;
  static String? _lastTikTokUrl;
  static String? _selectedOption;
  static String? _campaignId;
  static int _reward = 0;
  static int _screenFrom = 1;
  static int? _initialTaskValue;

  static bool _isCancelled = false;

  // 🧠 Cancel function to stop verification if popup closed
  static void cancelCurrentProcess() {
    _isCancelled = true;
  }

  // ✅ Fetch data from backend
  static Future<int> fetchInitialTaskValue(String tiktokUrl, String taskType) async {
    try {
      final uri = Uri.parse(ApiPoints.tiktokTaskCheck);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"url": tiktokUrl}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        debugPrint("TikTok Data: ${response.body}");

        switch (taskType) {
          case 'Likes':
            return data['likes'] ?? 0;
          case 'Comments':
            return data['comments'] ?? 0;
          case 'Favorites':
            return int.tryParse(data['favorites']?.toString() ?? '0') ?? 0;
          case 'Followers':
            return int.tryParse(data['followers']?.toString() ?? '0') ?? 0;
          default:
            return 0;
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}, ${response.body}');
        return 0;
      }
    } catch (e) {
      debugPrint('Exception in fetchInitialTaskValue: $e');
      return 0;
    }
  }

  // ✅ Verify Task (2nd API)
  static Future<bool> verifyTaskWithBackend(
      String tiktokUrl, String taskType, int initialValue) async {
    try {
      final email = Helper.getFirebaseEmail();
      final uri = Uri.parse(ApiPoints.tiktokTaskVerify);

      final response = await http
          .post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "url": tiktokUrl,
          "taskType": taskType,
          "initialValue": initialValue,
          "campaignId": _campaignId,
          "userEmail": email,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['completed'] ?? false;
      } else {
        debugPrint('HTTP Error: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception in verifyTaskWithBackend: $e');
      return false;
    }
  }

  // ✅ Start TikTok task
  static Future<void> startTikTokTask({
    required BuildContext contextPop,
    required String tiktokUrl,
    required String taskType,
    required String campaignId,
    required int reward,
    required int screenFrom,
  }) async {
    _lastTikTokUrl = tiktokUrl;
    _campaignId = campaignId;
    _reward = reward;
    _selectedOption = taskType;
    _screenFrom = screenFrom;
    _isCancelled = false;


    final theme = Theme.of(contextPop).colorScheme;
    final textStyle = Theme.of(contextPop).textTheme;

    // 🔹 Show loading popup while fetching
    showDialog(
      context: contextPop,
      barrierDismissible: true,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          cancelCurrentProcess();
          AlertMessage.snackMsg(context: contextPop, message: "Task verification cancelled", time: 2);
          return true;
        },
        child: AlertDialog(
          backgroundColor: theme.secondaryContainer,
          content: SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(width: 30),
                Text('Task Checking...', style: textStyle.displaySmall?.copyWith(
                        fontSize: 18, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      _initialTaskValue = await fetchInitialTaskValue(tiktokUrl, taskType);

      if (_isCancelled) {
        if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);
        AlertMessage.snackMsg(context: contextPop, message: "Task verification cancelled", time: 2);
        debugPrint("⚠️ Task cancelled during initial fetch.");
        return;
      }

      if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);

      debugPrint("Task Value: $_initialTaskValue");

      await FlutterOverlayWindow.showOverlay(
        width: WindowSize.matchParent,
        height: 600,
        alignment: OverlayAlignment.topLeft,
        flag: OverlayFlag.defaultFlag,
        enableDrag: false,
        overlayTitle: "Return to Social Task",
        visibility: NotificationVisibility.visibilityPublic,
      );
      await FlutterOverlayWindow.shareData(taskType);

      final launched = await launchUrl(
        Uri.parse(tiktokUrl),
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        _taskLaunched = true;
      } else {
        AlertMessage.errorMsg(contextPop, "Failed", "Couldn't open TikTok video.");
      }
    } catch (e) {
      if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);
      AlertMessage.errorMsg(contextPop, "Error", "Failed to fetch initial task value.");
    }
  }

  // ✅ Handle resume lifecycle with cancellation safety
  static void handleLifecycle(AppLifecycleState state, BuildContext contextPop) async {
    if (state == AppLifecycleState.resumed && _taskLaunched) {
      _taskLaunched = false;
      _isCancelled = false;
      FlutterOverlayWindow.closeOverlay();

      final theme = Theme.of(contextPop).colorScheme;
      final textStyle = Theme.of(contextPop).textTheme;

      showDialog(
        context: contextPop,
        barrierDismissible: true,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            cancelCurrentProcess();
            AlertMessage.snackMsg(context: contextPop, message: "Task verification cancelled", time: 3);
            return true;
          },
          child: AlertDialog(
            backgroundColor: theme.secondaryContainer,
            content: SizedBox(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(width: 30),
                  Text('Verifying Task...',
                      style: textStyle.displaySmall?.copyWith(
                          fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final completed = await verifyTaskWithBackend(
          _lastTikTokUrl!,
          _selectedOption!,
          _initialTaskValue!,
        );

        if (_isCancelled) {
          if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);
          debugPrint("⚠️ Task verification cancelled by user.");
          return;
        }

        if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);

        if (completed) {
          AlertMessage.successMsg(contextPop, "Task Completed", "You earned +$_reward tickets!");
          FetchDataService.fetchData(contextPop, forceRefresh: true);
        } else {

          await showPopup(contextPop);

          // AlertMessage.errorMsg(contextPop, "Maybe your network issue,\nTikTok didn't added ${_selectedOption=="Likes"?"Like":_selectedOption=="Comments"?"Comment":_selectedOption=="Favorites"?"Favorite":"Follow"}",
          //   "You didn't ${_selectedOption=="Likes"?"Like":_selectedOption=="Comments"?"Comment":_selectedOption=="Favorites"?"Favorite":"Follow"} the ${_selectedOption=="Followers"?"Account":"Video"}\n",
          //   time: 8
          // );

        }

      } catch (e) {
        if (Navigator.canPop(contextPop)) Navigator.pop(contextPop);
        AlertMessage.errorMsg(contextPop, "Verifying Failed", "Something went wrong while verifying.");
      }
    }
  }


  static Future<void> showPopup(BuildContext contextPop) async{
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
        content: Text("\nYou didn't ${_selectedOption=="Likes"?"Like":_selectedOption=="Comments"?"Comment":_selectedOption=="Favorites"?"Favorite":"Follow"} the ${_selectedOption=="Followers"?"Account":"Video"}"
            "\n\nTikTok did not detect your ${_selectedOption=="Likes"?"Like":_selectedOption=="Comments"?"Comment":_selectedOption=="Favorites"?"Favorite":"Follow"}.\n"
            "Do you want to try again?\n", style: Theme.of(contextPop).textTheme.displaySmall?.copyWith(wordSpacing: 0.6, height: 1.3, fontSize: 15,color: Colors.white)),
        actions: [
        SizedBox(height: 36,
            child: TextButton(onPressed: (){
              final CampProvider = Provider.of<AllCampaignsProvider>(contextPop, listen: false);
              CampProvider.enterSelectionMode(_campaignId.toString());
              CampProvider.hideSelectedTasks("7 day");
              Navigator.pop(contextPop);
              AlertMessage.snackMsg(context: contextPop, message: "Task canceled and hidden");
            }, child: Text("Close & Hide", style: textStyle.displaySmall?.copyWith(color: Color(0xFFA6C4EA)),))),

          SizedBox(height: 38,
            child: MyButton(txt: "Try again", borderRadius: 40, pading: const EdgeInsets.only(left: 25, right: 25), shadowOn: true,
                bgColor: Colors.white70, borderLineOn: false, borderColor: Colors.black, txtSize: 15, txtColor: Colors.black,
                onClick: () async{
                  Navigator.pop(contextPop);

                  // Relaunch TikTok Again
                  await FlutterOverlayWindow.showOverlay(
                    width: WindowSize.matchParent,
                    height: 600,
                    alignment: OverlayAlignment.topLeft,
                    flag: OverlayFlag.defaultFlag,
                    enableDrag: false,
                    overlayTitle: "Return to Social Task",
                    visibility: NotificationVisibility.visibilityPublic,
                  );

                  await FlutterOverlayWindow.shareData(_selectedOption!);

                  await launchUrl(
                  Uri.parse(_lastTikTokUrl!),
                  mode: LaunchMode.externalApplication,
                  );
                  _taskLaunched = true;
                } ),
          ),
        ],
           ),
     );
  }


}
