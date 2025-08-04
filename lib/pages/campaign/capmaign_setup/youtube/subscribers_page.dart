import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../ui/layout_widgets/youtube_layout.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../server_model/internet_provider.dart';
import '../../../../server_model/provider/campaign_api.dart';
import '../../../../server_model/provider/users_provider.dart';
import '../../../../ui/flash_message.dart';

class SubscribePage extends StatelessWidget {
  final String? videoLink;
  final String? videoId;
  final String? videoTitle;
  final String? channelTitle;
  final String? channelProfileImage;
  final String? videoThumbnail;
  final YoutubePlayerController? youtubeController;

  SubscribePage({
    super.key,
    required this.youtubeController,
    required this.channelProfileImage,
    required this.channelTitle,
    required this.videoId,
    required this.videoThumbnail,
    required this.videoTitle,
    required this.videoLink,
  });

  final _formKey = GlobalKey<FormState>();
  final TextEditingController quantitySubscribers = TextEditingController();
  final ValueNotifier<int?> selectedTime = ValueNotifier<int?>(20);
  final ValueNotifier<String?> selectedCategory = ValueNotifier<String?>(null);
  final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> discountNotifier = ValueNotifier<int>(0);

  // 🔹 Quantity Calculation Function
  void updateTotal(BuildContext context) {
    final int subscriberValue = int.tryParse(quantitySubscribers.text) ?? 0;
    final int selectedValue = selectedTime.value ?? 0;
    final int subscriber = subscriberValue * 8;
    int watchtime = 0;

    switch (selectedValue) {
      case 20:watchtime = 2 * subscriberValue;
        break;
      case 30:watchtime = 3 * subscriberValue;
        break;
      case 45:watchtime = 4 * subscriberValue;
        break;
        case 60:watchtime = 6 * subscriberValue;
        break;
      case 90:watchtime = 9 * subscriberValue;
        break;
      case 120:watchtime = 12 * subscriberValue;
        break;
      case 150:watchtime = 15 * subscriberValue;
        break;
      case 180:watchtime = 18 * subscriberValue;
        break;
      case 210:watchtime = 21 * subscriberValue;
        break;
      case 240:watchtime = 24 * subscriberValue;
        break;
      case 270:watchtime = 27 * subscriberValue;
        break;
      case 300:watchtime = 30 * subscriberValue;
        break;
      default:watchtime = 0;
    }
    int totalCoins = subscriber + watchtime;

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
        title: channelTitle!,
        videoUrl: videoLink!,
        watchTime: selectedTime.value ?? 0,
        quantity: int.tryParse(quantitySubscribers.text) ?? 0,
        selectedOption: "Subscribers",
        campaignImg: channelProfileImage!,
        social: "YouTube",
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
    selectedTime.addListener(() => updateTotal(context));
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
                  ytLayout(
                    youtubeController: youtubeController!,
                    channelProfileImage: channelProfileImage!,
                    videoTitle: videoTitle!,
                    channelTitle: channelTitle!,
                    formKey: _formKey,
                    selectedTime: selectedTime,
                    selectedCategory: selectedCategory,
                    quantitySubscribers: quantitySubscribers,
                    totalNotifier: totalNotifier,
                    discountNotifier: discountNotifier,
                    updateTotal: () => updateTotal(context),
                    buttonAction: () {
                      FocusScope.of(context).unfocus();
                      buttonAction(context);
                    },
                    ytService: 'Subscribers',
                    ytServiceIcon: Icons.subscriptions,
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
              return const SizedBox.shrink(); // Hide overlay when not loading
            }
          },
        ),
      ],
    );
  }
}
