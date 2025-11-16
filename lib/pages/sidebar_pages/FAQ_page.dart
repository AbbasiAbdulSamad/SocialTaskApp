import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class FaqPage extends StatelessWidget {
  FaqPage({super.key});
  final List<Map<String, String>> faqData =
  [
    {
      "question": "What is Social Task?",
      "answer": "Social Task is a multi-platform engagement exchange app where users can earn tickets by completing real tasks on YouTube, TikTok, and Instagram — such as watching videos, liking posts, following accounts, or commenting. These tickets can then be used to promote your own social media content."
    },
    {
      "question": "How to use Social Task?",
      "answer": "Start by collecting tickets through completing tasks like subscribing, liking, following, or commenting on YouTube, TikTok, and Instagram content. Once you have enough tickets, you can create your own campaign to get engagement on your videos or posts."
    },
    {
      "question": "How does Social Task work?",
      "answer": "Social Task connects real users who complete each other's tasks. When your campaign runs, other users interact with your post to earn tickets, and you spend tickets to gain engagement. This helps grow your social media accounts organically."
    },
    {
      "question": "What are tickets and how do they work?",
      "answer": "Tickets are the in-app digital currency. You earn them by completing social tasks for other users, and spend them to create campaigns that bring real engagement — such as views, likes, comments, followers, or subscribers — across YouTube, TikTok, and Instagram."
    },
    {
      "question": "Is this app against YouTube, TikTok, or Instagram rules?",
      "answer": "Social Task is not affiliated with or endorsed by YouTube, TikTok, or Instagram. You are responsible for following each platform’s Terms of Service and Community Guidelines. We strictly prohibit fake, spam, or automated engagement."
    },
    {
      "question": "Is the app safe? Is my account secure?",
      "answer": "Yes. We use secure Google Sign-In and never store or access your passwords. We only collect public information such as name, email, and profile picture for login purposes. Your privacy and data are fully protected."
    },
    {
      "question": "Do I earn the same number of tickets for every task?",
      "answer": "No. Each task has a different ticket value depending on its type — for example, subscribe, follow, like, view, or comment — and the number of tickets set by the campaign creator."
    },
    {
      "question": "What happens if I complete tasks incorrectly or try to cheat?",
      "answer": "Using bots, fake accounts, or completing tasks dishonestly is strictly prohibited. Any cheating or invalid activity may result in suspension or permanent ban of your account."
    },
    {
      "question": "Can my account be blocked?",
      "answer": "Yes. If you complete a task and later undo it — for example, unfollowing or unsubscribing after earning tickets — your account may be automatically blocked by our system for violating fair-use policy."
    },
    {
      "question": "Can we delete or pause our campaign after it runs?",
      "answer": "Yes. You can pause any active campaign at any time. However, campaigns cannot be deleted immediately while running. After a campaign is completed, you can delete it from your campaign history for record clarity."
    },
    {
      "question": "There is an error in the Social Task app, what should I do?",
      "answer": "If you face any bug or error, please go to the Support page inside the app and send a support request. Our team will review your issue and respond within 24 hours. Verified bug reporters may receive bonus tickets as a thank you."
    },
    {
      "question": "How can I delete my account?",
      "answer": "To permanently delete your account and all associated data, go to the Support page in the app and send an account deletion request. Your request will be processed within 72 hours."
    }
  ];

  @override
  Widget build(BuildContext context) {
    ColorScheme theme=Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold( backgroundColor: Theme.of(context).colorScheme.primaryFixed,
          appBar: AppBar(title: Text('Frequently Asked Questions', style: textTheme.displaySmall?.copyWith(fontSize: 20, color: Colors.white)),
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
