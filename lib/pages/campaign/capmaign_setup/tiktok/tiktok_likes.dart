import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui/layout_widgets/tiktok_layout.dart';
import '../../../../ui/layout_widgets/youtube_layout.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../server_model/internet_provider.dart';
import '../../../../server_model/provider/campaign_api.dart';
import '../../../../server_model/provider/users_provider.dart';
import '../../../../ui/flash_message.dart';

class Tiktok_likes extends StatelessWidget {
  final String? taskLink;
  final String? accountName;
  final String? accountUrl;
  final String? thumbnailUrl;
  final String? videoTitle;

  Tiktok_likes({
    super.key,
    required this.taskLink,
    required this.accountName,
    required this.accountUrl,
    required this.thumbnailUrl,
    required this.videoTitle,
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController quantitySubscribers = TextEditingController();
  final ValueNotifier<String?> selectedCategory = ValueNotifier<String?>(null);
  final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> discountNotifier = ValueNotifier<int>(0);

  // 🔹 Quantity Calculation Function
  void updateTotal(BuildContext context) {
    final int subscriberValue = int.tryParse(quantitySubscribers.text) ?? 0;
    final int subscriber = subscriberValue * 5;
    int totalCoins = subscriber;

    // ✅ Apply 80% Discount if Premium
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser?.isPremium == true) {
      // 🟢 Premium user: Apply 20% discount
      discountNotifier.value = (totalCoins * 20) ~/ 100; // 20% discount
      totalNotifier.value = totalCoins - discountNotifier.value; // Remaining 80%
    } else {
      // 🔴 Non-Premium user: No discount
      discountNotifier.value = 0;
      totalNotifier.value = totalCoins;
    }
  }

  // 🔹 Value Live Campaign (Updated)
  void buttonAction(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      final internetProvider = Provider.of<InternetProvider>(context, listen: false);
      if (internetProvider.isConnected) {
      await campaignProvider.createCampaign(
        context: context,
        title: videoTitle!,
        videoUrl: taskLink!,
        watchTime: 0,
        quantity: int.tryParse(quantitySubscribers.text) ?? 0,
        selectedOption: "Likes",
        campaignImg: thumbnailUrl!,
        social: "TikTok",
        catagory: selectedCategory.value ?? "None",
      );
      } else {
        AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Add listeners here to pass the correct context
    quantitySubscribers.addListener(() => updateTotal(context));
    selectedCategory.addListener(() => updateTotal(context));

    return Stack(
      children: [
        // Underlying content
        FutureBuilder(
          future: Provider.of<UserProvider>(context, listen: false).fetchCurrentUser(),
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Youtube Layout Page include from youtube_layout.dart
                  TiktokLayout(
                    thumbnailUrl: thumbnailUrl!,
                    videoTitle: videoTitle!,
                    accountName: accountName!,
                    accountUrl: accountUrl!,
                    taskUrl: taskLink!,
                    formKey: _formKey,
                    selectedCategory: selectedCategory,
                    quantitySubscribers: quantitySubscribers,
                    totalNotifier: totalNotifier,
                    discountNotifier: discountNotifier,
                    updateTotal: () => updateTotal(context),
                    buttonAction: () {
                      FocusScope.of(context).unfocus();
                      buttonAction(context);
                    },
                    ytService: 'Likes',
                    ytServiceIcon: Icons.favorite,
                  ),
                ],
              ),
            );
          },
        ),

        // Loading overlay (only when waiting)
        FutureBuilder(
          future: Provider.of<UserProvider>(context, listen: false).fetchCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
