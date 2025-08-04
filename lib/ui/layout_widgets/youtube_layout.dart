import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../server_model/provider/campaign_api.dart';
import '../../server_model/provider/users_provider.dart';
import '../flash_message.dart';
import '../bg_box.dart';
import '../button.dart';
import '../ui_helper.dart';
class ytLayout extends StatelessWidget {
  final YoutubePlayerController youtubeController;
  final String channelProfileImage;
  final String videoTitle;
  final String channelTitle;
  final GlobalKey formKey;
  final ValueNotifier<int?> selectedTime;
  final ValueNotifier<String?> selectedCategory;
  final TextEditingController quantitySubscribers;
  final VoidCallback buttonAction;
  final ValueNotifier<int> totalNotifier;
  final ValueNotifier<int> discountNotifier;
  final VoidCallback updateTotal;
  final String ytService;
  final IconData ytServiceIcon;

  ytLayout({super.key, required this.youtubeController, required this.channelProfileImage, required this.videoTitle, required this.channelTitle,
    required this.formKey, required this.selectedTime, required this.selectedCategory, required this.quantitySubscribers, required this.buttonAction,
    required this.totalNotifier, required this.discountNotifier, required this.updateTotal, required this.ytService, required this.ytServiceIcon})
  { // initState auto start Value Listener
    quantitySubscribers.addListener(updateTotal);
    selectedTime.addListener(updateTotal);
    selectedCategory.addListener(updateTotal);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Future.microtask(() {
      userProvider.fetchCurrentUser();
    });
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Consumer<CampaignProvider>(
      builder: (context, campaignProvider, child) {
        return Stack(
          children: [ Column(children: [
            // youtube video display
            YoutubePlayerBuilder(
              player: YoutubePlayer(controller: youtubeController),
              builder: (context, player) => player,),

            // Title and Profile Box
            BgBox(
              margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              allRaduis: 7,
              child: Row(children: [
                Container(width: 55,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: theme.onPrimaryContainer, width: 2.0,),),
                  child: ClipOval(
                    child: Image.network(channelProfileImage, fit: BoxFit.cover,),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(videoTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 16, fontWeight: FontWeight.bold, color: theme.onPrimaryContainer,),
                      ),
                      const SizedBox(height: 6),
                      Text(channelTitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.secondary,),),
                    ],),
                ),
              ]),
            ),
            const SizedBox(height: 10,),
            Form(key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min,
                  children: [
                    // Select Value Box
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          const Icon(Icons.library_add_check_outlined),
                          const Expanded(child: Text('Video Category',style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 155,

                            // Select Options
                            child: ValueListenableBuilder<String?>(
                              valueListenable: selectedCategory,
                              builder: (context, value, child) {
                                return DropdownButtonFormField<String>(
                                  hint: const Text('Choice Option'),
                                  value: value, // Default selected value (int)
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: "Education", child: Text('Education')),
                                    DropdownMenuItem(value: "Gaming", child: Text('Gaming')),
                                    DropdownMenuItem(value: "Technology", child: Text('Technology')),
                                    DropdownMenuItem(value: "Entertainment", child: Text('Entertainment')),
                                    DropdownMenuItem(value: "Health", child: Text('Health')),
                                    DropdownMenuItem(value: "Business", child: Text('Business')),
                                    DropdownMenuItem(value: "Lifestyle", child: Text('Lifestyle')),
                                    DropdownMenuItem(value: "Motivation", child: Text('Motivation')),
                                    DropdownMenuItem(value: "News & Politics", child: Text('News & Politics')),
                                    DropdownMenuItem(value: "Sports", child: Text('Sports')),
                                  ],

                                  // Update the int value
                                  onChanged: (newValue) {
                                    selectedCategory.value = newValue;},
                                  validator: (selectedCatagory) {
                                    if (selectedCatagory == ""|| selectedCatagory==null){
                                      AlertMessage.errorMsg(context, 'Please Select Video Category', 'Invalid !');
                                      return 'Select Video Category';}
                                    return null;},
                                );
                              },
                            ),
                          ),
                        ],),
                    ),


                    // Select Value Box
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          const Icon(Icons.timer),
                          const Expanded(child: Text('Watch Time',style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 108,

                            // Select Options
                            child: ValueListenableBuilder<int?>(
                              valueListenable: selectedTime,
                              builder: (context, value, child) {
                                return DropdownButtonFormField<int>(
                                  value: value, // Default selected value (int)
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 20, child: Text('20 sec')),
                                    DropdownMenuItem(value: 30, child: Text('30 sec')),
                                    DropdownMenuItem(value: 45, child: Text('45 sec')),
                                    DropdownMenuItem(value: 60, child: Text('60 sec')), // 1 min
                                    DropdownMenuItem(value: 90, child: Text('90 sec')),
                                    DropdownMenuItem(value: 120, child: Text('120 sec')), // 2 min
                                    DropdownMenuItem(value: 150, child: Text('150 sec')),
                                    DropdownMenuItem(value: 180, child: Text('180 sec')), // 3 min
                                    DropdownMenuItem(value: 210, child: Text('210 sec')),
                                    DropdownMenuItem(value: 240, child: Text('240 sec')), // 4 min
                                    DropdownMenuItem(value: 270, child: Text('270 sec')),
                                    DropdownMenuItem(value: 300, child: Text('300 sec')), // 5 min
                                  ],

                                  // Update the int value
                                  onChanged: (newValue) {
                                    selectedTime.value = newValue;},
                                  validator: (selectedValue) {
                                    if (selectedValue == null || selectedValue <= 0){
                                      return 'Select time duration';}
                                    return null;},
                                );
                              },
                            ),
                          ),
                        ],),
                    ),

                    // Quantity Value Input Getter
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      padding: const EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 0),
                      allRaduis: 7,
                      wth: double.infinity,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          Icon(ytServiceIcon), // Icon getting form Pages

                          // Service Getting Name
                          Expanded(child: Text(ytService,style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 120,

                            // Input class import from ui_helper.dart
                            child: Ui.input(context, quantitySubscribers, 'Quantity', '10', TextInputType.number,
                                  (value){void showError(String message){

                                // show Error message alert import from alert_messsage.dart
                                AlertMessage.errorMsg(context, message, 'Invalid !');}

                              // Quantity input validation checking
                              if (value == null || value.isEmpty) {
                                showError("Enter the Quantity of $ytService.");
                                return'Subscribers' ;}
                              final number = int.tryParse(value);
                              if (number == null || value.isEmpty) {
                                showError("Enter a valid number");
                                return 'not valid.';}
                              if (number < 10) {
                                showError("Minimum number allowed is 10.");
                                return'minimum 10';}
                              if (number > 1000) {
                                showError("Maximum number allowed is 1000.");
                                return'maximum 1000';}
                              return null;},
                            ),
                          ),
                        ],),),

                    // Line border
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 5, left: 15, right: 15),
                      child:Ui.line(),),

                    // Discount
                    (userProvider.currentUser?.isPremium == true)?
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 7,
                          children: [
                            const Icon(Icons.workspace_premium, size: 22,),
                            const Expanded(child: Text('Discount 20%',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                            Align(alignment: Alignment.centerRight,

                              // Total Calculate display show real time
                              child: ValueListenableBuilder<int>(
                                valueListenable: discountNotifier,
                                builder: (context, discount, child) {
                                  return Text("-$discount", style: textTheme.displaySmall?.copyWith
                                    (fontSize: 23, color: theme.errorContainer, fontWeight: FontWeight.bold));
                                },
                              ),
                            ),
                          ],),
                      ),): SizedBox(),
                    // Total Cost Box
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 7,
                          children: [
                            const Icon(Icons.payments_outlined, size: 22,),
                            const Expanded(child: Text('Cost of Tickets',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                            Align(alignment: Alignment.centerRight,

                              // Total Calculate display show real time
                              child: ValueListenableBuilder<int>(
                                valueListenable: totalNotifier,
                                builder: (context, total, child) {
                                  return Text("$total", style: textTheme.displaySmall?.copyWith
                                    (fontSize: 23, color: theme.errorContainer, fontWeight: FontWeight.bold));
                                },
                              ),
                            ),
                          ],),
                      ),),
                    const SizedBox(height: 10),

                    // Button Create Campaign
                    (campaignProvider.isLoading)? const Text('Campaign Creating...')
                    : Container(margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      width: double.infinity,
                      child: MyButton(
                        txt: 'Create Campaign', fontfamily: '3rdRoboto', bgColor: theme.surfaceDim,
                        shadowOn: true, borderLineOn: true, borderRadius: 10, txtSize: 17,
                        txtColor: theme.onPrimaryContainer, onClick: buttonAction,
                      ),
                    ),
                    const SizedBox(height: 20,),

                    // Last Keep in mind text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      child:Column(children: [

                        // Underline
                        Stack(children: [
                          Positioned(bottom: 2, left: 0, right: 0,
                            child: Container(height: 2, color: theme.error, ),),
                          Text('keep in mind', style: textTheme.labelMedium?.copyWith(fontSize: 20, color: theme.error)),
                        ],),
                        const SizedBox(height: 10,),
                        Text('Do not create to many campaigns for one video, YT will not count many views from one IP in very short time.\n\n'
                            'YouTube need 72 hours to update views from third party apps. so wait at least 72 hours to see the updated views in YT studio.',
                          style: textTheme.displaySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w300, color: theme.primaryContainer),),
                      ],),)

                  ],)
            )
          ]),
          ],);
      },
    );
  }
}