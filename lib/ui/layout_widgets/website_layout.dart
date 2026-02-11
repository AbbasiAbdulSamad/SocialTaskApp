import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/sidebar_pages/buy_tickets.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/provider/campaign_api.dart';
import '../../server_model/provider/users_provider.dart';
import '../flash_message.dart';
import '../bg_box.dart';
import '../button.dart';
import '../ui_helper.dart';

class WebsiteLayout extends StatelessWidget {
  final String webIcon;
  final String webTitle;
  final String taskUrl;

  final GlobalKey formKey;
  final ValueNotifier<String?> selectedCategory;
  final ValueNotifier<String?> selectedCountry;
  final TextEditingController quantitySubscribers;
  final VoidCallback buttonAction;
  final ValueNotifier<int?> selectedTime;
  final ValueNotifier<int> totalNotifier;
  final ValueNotifier<int> discountNotifier;
  final VoidCallback updateTotal;
  final String ytService;
  final IconData ytServiceIcon;

  WebsiteLayout({super.key, required this.webIcon, required this.webTitle, required this.taskUrl, required this.formKey, required this.selectedTime, required this.selectedCategory,
    required this.selectedCountry, required this.quantitySubscribers,
    required this.buttonAction, required this.totalNotifier, required this.discountNotifier, required this.updateTotal, required this.ytService, required this.ytServiceIcon})
  { // initState auto start Value Listener
    quantitySubscribers.addListener(updateTotal);
    selectedTime.addListener(updateTotal);
    selectedCategory.addListener(updateTotal);
    selectedCountry.addListener(updateTotal);
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
            Column(
              children: [
                const SizedBox(height: 30),
                InkWell(
                  onTap: () async{
                    await launchUrl(
                    Uri.parse(taskUrl),
                    mode: LaunchMode.externalApplication,
                    );
                  },
                  child: BgBox(
                    margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    padding: const EdgeInsets.symmetric(vertical:8, horizontal: 10),
                    allRaduis: 5,
                    wth: double.infinity,
                    child: Row(children: [
                      SizedBox(width: 85,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Ui.networkImage(context, webIcon, 'assets/ico/web.webp', 75, 75)
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(webTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),),
                            Text(taskUrl, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: theme.errorContainer, fontSize: 14, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            // Title and Profile Box

            const SizedBox(height: 25,),
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
                          const Icon(CupertinoIcons.app_badge_fill),
                          const Expanded(child: Text('Web Category',style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 150,

                            // Select Options
                            child: ValueListenableBuilder<String?>(
                              valueListenable: selectedCategory,
                              builder: (context, value, child) {
                                return DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  hint: Text('Select Category', style: textTheme.displaySmall?.copyWith(color: Colors.grey),),
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

                    // Target Adiunce
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          const Icon(CupertinoIcons.flag),
                          const Expanded(child: Text('Target Country',style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 130,

                            child: ValueListenableBuilder<String?>(
                              valueListenable: selectedCountry,
                              builder: (context, value, child) {
                                return DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  hint: Text('All Country', style: textTheme.displaySmall?.copyWith(color: Colors.grey),),
                                  value: value,
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: "All Country",
                                      child: Text('All Country'),
                                    ),

                                    // ❌ Disabled option
                                    DropdownMenuItem(
                                      value: "Custom",
                                      enabled: false, // 👈 disable selection
                                      child: Text('Custom (coming soon)',
                                        style: textTheme.displaySmall?.copyWith(color: Colors.grey, fontSize: 16),
                                      ),
                                    ),
                                  ],

                                  onChanged: (newValue) {
                                    // disabled item kabhi yahan nahi aayega
                                    selectedCountry.value = newValue;
                                  },
                                );

                              },
                            ),
                          ),
                        ],),
                    ),

                    // Select Value Box
                    BgBox(
                      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      allRaduis: 5,
                      wth: double.infinity,
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 5,
                        children: [
                          const Icon(Icons.timer),
                          const Expanded(child: Text('Stay Duration',style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1,)),
                          SizedBox(width: 108,
                            // Select Options
                            child: ValueListenableBuilder<int?>(
                              valueListenable: selectedTime,
                              builder: (context, value, child) {
                                return DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  value: value, // Default selected value (int)
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                    border: OutlineInputBorder(borderSide: BorderSide.none),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 10, child: Text('10 sec')),
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
                              if (number > 10000) {
                                showError("Maximum number allowed is 1000.");
                                return'maximum 10000';}
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
                    if(Provider.of<CampaignProvider>(context, listen: false).campaignNotEnough)
                      Container(margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        width: double.infinity,
                        child: MyButton(txt: 'Buy Tickets', img: '2xTickets.webp', imgSize: 28, fontfamily: '3rdRoboto', bgColor: theme.surfaceDim,
                          shadowOn: true, borderLineOn: true, borderRadius: 10, txtSize: 17,
                          txtColor: theme.onPrimaryContainer, onClick: ()=> Helper.navigatePush(context, const BuyTickets()),
                        ),
                      ),

                    // Button Create Campaign
                    (campaignProvider.isLoading)? const Text('Campaign Creating...')
                        : Container(margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
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
                        Text('Do not create too many campaigns for the same blog post or article.',
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