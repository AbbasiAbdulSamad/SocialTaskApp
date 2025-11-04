import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../server_model/internet_provider.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../../ui/pop_alert.dart';
import '../../home.dart';

class TikTokTaskHandler {
  static DateTime? _taskStartTime;
  static bool _taskLaunched = false;
  static String? _lastTikTokUrl;
  static int _requiredSeconds = 5;
  static String? _selectedOption;


  static String? _campaignId;
  static int _reward = 0;
  static int _screenFrom = 1;

  static void handleLifecycle(AppLifecycleState state, BuildContext context) async {
    ColorScheme theme = Theme.of(context).colorScheme;

    if (state == AppLifecycleState.resumed && _taskLaunched) {
      _taskLaunched = false;
      final elapsed = DateTime.now().difference(_taskStartTime!);

      // User returned early: show 3s fixed loading
      if (elapsed.inSeconds < _requiredSeconds) {
        FlutterOverlayWindow.closeOverlay();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            content: SizedBox(
              height: 50,
              child: Center(
                child: Row(
                  children: [
                    CircularProgressIndicator(color: Colors.black, strokeAlign: 0.2),
                    SizedBox(width: 20),
                    Text('Verifying Task...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pop(); // Close loading dialog
        _showEarlyReturnDialog(context);
      }
      // User waited long enough: show live API loading
      else {
        FlutterOverlayWindow.closeOverlay();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: SizedBox(
              height: 50,
              child: Center(
                child: Row(
                  children: [
                    CircularProgressIndicator(color: theme.onPrimaryContainer, strokeAlign: 0.2),
                    SizedBox(width: 20),
                    Text('Completing Task...', style: TextStyle(color: theme.onPrimaryContainer, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        );

        await completeTask(context);
      }
    }
  }

  static Future<void> startTikTokTask({
    required BuildContext context,
    required String tiktokUrl,
    required String taskType,
    required String campaignId,
    required int reward,
    required int screenFrom,
  }) async {
    _lastTikTokUrl = tiktokUrl;
    _campaignId = campaignId;
    _reward = reward;
    _requiredSeconds = _getWaitTimeForTask(taskType);
    _selectedOption = taskType;
    _screenFrom = screenFrom;

    // ✅ Direct launch TikTok link (no alert)
    final launched = await launchUrl(
      Uri.parse(tiktokUrl),
      mode: LaunchMode.externalApplication,
    );

    if (launched) {
      _taskLaunched = true;
      _taskStartTime = DateTime.now();
    } else {
      AlertMessage.errorMsg(context, "Failed", "Couldn't open TikTok video.");
    }
  }


  static int _getWaitTimeForTask(String taskType) {
    switch (taskType) {
      case 'Comments':
        return 10;
      default:
        return 5;
    }
  }

  static void _showEarlyReturnDialog(BuildContext context) {
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    if (internetProvider.isConnected) {
      showDialog(context: context,
        builder: (BuildContext context) {
          // pop class import from pop_box.dart
          return pop.backAlert(context: context,icon: Icons.close, title: 'Task Not Completed',
              bodyTxt:'You didn\'t $_selectedOption the video. Please like it before returning.',
              confirm: 'Continue Task', onConfirm: () async{
                                  Navigator.of(context).pop();
                                  final launched = await launchUrl(
                                    Uri.parse(_lastTikTokUrl!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (launched) {
                                    _taskLaunched = true;
                                    _taskStartTime = DateTime.now();
                                  }

                                  // Re Open Overlay continue task
                                  await FlutterOverlayWindow.showOverlay(
                                    width: WindowSize.matchParent,
                                    height: 600,
                                    alignment: OverlayAlignment.topLeft,
                                    flag: OverlayFlag.defaultFlag,
                                    enableDrag: false,
                                    overlayTitle: "Social Task",
                                    visibility: NotificationVisibility.visibilityPublic,
                                  );
                                  await FlutterOverlayWindow.shareData(_selectedOption);
          } );
        },
      );
      }
  }

  static Future<void> completeTask(BuildContext context) async {
    if (_campaignId == null || _reward == 0) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    try {
      await taskProvider.completeTaskAuto(
        context: context,
        campaignId: _campaignId!,
        rewardCoins: _reward,
      );

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Home(onPage: _screenFrom)), (route) => false,);
    } catch (e) {
      Navigator.of(context).pop(); // Close dialog on error
      AlertMessage.errorMsg(context, "Task Failed", "Something went wrong.");
    }
  }
}
