import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../server_model/provider/task_complete.dart';
import '../../../ui/button.dart';
import '../../../ui/flash_message.dart';
import '../../home.dart';

class TikTokTaskHandler {
  static DateTime? _taskStartTime;
  static bool _taskLaunched = false;
  static String? _lastTikTokUrl;
  static int _requiredSeconds = 5;

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

        await Future.delayed(const Duration(seconds: 3));
        Navigator.of(context).pop(); // Close loading dialog
        _showEarlyReturnDialog(context);
      }
      // User waited long enough: show live API loading
      else {
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
    _screenFrom = screenFrom;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          content: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(taskType=="Followers"?Icons.supervised_user_circle_rounded: taskType=="Likes"?Icons.thumb_up
                        :taskType=="Favorites"?Icons.bookmark:Icons.comment, size: 27),

                    const SizedBox(width: 10),
                    Text(taskType=="Followers"?'Follow Account': taskType=="Likes"?'Like Video'
                        :taskType=="Favorites"?'Favorite Video':'Comment on the video'
                        , style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22)),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/ico/warning.webp', width: 25),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please ${taskType=="Followers"?'follow the account': taskType=="Likes"?'like the video'
                            :taskType=="Favorites"?'favorite the video':'comment on the video'}'
                            ', Otherwise, your tickets will be deducted.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 90,
                      height: 35,
                      child: MyButton(
                        txt: "I Agree",
                        borderRadius: 40,
                        shadowOn: true,
                        bgColor: const Color(0xff5dacd6),
                        borderLineOn: true,
                        borderLineSize: 0.5,
                        borderColor: Colors.black,
                        txtSize: 16,
                        txtColor: Colors.black,
                        onClick: () async {
                          Navigator.of(context).pop();
                          final launched = await launchUrl(
                            Uri.parse(tiktokUrl),
                            mode: LaunchMode.externalApplication,
                          );

                          if (launched) {
                            _taskLaunched = true;
                            _taskStartTime = DateTime.now();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
    ColorScheme theme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        content: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Task Not Completed", style: TextStyle(fontSize: 20, color: theme.error)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text("You didn't like the video. Please like it before returning."),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("Cancel", style: TextStyle(color: theme.onPrimaryContainer, fontSize: 18)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  MyButton(
                    txt: "Continue Task",
                    borderRadius: 40,
                    pading: const EdgeInsets.only(left: 20, right: 20),
                    shadowOn: true,
                    bgColor: theme.onPrimary,
                    borderLineOn: true,
                    borderLineSize: 0.5,
                    borderColor: theme.onPrimaryContainer,
                    txtSize: 16,
                    txtColor: Colors.black,
                    onClick: () async {
                      Navigator.of(context).pop();
                      final launched = await launchUrl(
                        Uri.parse(_lastTikTokUrl!),
                        mode: LaunchMode.externalApplication,
                      );

                      if (launched) {
                        _taskLaunched = true;
                        _taskStartTime = DateTime.now();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
