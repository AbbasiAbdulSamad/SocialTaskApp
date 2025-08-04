import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class FaqPage extends StatelessWidget {
  FaqPage({super.key});
  final List<Map<String, String>> faqData = [
    {"question": "What is Social Task?",
      "answer": "Social Task is a YouTube engagement exchange app where users can earn tickets by watching videos, liking, commenting, or subscribing to YouTube channels. These tickets can then be used to promote your own videos."},

    {"question": "How to use Social Task?",
      "answer": "First, you need to collect tickets by completing tasks.\nYou can earn tickets by completing tasks, subscribing to channels, liking videos or commenting on Facebook posts, etc.\nAfter collecting tickets, one can promote their post by running a social media post campaign."},

    {"question": "How to Work Social Task?",
      "answer": "Social Task App is designed to help real users see your posts as your campaign progresses, which helps boost your social accounts.\nYou are charged tickets for the campaigns you run. And users earn tickets in exchange for viewing the campaigns you run."},

    {"question": "What are tickets and how do they work?",
      "answer": "Tickets are a digital in-app currency. You earn them by completing tasks for others, and spend them to create campaigns that get you views, likes, comments, or subscribers on your YouTube videos."},

    {"question": "Is this app against YouTube’s rules?",
      "answer": "Social Task is not affiliated with or endorsed by YouTube. You are responsible for ensuring that your use of the app follows YouTube’s Terms of Service and Community Guidelines. We do not support fake or artificial engagement."},

    {"question": "Is the app safe? Is my Google account secure?",
      "answer": "Yes. We use secure Google Sign-In and only access your public information (name, email, and profile picture). We never store or access your password. Your data and privacy are protected."},

    {"question": "Do I earn the same number of tickets for every task?",
      "answer": "No. Each task offers a different number of tickets depending on its type (subscribe, like, comment, view) and how many tickets the campaign creator has assigned."},

    {"question": "What happens if I complete tasks incorrectly or try to cheat?",
      "answer": "If you use bots, fake accounts, or complete tasks dishonestly, your account may be suspended or permanently banned from the platform."},

    {"question": "How can I delete my account?",
      "answer": "To delete your account and associated data, contact us at support@socialtask.xyz . We will process your request within 72 hours."},

    {"question": "There is an error in the SocialTask application, what should I do?",
      "answer": "In that case, please contact us. We will fix it quickly.\nsupport@socialtask.xyz\nIf you tell us, we will reward you with 1000 tickets."},

    {"question": "Can we delete or pause our campaign after it runs?",
      "answer": "After creating a campaign, you can pause it anytime while it's running, but you cannot delete it immediately. Once the campaign is completed, you will be able to delete it from your campaign history. This ensures transparency and tracking until the campaign has ended."},

    {"question": "Can my account be blocked?",
      "answer": "Yes, if you make a mistake or complete a task and earn tickets, then undo the task.\nExample: Unsubscribing from a YouTube channel after completing the task.\nSocialTask app detects your account activity and automatically blocks your account."},

    {"question": "How to get a YouTube video link?",
      "answer": "Open the YouTube -> Go to your video for which you want to create a campaign.\nAnd you will see the share button, click on it.\nThen click Copy Link to copy the video link."},

    // {"question": "How to get a Facebook Post link?",
    //   "answer": "Open the Facebook -> Go to your post for which you want to create a campaign.\nAnd you will see the share button, click on it.\nThen click Copy Link to copy the video link."},

  ];
  @override
  Widget build(BuildContext context) {
    ColorScheme theme=Theme.of(context).colorScheme;
    return Scaffold( backgroundColor: Theme.of(context).colorScheme.primaryFixed,
          appBar: AppBar(title: const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18)),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: theme.surfaceTint,
              statusBarIconBrightness: Brightness.light,),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: ListView.builder(
              itemCount: faqData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  child: ExpansionTile(
                    backgroundColor: theme.background,
                    collapsedBackgroundColor: theme.background,
                    title: Text(faqData[index]["question"]!),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Text(faqData[index]["answer"]!, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 15, height: 1.7, color: theme.errorContainer)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
  }
}
