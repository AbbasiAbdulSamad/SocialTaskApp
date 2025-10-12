import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../config/config.dart';
import '../../../../screen/home.dart';
import '../../../../server_model/provider/campaign_api.dart';
import '../../../../ui/button.dart';
import '../../../../ui/flash_message.dart';
import '../../../../ui/bg_box.dart';
import '../../../../ui/pop_alert.dart';
import '../../../../ui/ui_helper.dart';

class facebook_LinkGetting extends StatefulWidget {
  // getting page Data from select_list_data.dart
  String? goPage;
  facebook_LinkGetting({super.key, required this.goPage});

  @override
  State<facebook_LinkGetting> createState() => _facebook_LinkGettingState();
}
class _facebook_LinkGettingState extends State<facebook_LinkGetting> {
  //All variables define
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  bool _loading = false;
  String? _onPage;
  String? _videoLink;

  String? _linkedinName;
  String? _linkedinPic;


// getting page data store in variable
  @override
  void initState() {super.initState();
  _onPage = widget.goPage;
  }

  Future<void> _analyzeInstagramLink(String linkedinProfile) async {
    setState(() => _loading = true);
    
  }




  // Check selected Page to Redirect Page
  _goToPage(checkPage){
    // Check Data Safe send
    // if(thumbnailUrl != null && authorName != null && authorProfile != null && _videoLink != null){
    //   // Subscribe page
    //   if (checkPage == 'Followers') {
    //     return Instagram_followers(taskLink: _videoLink, accountName: authorName,
    //       accountProfile: authorProfile, thumbnailUrl: thumbnailUrl, videoTitle: videoTitle,
    //       videoLikes: videoLikes, videoViews: videoViews, Followers: Followers, isReel: isReel,);}
    //
    //   // // Likes page
    //   else if (checkPage == 'Likes') {
    //     return Instagram_likes(taskLink: _videoLink, accountName: authorName,
    //         accountProfile: authorProfile, thumbnailUrl: thumbnailUrl, videoTitle: videoTitle,
    //         videoLikes: videoLikes, videoViews: videoViews, Followers: Followers, isReel: isReel,);}
    //
    //   // // Comments page
    //   else if (checkPage == 'Comments') {
    //     return Instagram_comments(taskLink: _videoLink, accountName: authorName,
    //       accountProfile: authorProfile, thumbnailUrl: thumbnailUrl, videoTitle: videoTitle,
    //       videoLikes: videoLikes, videoViews: videoViews, Followers: Followers, isReel: isReel,);}
    //   else {
    //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
    //   }
    // }else{
    //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
    // }
  }

  String? validateLinkedInUrl(String? value) {
    final RegExp validUrlRegex = RegExp(r'^(https:\/\/(www\.)?facebook\.com\/in\/[A-Za-z0-9_-]+\/?)$');

    if (value == null || value.trim().isEmpty) {
      return 'Enter your LinkedIn profile URL.';
    }

    final trimmedValue = value.trim();

    if (!validUrlRegex.hasMatch(trimmedValue)) {
      return 'Invalid LinkedIn Profile URL.';
    }

    return null;
  }


  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();}

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    final campaignProvider = Provider.of<CampaignProvider>(context);
    final campaigns = campaignProvider.campaigns;

    List<Map<String, dynamic>> uniqueCampaigns = [];
    Set<String> seenUrls = {};

    for (var campaign in campaigns.reversed) {
      if (campaign['social'] == 'Instagram' && !seenUrls.contains(campaign['videoUrl'])) {
        seenUrls.add(campaign['videoUrl']);
        uniqueCampaigns.add(campaign);
        if (uniqueCampaigns.length >= 6) break; // only latest 8 TikTok videos
      }
    }


    return WillPopScope( // Back button to show pop alert confirm
        onWillPop: ()async{
          return await  showDialog(context: context,
            builder: (BuildContext context) {
              // pop class import from pop_box.dart
              return pop.backAlert(context: context, bodyTxt:'Are you sure you want to exit? your TikTok URL will be lost.');
            },
          ) ?? false;},
        child: Scaffold(backgroundColor: theme.primaryFixed,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text('Facebook $_onPage', style: TextStyle(fontSize: 16),),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: theme.surfaceTint,
              statusBarIconBrightness: Brightness.light,),
          ),
          body: Stack(children: [
            // Main content getting link
            if (_loading || _linkedinPic == null)
              Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // First Box Form Link Getting
                  BgBox(
                    margin: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 10),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    allRaduis: 5, wth: double.infinity,
                    child: Form(key: _formKey,
                      child: Column(mainAxisSize: MainAxisSize.min,

                        // YT link getting Input import form ui_helper.dart
                        children: [Ui.input(context, _linkController, 'Reel URL', 'https://instagram.com/reel/...',
                          TextInputType.url, validateLinkedInUrl,),
                          const SizedBox(height: 18),

                          // loading true to button hide and show loading
                          (_loading)?const Center(child: Text('Checking....'),)
                              :SizedBox(width: double.infinity,

                            // continue button call function YT link searching
                            child: MyButton(txt: 'Continue', fontfamily: '3rdRoboto',
                              bgColor: theme.surfaceDim, shadowOn: true, borderLineOn: true,
                              borderRadius: 10, txtSize: 17, txtColor: theme.onPrimaryContainer,
                                onClick: () {
                                  if (_formKey.currentState!.validate()) {
                                    _analyzeInstagramLink("$_linkController");
                                  }
                              },
                            ),
                          ),
                        ],),
                    ),
                  ),

                  // 2nd center Box
                  Expanded(
                    child: BgBox(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      wth: double.infinity, allRaduis: 5,
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,

                          // svg recent videos logo and name
                          children: [
                            SvgPicture.asset('assets/ico/back_in_time.svg', width: 20, color: theme.onPrimaryContainer),
                            const SizedBox(width: 5),
                            Text('Recent Videos', style: Theme.of(context).textTheme.labelSmall,),
                            const SizedBox(width: 5),
                            Expanded(child: Divider(color: theme.onPrimaryContainer, thickness: 1)),
                          ],),

                        // recent videos here
                        const SizedBox(height: 15),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: campaigns.isEmpty
                                    ? const Row(mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(Icons.video_library_sharp, size: 18,),
                                    Text("No Recent Video History",),
                                  ],
                                ): Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 13 / 15,
                                    ),
                                    itemCount: uniqueCampaigns.length, // ✅ Sirf unique campaigns
                                    itemBuilder: (context, index) {
                                      final campaign = uniqueCampaigns[index];

                                      return InkWell(
                                        onTap: () async {
                                          setState((){
                                            _loading = true;
                                            _videoLink = campaign['videoUrl'];
                                          });
                                          await _analyzeInstagramLink(_videoLink!);
                                        },
                                        child: Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 0.5),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      Ui.networkImage(context, campaign['campaignImg'], 'assets/ico/image_loading.png', double.infinity, double.infinity),
                                                      Positioned(
                                                        bottom: 1,
                                                        left: 5,
                                                        child: Row( spacing: 2,
                                                          children: [
                                                            Icon(
                                                              (campaign['selectedOption'] == 'Likes')
                                                                  ? Icons.favorite
                                                                  : (campaign['selectedOption'] == 'Comments')
                                                                  ? Icons.comment
                                                                  : (campaign['selectedOption'] == 'Favorites')
                                                                  ? Icons.bookmark
                                                                  : Icons.supervised_user_circle_rounded,
                                                              size: 10,
                                                              color: (campaign['selectedOption'] == 'Likes')
                                                                  ? Colors.pinkAccent
                                                                  : (campaign['selectedOption'] == 'Favorites')
                                                                  ? Colors.yellowAccent
                                                                  : Colors.white,
                                                            ),
                                                            Text(
                                                              campaign['selectedOption'],
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w800,
                                                                fontSize: 10,
                                                                color: (campaign['selectedOption'] == 'Likes')
                                                                    ? Colors.pinkAccent
                                                                    : (campaign['selectedOption'] == 'Favorites')
                                                                    ? Colors.yellowAccent
                                                                    : Colors.white,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                                                  child: Text(
                                                    campaign['title'],
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],),
                    ),
                  ),

                  // last Box bottom instruction Bar
                  BgBox(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    wth: double.infinity,
                    allRaduis: 5,
                    // bottom bar include ui_helper.dart
                    child: Ui.bottomBar(context, 'Accepted Link: Only Linkedin Profile are supported',
                      'ico/linkedin_icon.webp', 'Open Linkedin', 'https://www.facebook.com',),
                  ),
                ],),

            // Loading indicator (only visible when loading is true)
            if (_loading)
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3.0,),
                  ),
                ),
              ),

            // Page redirection (Will Show After Loading is Complete)
            // if (!_loading && _linkedinPic != null)
            //   Positioned.fill(
            //     // Navigate to the appropriate page after loading
            //     child: _goToPage(widget.goPage),
            //   ),
          ],),
        ));
  }
}