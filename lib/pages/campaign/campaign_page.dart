import 'dart:convert';

import 'package:app/ui/pop_alert.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/config.dart';
import '../../screen/home.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/internet_provider.dart';
import '../../server_model/page_load_fetchData.dart';
import '../../server_model/provider/campaign_api.dart';
import '../../server_model/provider/campaigns_action.dart';
import '../../server_model/provider/users_provider.dart';
import '../../ui/button.dart';
import '../../ui/dot_menu_list.dart';
import '../../ui/flash_message.dart';
import '../../ui/ui_helper.dart';
import 'camp_select_list_data.dart';
import 'campaign_details.dart';
import 'capmaign_setup/youtube/YT_link_getting.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask((){
      Provider.of<CampaignProvider>(context, listen: false).fetchCampaigns(forceRefresh: true);
      Provider.of<UserProvider>(context, listen: false).fetchCurrentUser();
    });
  }


  Future<void> reCreateCampaign({
    required BuildContext context,
    required String title,
    required String videoUrl,
    required int watchTime,
    required int quantity,
    required String selectedOption,
    required String campaignImg,
    required String social,
    required String catagory,
  }) async {
    try {
      // ✅ Validate quantity before proceeding
      if (quantity <= 0) {
        AlertMessage.errorMsg(context, "Quantity must be greater than 10.", "Invalid Input");
        return;
      }
      String? token = await Helper.getAuthToken();
      if (token == null) return;
      final response = await http.post(
        Uri.parse(ApiPoints.campaignsPost),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'videoUrl': videoUrl,
          'watchTime': watchTime,
          'quantity': quantity,
          'selectedOption': selectedOption,
          'campaignImg': campaignImg,
          'social': social,
          'catagory': catagory,
        }),
      );

      if (response.statusCode == 201){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const Home(onPage: 2)), (route) => false);
        AlertMessage.successMsg(context, 'New $selectedOption campaign is now active.', 'Success');
      } else {
        String errorMessage = "Something went wrong, please try again.";
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('error')) {
            errorMessage = errorJson['error'];
          }
        } catch (e) {
          debugPrint("⚠️ Error parsing JSON response: $e");
        }
        // ✅ Show actual error message
        AlertMessage.errorMsg(context, errorMessage, 'Not enough');
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      AlertMessage.errorMsg(context, 'Something went wrong, please try again.', 'An Error');
    }
  }
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final internetProvider = Provider.of<InternetProvider>(context, listen: false);
    String? _selectedOption;

    void _onDropdownChanged(String? newValue) {
      setState(() {
        _selectedOption = newValue;
      });
    }

    return Scaffold(
      backgroundColor: theme.primaryFixed,
      body: Consumer<CampaignProvider>(
        builder: (context, campaignProvider, child) {
          return RefreshIndicator(
            color: theme.onPrimaryContainer,
            onRefresh: () => campaignProvider.fetchCampaigns(forceRefresh: true), // 🔄 Pull-to-Refresh
            child: campaignProvider.isLoading
                ? Ui.loading(context) // ✅ Loader
                : campaignProvider.errorMessage.isNotEmpty
                ? Center(child: Text(campaignProvider.errorMessage, style: const TextStyle(color: Colors.red))) // ⚠️ Error Message
                : campaignProvider.campaigns.isEmpty
                ? Center(child: Row(spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign, size: 40, color: theme.error,),
                    Text("No campaigns found", style: textTheme.labelMedium?.copyWith(color: theme.error),)
                  ],
                )) // ✅ Empty state
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // ✅ Ensure scroll is enabled for refresh
              itemCount: campaignProvider.campaigns.length,
              itemBuilder: (context, index) {
                final campaign = campaignProvider.campaigns.reversed.toList()[index];
                double progress = (campaign['viewers'] != null && campaign['quantity'] != 0)
                    ? (campaign['viewers'].length >= campaign['quantity'] ? 1.0 : campaign['viewers'].length / campaign['quantity'])
                    : 0;


                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  color: theme.background,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child:  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(spacing: 10,
                      children: [
                        (campaign['campaignImg'] != '')
                            ? (campaign['selectedOption'] == 'Subscribers')
                            ? Container(
                          width: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.onPrimaryContainer, width: 1.0),
                          ),
                          child: ClipOval(
                            child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', 60, 60)
                          ),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Ui.networkImage(context, "${campaign['campaignImg']}", 'assets/ico/image_loading.png', 80, 55)
                        ) : Image.asset('assets/ico/image_loading.png',
                            width: 75, height: 50, color: theme.onPrimaryContainer),


                        Expanded(
                          child: Column(spacing: 7,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start, // Left align everything
                            children: [

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(campaign['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.displaySmall?.
                                    copyWith(fontSize: 14, height: 0.8, fontWeight: FontWeight.bold, color: theme.onPrimaryContainer,
                                      ),),
                                  ),

                                  campaign['status']=="Completed"?
                      // Completed Campaigns Menu Actions
                                  getDefaultDotMenu(context,
                                    [
                              // Details Button
                                      {"label": "Details", "icon": Icons.visibility, "value": "details", "onTap": (){

                                        if (internetProvider.isConnected) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> CampaignDetails(videoUrl: campaign['videoUrl'], videoTitle: campaign['title'],
                                          progress: progress, campaignImg: campaign['campaignImg'], selectedOption: campaign['selectedOption'], quantity: campaign['quantity'], viewers: campaign['viewers'].length, status: campaign['status'],
                                          social: campaign['social'], watchTime: campaign['watchTime'], created: campaign['createdAt'], completedAt: campaign['completedAt'],
                                            campaignCost: campaign['campaignCost'], campaignId: campaign['_id'])));
                                        } else {
                                          AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
                                        }
                                        },},
                              // Recreate Button
                                      {"label": "Recreate", "icon": Icons.settings_backup_restore, "value": "recreate", "onTap": () async{
                                        if (internetProvider.isConnected) {
                                          await reCreateCampaign(
                                            context: context,
                                            title: campaign['title']!,
                                            videoUrl: campaign['videoUrl']!,
                                            watchTime: (campaign['social']=="YouTube")?campaign['watchTime']:0,
                                            quantity: campaign['quantity'],
                                            selectedOption: campaign['selectedOption'],
                                            campaignImg: campaign['campaignImg'],
                                            social: campaign['social'],
                                            catagory: campaign["catagory"],
                                          );
                                        } else {
                                          AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
                                        }
                                      },},
                              // Delete Button
                                      {"label": "Delete", "icon": Icons.delete, "value": "delete", "onTap": (){

                                        if (internetProvider.isConnected) {
                                        showDialog(context: context,
                                          builder: (BuildContext context) {
                                            // pop class import from pop_box.dart
                                            return pop.backAlert(context: context,icon: Icons.delete, title: 'Confirm Delete',
                                                bodyTxt:'Are you sure you want to delete this campaign? cannot be undone.',
                                                confirm: 'Delete', onConfirm: (){CampaignsAction.deleteCompletedCampaign(context, campaign['_id']);} );
                                          },
                                        );
                                        } else {AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);}
                                      },},
                                    ],
                                  ):

                      // Processing / Paused Campaigns Menu Actions
                                  getDefaultDotMenu(context,
                                    [
                              // Details Button
                                      {"label": "Details", "icon": Icons.visibility, "value": "details", "onTap": (){

                                        if (internetProvider.isConnected) {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> CampaignDetails(videoUrl: campaign['videoUrl'], videoTitle: campaign['title'],
                                          progress: progress, campaignImg: campaign['campaignImg'], selectedOption: campaign['selectedOption'], quantity: campaign['quantity'], viewers: campaign['viewers'].length, status: campaign['status'],
                                          social: campaign['social'], watchTime: campaign['watchTime'], created: campaign['createdAt'], completedAt: campaign['completedAt'],
                                          campaignCost: campaign['campaignCost'], campaignId: campaign['_id'],)));
                                        } else {AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);}
                                        },},
                               // Paused/Active Button
                                      {"label": campaign['status']=="Processing"?"Pause":"Active",
                                        "icon":campaign['status']=="Processing"?Icons.pause_circle:Icons.campaign, "value": "pause", "onTap": () {

                                        if (internetProvider.isConnected) {
                                        if(campaign['status']=="Processing"){
                                          CampaignsAction.pauseCampaign(context, campaign['_id']);
                                        }else{
                                          CampaignsAction.resumeCampaign(context, campaign['_id']);
                                        }
                                        } else {AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);}
                                      },},
                                    ],
                                  )
                                ],
                              ),


                              // Progress Bar should touch the left side
                              Row(mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Ui.progressBar(progress, "", 4, 8),
                                  ),
                                ],
                              ),

                              Container(margin: const EdgeInsets.only(left: 11),
                                child: Row(spacing: 5,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(spacing: 3, children: [
                                      (campaign['social']=="YouTube")?Image.asset('assets/ico/youtube_icon.webp', width: 17,):
                                      (campaign['social']=="TikTok")?Image.asset('assets/ico/tiktok_icon.webp', width: 17,)
                                      :Image.asset('assets/ico/instagram_icon.webp', width: 17,),
                                      Text("${campaign['selectedOption']}", maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.displaySmall?.copyWith(fontSize: 12),),
                                      Text('${campaign['quantity']} / ${campaign['viewers'] != null ? campaign['viewers'].length : 0}', style: textTheme.displaySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w800),),
                                      (campaign['status']=="Completed")?Icon(Icons.check_circle_rounded, color: Colors.green, size: 15,):SizedBox(),
                                    ],),

                                    Container(
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: (campaign['status']=="Completed")? Colors.green.shade500: (campaign['status']=="Processing") ? Colors.yellow.shade200 : Colors.red.shade400,
                                        borderRadius: BorderRadius.circular(3)
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                                      child: Text("${campaign['status']}", style: textTheme.displaySmall?.copyWith(fontSize: 10, color: (campaign['status']=="Processing")? Colors.black: Colors.white, fontWeight: FontWeight.bold),),
                                    )
                                ],),
                              )
                            ],
                          ),
                        ),
                      ],),
                  ) // End Container
                );
              },
            ),
          );
        },
      ),




      // 🟢 Bottom Navigation Button
      bottomNavigationBar: Container(color: theme.primaryFixed,
        child: Container(
          margin: const EdgeInsets.only(bottom: 15, left: 70, right: 70),
          child: MyButton(
            txt: 'Add Campaign',
            onClick: () {
              Ui.Add_campaigns_pop(
                context,
                'Select Social Campaign',
                SizedBox(
                  width: 420,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Ui.DropdownManu(context, youtube, _selectedOption, 'YouTube', _onDropdownChanged),
                        Ui.lightLine(),
                        Ui.DropdownManu(context, tiktok, _selectedOption, 'TikTok', _onDropdownChanged),
                        Ui.lightLine(),
                        Ui.DropdownManu(context, instagram, _selectedOption, 'Instagram', _onDropdownChanged),
                        // Ui.lightLine(),
                        // Ui.DropdownManu(context, webvisit, _selectedOption, 'Website SEO & Visitors', _onDropdownChanged),
                      ],
                    ),
                  ),
                ),
              );
            },
            ico: Icons.add,
            icoSize: 23,
            txtSpace: 10,
            shadowColor: theme.onPrimaryContainer,
            borderLineOn: true,
            borderColor: theme.secondary,
            borderLineSize: 1,
            txtColor: theme.onPrimaryContainer,
            borderRadius: 20,
            bgColor: theme.surfaceDim,
          ),
        ),
      ),
    );
  }
}


