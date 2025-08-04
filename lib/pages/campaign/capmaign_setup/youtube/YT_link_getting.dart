import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../screen/home.dart';
import '../../../../server_model/provider/campaign_api.dart';
import '../../../../ui/button.dart';
import '../../../../ui/flash_message.dart';
import '../../../../ui/bg_box.dart';
import '../../../../ui/pop_alert.dart';
import '../../../../ui/ui_helper.dart';
import 'comment_page.dart';
import 'likes_page.dart';
import 'subscribers_page.dart';
import 'watchTime_page.dart';

class YT_LinkGetting extends StatefulWidget {
  // getting page Data from select_list_data.dart
  String? goPage;
  YT_LinkGetting({super.key, required this.goPage});

  @override
  State<YT_LinkGetting> createState() => _YT_LinkGettingState();
}
class _YT_LinkGettingState extends State<YT_LinkGetting> {
  //All variables define
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  final String _apiKey = "AIzaSyAJDa0-jn94LvFzvEvYPTQgRWQ98-JoT1o";
  bool _loading = false;
  String? _videoId;
  String? _videoTitle;
  String? _channelTitle;
  String? _channelProfileImage;
  String? _videoThumbnail;
  YoutubePlayerController? _youtubeController;
  String? _onPage;
  String? _videoLink;

// getting page data store in variable
  @override
  void initState() {super.initState();
    _onPage = widget.goPage;}

 // Main Function Link Analyze
  Future<void> analyzeLink(BuildContext context, String link, {bool checkForm = true}) async {
    if (checkForm && !_formKey.currentState!.validate()) {
      return;
    }
    _loading = true;
    setState(() {
      _videoLink = link;
    });

    try {
      // Extract video ID from the YouTube link
      _videoId = extractVideoId(link);
      if (_videoId == null) {
        showError("Invalid or unsupported YouTube link.");
        return;
      }

      // Fetch video details
      final videoUrl = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=$_videoId&key=$_apiKey";
      final videoResponse = await http.get(Uri.parse(videoUrl));

      if (videoResponse.statusCode != 200) {
        showError("Failed to fetch video details.");
        return;
      }

      final videoData = json.decode(videoResponse.body);
      if (videoData['items'].isEmpty) {
        showError("No video found for the provided link.");
        return;
      }

      final snippet = videoData['items'][0]['snippet'];
      setState(() {
        _videoTitle = snippet['title'];
        _videoThumbnail = snippet['thumbnails']['high']['url'];
        _channelTitle = snippet['channelTitle'];

        // Initialize YouTube player
        _youtubeController = YoutubePlayerController(
          initialVideoId: _videoId!,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false, loop: true),
        );
      });

      // Fetch channel details
      final channelId = snippet['channelId'];
      final channelUrl = "https://www.googleapis.com/youtube/v3/channels?part=snippet&id=$channelId&key=$_apiKey";
      final channelResponse = await http.get(Uri.parse(channelUrl));

      if (channelResponse.statusCode != 200) {
        showError("Failed to fetch channel details.");
        return;
      }

      final channelData = json.decode(channelResponse.body);
      if (channelData['items'].isEmpty) {
        showError("No channel found for the video.");
        return;
      }

      setState(() {
        _channelProfileImage = channelData['items'][0]['snippet']['thumbnails']['default']['url'];
      });
    } on SocketException {
      showError("No Internet Connection, Network unavailable, or Connection timed out");
    } on HttpException {
      showError("Couldn't fetch data from server");
    } on FormatException {
      showError("Invalid response format");
    } catch (e) {
      showError("An error occurred: Couldn't fetch data from server");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  // getting link check/Path Setup
  String? extractVideoId(String link) {
    final uri = Uri.tryParse(link);
    if (uri == null) return null;
    // Youtu.be link setup
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;}
     // For YouTube Shorts
    if (uri.pathSegments.contains('shorts')) {
      return uri.pathSegments.last;}
    return uri.queryParameters['v'];}

  // show error SnackBar include from flash_message.dart
  void showError(String message) {
    AlertMessage.errorMsg(context, message, 'Opps !');
  }

  // Check selected Page to Redirect Page
   _goToPage(checkPage){
    // Check Data Safe send
     if(_youtubeController != null && _channelProfileImage != null && _channelTitle != null &&
         _videoId != null && _videoThumbnail != null && _videoTitle != null &&
         _videoLink != null){
       // Subscribe page
       if (checkPage == 'Subscribers') {
         return SubscribePage(
           youtubeController: _youtubeController, channelProfileImage: _channelProfileImage, channelTitle: _channelTitle,
           videoId: _videoId, videoThumbnail: _videoThumbnail, videoTitle: _videoTitle, videoLink: _videoLink,);}

       // WatchVideo page
       else if (checkPage == 'Viewers') {
         return WatchtimePage(
           youtubeController: _youtubeController, channelProfileImage: _channelProfileImage, channelTitle: _channelTitle,
           videoId: _videoId, videoThumbnail: _videoThumbnail, videoTitle: _videoTitle, videoLink: _videoLink,);}

       // Likes page
       else if (checkPage == 'Likes') {
         return LikesPage(
           youtubeController: _youtubeController, channelProfileImage: _channelProfileImage, channelTitle: _channelTitle,
           videoId: _videoId, videoThumbnail: _videoThumbnail, videoTitle: _videoTitle,  videoLink: _videoLink,);}

       else if (checkPage == 'Comments') {
         return CommentPage(
           youtubeController: _youtubeController, channelProfileImage: _channelProfileImage, channelTitle: _channelTitle,
           videoId: _videoId, videoThumbnail: _videoThumbnail, videoTitle: _videoTitle,  videoLink: _videoLink,);}

       else {
         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
       }
     }else{
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
     }
  }

  @override
  void dispose() {
   _youtubeController?.dispose();
   super.dispose();}

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    final campaignProvider = Provider.of<CampaignProvider>(context);
    final campaigns = campaignProvider.campaigns;

    List<Map<String, dynamic>> uniqueCampaigns = [];
    Set<String> seenUrls = {};
    for (var campaign in campaigns.reversed) {
      if (campaign['social'] == 'YouTube' && !seenUrls.contains(campaign['videoUrl'])) {
        seenUrls.add(campaign['videoUrl']);
        uniqueCampaigns.add(campaign);
        if (uniqueCampaigns.length >= 8) break; // only latest 8 TikTok videos
      }
    }


    return WillPopScope( // Back button to show pop alert confirm
        onWillPop: ()async{
      return await  showDialog(context: context,
        builder: (BuildContext context) {
          // pop class import from pop_box.dart
          return pop.backAlert(context: context, bodyTxt:'Are you sure you want to exit? your youtube URL will be lost.');
          },
      ) ?? false;},
    child: Scaffold(backgroundColor: theme.primaryFixed,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('YouTube $_onPage'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,),
      ),
      body: Stack(children: [
          // Main content getting link
          if (_loading || _videoTitle == null)
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                // First Box Form Link Getting
                BgBox(
                  margin: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 0),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  allRaduis: 5, wth: double.infinity,
                  child: Form(key: _formKey,
                    child: Column(mainAxisSize: MainAxisSize.min,

                      // YT link getting Input import form ui_helper.dart
                      children: [Ui.input(context, _linkController, 'Video URL', 'https://youtube.com/BhosiIBOc9c',
                          TextInputType.url, (value) { // input validiter fun
                            if (value == null || value.isEmpty) {
                              return 'Enter the youtube video URL.';}
                            final RegExp youtubeRegex = RegExp(r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.+$',);
                            if (!youtubeRegex.hasMatch(value)) {
                              return 'Please enter a valid YouTube URL';}
                            return null;
                          },),
                        const SizedBox(height: 18),

                      // loading true to button hide and show loading
                      (_loading)?const Center(child: Text('Checking....'),)
                      :SizedBox(width: double.infinity,

                       // continue button call function YT link searching
                          child: MyButton(txt: 'Continue', fontfamily: '3rdRoboto',
                            bgColor: theme.surfaceDim, shadowOn: true, borderLineOn: true,
                            borderRadius: 10, txtSize: 17, txtColor: theme.onPrimaryContainer,
                            onClick: () => analyzeLink(context, _linkController.text.trim(), checkForm: true),
                          ),
                        ),
                      ],),
                  ),
                ),
                const SizedBox(height: 10),

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
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 15,
                                      childAspectRatio: 13 / 9,
                                    ),
                                    itemCount: uniqueCampaigns.length, // ✅ Sirf unique campaigns
                                    itemBuilder: (context, index) {
                                      final campaign = uniqueCampaigns[index];

                                      return InkWell(
                                        onTap: () async {
                                         await analyzeLink(context, campaign['videoUrl'], checkForm: false);
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
                                                                  ? Icons.thumb_up
                                                                  : (campaign['selectedOption'] == 'Comments')
                                                                  ? Icons.comment
                                                                  : (campaign['selectedOption'] == 'WatchTime')
                                                                  ? Icons.ondemand_video_rounded
                                                                  : Icons.subscriptions,
                                                              size: 10,
                                                              color: (campaign['selectedOption'] == 'Likes')
                                                                  ? Colors.blueAccent
                                                                  : (campaign['selectedOption'] == 'Comments')
                                                                  ? Colors.white
                                                                  : Colors.red,
                                                            ),
                                                            Text(
                                                              campaign['selectedOption'],
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w800,
                                                                fontSize: 10,
                                                                color: (campaign['selectedOption'] == 'Likes')
                                                                    ? Colors.blueAccent
                                                                    : (campaign['selectedOption'] == 'Comments')
                                                                    ? Colors.white
                                                                    : Colors.red,
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
                  child: Ui.bottomBar(context, 'How to get link: Open your video on youtube -> share button -> copy link',
                    'ico/youtube_icon.webp', 'Open YT', 'https://www.youtube.com',),
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
          if (!_loading && _videoTitle != null && _channelTitle != null && _channelProfileImage != null
              && _videoThumbnail != null && _youtubeController != null && _videoLink != null)
            Positioned.fill(
              // Navigate to the appropriate page after loading
              child: _goToPage(widget.goPage),
            ),
        ],),
    ));
  }
}