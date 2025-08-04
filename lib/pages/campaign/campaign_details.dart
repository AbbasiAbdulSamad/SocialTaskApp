import 'dart:convert';

import 'package:app/ui/bg_box.dart';
import 'package:app/ui/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../config/config.dart';
import '../../server_model/functions_helper.dart';

class CampaignDetails extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;
  final String selectedOption;
  final String campaignImg;
  final int quantity;
  final int viewers;
  final int watchTime;
  final int campaignCost;
  final double progress;
  final String social;
  final String status;
  final String created;
  final String? completedAt;
  final String campaignId;
  const CampaignDetails({super.key, required this.videoUrl, required this.videoTitle, required this.selectedOption, required this.campaignImg,
    required this.progress, required this.quantity, required this.viewers, required this.social, required this.status, required this.watchTime,
      required this.campaignCost, required this.created, required this.completedAt, required this.campaignId});

  @override
  State<CampaignDetails> createState() => _CampaignDetailsState();
}

class _CampaignDetailsState extends State<CampaignDetails> {
  late YoutubePlayerController _youtubeController;
  late String createCampaign;
  late String completeCampaign;
  bool isLoadingViewers = true;
  List<Map<String, dynamic>> viewers = [];



  @override
  void initState() {
    super.initState();

    DateTime createdDate = DateTime.parse(widget.created).toLocal();
    createCampaign = DateFormat('dd MMM yyyy, hh:mm a').format(createdDate);

    // ✅ Safe check for null or empty completed date
    if (widget.completedAt != null && widget.completedAt!.trim().isNotEmpty) {
      try {
        DateTime completedDate = DateTime.parse(widget.completedAt!).toLocal();
        completeCampaign = DateFormat('dd MMM yyyy, hh:mm a').format(completedDate);
      } catch (e) {completeCampaign = '••••••••••';}
    } else {completeCampaign = '••••••••••';}
    // YouTube setup
    final String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),);

    loadViewers();
  }

  Future<void> loadViewers() async {
    try {
      final data = await fetchViewers(widget.campaignId);
      setState(() {
        viewers = data;
        isLoadingViewers = false;
      });
    } catch (e) {
      debugPrint("Error loading viewers: $e");
      setState(() {
        isLoadingViewers = false;
      });
    }
  }


  Future<List<Map<String, dynamic>>> fetchViewers(String campaignId) async {
    final token = await Helper.getAuthToken();
    if (token == null) {
      throw Exception("User not authenticated.");
    }

    final response = await http.get(
      Uri.parse('${ApiPoints.campaignsViewers}/$campaignId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['viewers']);
    } else {
      throw Exception("Failed to load viewers: ${response.statusCode}");
    }
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme theme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.primaryFixed,
      appBar: AppBar(
        title: Text('Campaign Details View'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: theme.surfaceTint,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BgBox(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(spacing: 13,
                children: [
                  (widget.social=="YouTube")?
                  Column(
                    children: [
                      YoutubePlayer(controller: _youtubeController),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(widget.videoTitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 16, height: 1.5, fontWeight: FontWeight.bold, color: theme.onPrimaryContainer,),),
                      ),

                      Ui.line(),
                    ],
                  ):InkWell(
                    onTap: ()=> launchUrl(Uri.parse(widget.videoUrl)),
                    child: Stack(
                      children: [
                        Ui.networkImage(context, widget.campaignImg, 'assets/ico/image_loading.png', double.infinity, 400),

                        Positioned(
                          left: 0, right: 0, bottom: 10,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Text(widget.videoTitle, maxLines: 4, overflow: TextOverflow.ellipsis,
                                    style: textTheme.displaySmall?.copyWith(
                                      fontSize: 16, color: Colors.white,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                            left: 0, right: 0, top: 150,
                            child: Image.asset("assets/ico/tiktok_play_icon.webp", width: 60, height: 60,))
                      ],
                    ),
                  ),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    Row(spacing: 5,
                      children: [
                        Image.asset('assets/ico/${(widget.social=="YouTube")?"youtube_icon.webp":"tiktok_icon.webp"}', width: 20,),
                        Text("${widget.social}", maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.displaySmall?.copyWith(fontSize: 14),),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 12,),
                    Row(spacing: 5,
                      children: [
                        Text(widget.selectedOption, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.displaySmall?.copyWith(fontSize: 14),),
                        Text('${widget.quantity} / ${widget.viewers }', style: textTheme.displaySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w800),),
                      ],
                    ),

                      (widget.social=="YouTube")?
                    Row(spacing: 5,
                      children: [
                        Icon(Icons.arrow_forward_ios, size: 12,),
                        SizedBox(width: 8,),
                        Icon(Icons.watch_later, size: 14,),
                        Text("${widget.watchTime}")
                      ],
                    ):SizedBox(),
                  ],),
        
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [Expanded(child: Ui.progressBar(widget.progress, "", 4, 8,),),],),
        
                  Container(margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(spacing: 6,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset('assets/ico/1xTickets.webp', width: 35,),
                            SizedBox(width: 140,),
                            Text("${widget.campaignCost}", style: textTheme.labelMedium?.copyWith(color: theme.errorContainer),),
                          ],),
                        Ui.lightLine(),
        
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 65, alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.green.shade300,
                                  borderRadius: BorderRadius.circular(3)),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              child: Text("Create", style: textTheme.displaySmall?.copyWith(fontSize: 11, color:Colors.black,),),
                            ),
                            Text(createCampaign, style: textTheme.displaySmall,),
                            ],),
                        Ui.lightLine(),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 65, alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: (widget.status=="Completed")? Colors.green.shade500: (widget.status=="Processing") ? Colors.yellow.shade200 : Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(3)
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              child: Text(widget.status, style: textTheme.displaySmall?.copyWith(fontSize: 11, color:(widget.status=="Paused")? Colors.white:Colors.black),),
                            ),
                            Text(completeCampaign, style: textTheme.displaySmall,),
                          ],),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            Text('List of those who completed the task', style: textTheme.displaySmall?.copyWith(fontSize: 16, color: theme.onPrimaryContainer),),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 2),
              height: 1,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: theme.onPrimaryFixed,
                  boxShadow: [BoxShadow(
                      color: theme.onPrimaryFixed,
                      spreadRadius: 1,
                      blurRadius: 12,
                      offset: const Offset(0, 6)
                  )]
              ),),
            SizedBox(height: 15,),

            isLoadingViewers ? Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(color: theme.onPrimaryContainer,)),
            )
                : viewers.isEmpty
                ? const Padding(padding: EdgeInsets.all(20),
              child: Center(child: Text("No viewers found.")),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewers.length,
              itemBuilder: (context, index) {
                final viewer = viewers[index];
                return Card(
                  color: theme.primaryFixedDim,
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                  child: ListTile(
                    minTileHeight: 50,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: theme.onPrimaryContainer, width: 0.5),),
                      child: ClipOval(
                        child: viewer['profile'] != null
                            ? Ui.networkImage(context, viewer['profile'], 'assets/ico/user_profile.webp', 90, 90)
                            : Image.asset('assets/ico/user_profile.webp'),
                      ),
                    ),
                    title: Text(viewer['name'] ?? 'Unknown', style: textTheme.displaySmall?.copyWith(fontSize: 17),),
                  ),
                );
              },
            ),
            SizedBox(height: 50,),
          ],
        ),
      ),
    );
  }
}
