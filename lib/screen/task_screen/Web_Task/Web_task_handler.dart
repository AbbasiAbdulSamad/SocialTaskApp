import 'dart:async';
import 'package:app/ui/showDialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../server_model/overlay_timer_provider.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../ui/flash_message.dart';

class WebsiteTaskHandler {
  static bool _taskLaunched = false;
  static bool _completionInProgress = false;

  static int _reward = 0;
  static int _screenFrom = 1;
  static int _seconds = 1;
  static String? _url;
  static String? _campaignId;

  static BuildContext? _loadingDialogContext;

  /* ---------------- START TASK ---------------- */
  static Future<void> startWebsiteTask({
    required BuildContext context,
    required String url,
    required int reward,
    required int screenFrom,
    required int seconds,
    required String campaignId,
  }) async {
    _reward = reward;
    _screenFrom = screenFrom;
    _seconds = seconds;
    _url = url;
    _campaignId = campaignId;

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      AlertMessage.errorMsg(context, "Failed", "Could not open link");
      return;
    }
    _taskLaunched = true;
   await Future.delayed(Duration(milliseconds: 1500));

    final timerProvider =
    Provider.of<TaskTimerProvider>(context, listen: false);
    timerProvider.start(seconds);
    await FlutterOverlayWindow.showOverlay(
      width: WindowSize.matchParent,
      height: 600,
      alignment: OverlayAlignment.topLeft,
      flag: OverlayFlag.defaultFlag,
      enableDrag: false,
      overlayTitle: "Return to Task",
      visibility: NotificationVisibility.visibilityPublic,
    );

    await FlutterOverlayWindow.shareData({
      "message": "Web",
      "seconds": seconds,
    });
  }

  /* ---------------- APP LIFECYCLE ---------------- */
  static Future<void> handleLifecycle(AppLifecycleState state, BuildContext context) async {
    final theme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    if (!_taskLaunched) return;

    final timerProvider =
    Provider.of<TaskTimerProvider>(context, listen: false);

    /* ---------- USER RETURNED BEFORE TIMER ---------- */
    if (state == AppLifecycleState.resumed &&
        timerProvider.secondsLeft > 0) {
      timerProvider.pause();

      if (!context.mounted) return;


      ShowDialogs.taskNotComplete(contextPop: context,
          body: "\nTime left: ${timerProvider.secondsLeft}s\n\n"
              "Please make sure you fully visit the website and scroll down as required.",
          onContinueText: "Continue",
          closeText: "Cancel",
          onContinue: () async{
            Navigator.of(context).pop();
            timerProvider.resume();
            startWebsiteTask(
              context: context,
              url: _url!,
              reward: _reward,
              screenFrom: _screenFrom,
              seconds: timerProvider.secondsLeft,
              campaignId: _campaignId!,
            );
          },
          close: ()async{
            Navigator.of(context).pop();
            timerProvider.cancel();
            FlutterOverlayWindow.closeOverlay();
            _taskLaunched = false;
          }
      );
    }


    /* ---------- TIMER FINISHED ---------- */
    else if (state == AppLifecycleState.resumed &&
        timerProvider.secondsLeft <= 0 &&
        !_completionInProgress) {
      _completionInProgress = true;
      _taskLaunched = false;

      FlutterOverlayWindow.closeOverlay();

      final taskProvider =
      Provider.of<TaskProvider>(context, listen: false);

      if (!context.mounted) return;

      /* ----- LOADING DIALOG ----- */
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          _loadingDialogContext = ctx;
          return AlertDialog(
            backgroundColor: theme.secondaryContainer,
            content: Row(spacing: 5,
              children: [
               const CircularProgressIndicator(color: Colors.white,),
               const SizedBox(width: 8),
                Image.asset('assets/ico/1xTickets.webp', width: 30,),
                Expanded(child: Text("$_reward Tickets adding...",
                  style: textStyle.displaySmall?.copyWith(color: Colors.white, fontSize: 18,),)),
              ],
            ),
          );
        },
      );

      try {
        await taskProvider.completeTask(
          context: context,
          campaignId: _campaignId!,
          rewardCoins: _reward,
          onPage: _screenFrom,
        );

        _closeLoadingDialog();
      } catch (e) {
        _closeLoadingDialog();

        AlertMessage.errorMsg(
          context,
          "Error",
          "Failed to complete task",
        );
      } finally {
        _completionInProgress = false;
      }
    }
  }

  /* ---------------- SAFE DIALOG CLOSE ---------------- */
  static void _closeLoadingDialog() {
    if (_loadingDialogContext != null &&
        Navigator.of(_loadingDialogContext!).canPop()) {
      Navigator.of(_loadingDialogContext!).pop();
    }
    _loadingDialogContext = null;
  }
}
