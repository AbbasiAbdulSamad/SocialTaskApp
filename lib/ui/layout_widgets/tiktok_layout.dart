import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../server_model/provider/campaign_api.dart';
import '../../server_model/provider/users_provider.dart';
import '../flash_message.dart';
import '../bg_box.dart';
import '../button.dart';
import '../ui_helper.dart';
class TiktokLayout extends StatelessWidget {
  final String thumbnailUrl;
  final String videoTitle;
  final String accountName;
  final String accountUrl;
  final String taskUrl;

  final GlobalKey formKey;
  final ValueNotifier<String?> selectedCategory;
  final TextEditingController quantitySubscribers;
  final VoidCallback buttonAction;
  final ValueNotifier<int> totalNotifier;
  final ValueNotifier<int> discountNotifier;
  final VoidCallback updateTotal;
  final String ytService;
  final IconData ytServiceIcon;

  TiktokLayout({super.key, required this.thumbnailUrl, required this.videoTitle, required this.accountName, required this.accountUrl,
    required this.taskUrl, required this.formKey, required this.selectedCategory, required this.quantitySubscribers,
    required this.buttonAction, required this.totalNotifier, required this.discountNotifier, required this.updateTotal, required this.ytService, required this.ytServiceIcon})
  { // initState auto start Value Listener
    quantitySubscribers.addListener(updateTotal);
    selectedCategory.addListener(updateTotal);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Future.delayed(Duration(milliseconds: 600), () {
      userProvider.fetchCurrentUser();
    });

    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Consumer<CampaignProvider>(
      builder: (context, campaignProvider, child) {
        return Stack(
          children: [ Column(children: [
            Stack(
              children: [
                InkWell(
                  onTap: ()=>launchUrl(Uri.parse(taskUrl)),
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Ui.networkImage(context, thumbnailUrl, 'assets/ico/image_loading.png', double.infinity, 500)),
                ),

                Positioned(
                  left: 0, right: 0, bottom: 10,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(videoTitle, maxLines: 4, overflow: TextOverflow.ellipsis,
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,),
                          ),
                        ),
                        const SizedBox(height: 6),

                        InkWell(
                          onTap: ()=> launchUrl(Uri.parse(accountUrl)),
                          child: Container(
                            color: Colors.black54,
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Row(children: [
                              Container(width: 40,
                                decoration: BoxDecoration(shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1,),),
                                child: ClipOval(
                                  child: Image.asset('assets/ico/tiktok_icon.webp', fit: BoxFit.cover,),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(accountName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,),),
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Positioned(
                    left: 0, right: 0, top: 215,
                    child: InkWell(
                        onTap: ()=> launchUrl(Uri.parse(taskUrl)),
                        child: Image.asset("assets/ico/tiktok_play_icon.webp", width: 70, height: 70,)))
              ],
            ),
            // Title and Profile Box

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


                    // Quantity Value Input Getter
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                                return'Followers' ;}
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
                          Text('Important', style: textTheme.labelMedium?.copyWith(fontSize: 20, color: theme.error)),
                        ],),
                        const SizedBox(height: 10,),
                        Text('Do not create too many campaigns for the same video. TikTok may not count multiple views from the same IP address in a short time.',
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