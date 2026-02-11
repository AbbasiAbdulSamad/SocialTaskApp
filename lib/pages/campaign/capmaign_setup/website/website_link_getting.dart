import 'dart:async';
import 'dart:io';
import 'package:app/pages/campaign/capmaign_setup/website/web_visitors.dart';
import 'package:app/screen/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../../../server_model/provider/campaign_api.dart';
import '../../../../../ui/button.dart';
import '../../../../../ui/flash_message.dart';
import '../../../../../ui/bg_box.dart';
import '../../../../../ui/pop_alert.dart';
import '../../../../../ui/ui_helper.dart';

class Website_LinkGetting extends StatefulWidget {
  // getting page Data from select_list_data.dart
  String? goPage;
  Website_LinkGetting({super.key, required this.goPage});

  @override
  State<Website_LinkGetting> createState() => _Website_LinkGettingState();
}
class _Website_LinkGettingState extends State<Website_LinkGetting> {
  //All variables define
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  bool _loading = false;
  String? _onPage;
  String? _webLink;

  String? webIcon;
  String? webTitle;

// getting page data store in variable
  @override
  void initState() {super.initState();
  _onPage = widget.goPage;
  }

  Future<void> _analyzeWebsite(String videoUrl) async{
    setState(() => _loading = true);

    print(videoUrl);
    try {
     await fetchWebsiteMeta(videoUrl);

     debugPrint(webTitle);
     debugPrint(webIcon);
    } catch (e) {
      setState(() => _loading = false);
      print("❌ API Call Error: $e");
      AlertMessage.errorMsg(context, "Invalid or unsupported Instagram link.", "Opps!");
    }
  }


  Future<void> fetchWebsiteMeta(String inputUrl) async {
    try {
      setState(() => _loading = true);

      // Normalize URL (add https:// if missing)
      String url = inputUrl.startsWith('https://') ? inputUrl : 'https://$inputUrl';
      final uri = Uri.parse(url);

      // HTTP GET with timeout
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      // Website reachable check
      if (response.statusCode != 200) {
        throw HttpException('Website returned status code ${response.statusCode}');
      }

      final html = response.body;

      // -------- HTML content validation ----------
      final hasTitle = RegExp(r'<title>.*?</title>', caseSensitive: false, dotAll: true)
          .hasMatch(html);
      final hasMeta = RegExp(r'<meta[^>]+', caseSensitive: false).hasMatch(html);

      if (!hasTitle && !hasMeta) {
        setState(() => _loading = false);
        AlertMessage.errorMsg(
          context,
          'Website not found or does not contain valid content.',
          'Website Not Found',
        );
        return;
      }

      // -------- TITLE ----------
      final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true)
          .firstMatch(html);
      final String? title = titleMatch?.group(1)?.trim();

      // -------- ARTICLE IMAGE ----------
      String? imageUrl;
      final ogImageMatch = RegExp(
        r'''<meta[^>]+property=["']og:image["'][^>]+content=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(html);
      final twitterImageMatch = RegExp(
        r'''<meta[^>]+name=["']twitter:image["'][^>]+content=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(html);
      final normalImageMatch = RegExp(
        r'''<meta[^>]+name=["']image["'][^>]+content=["']([^"']+)["']''',
        caseSensitive: false,
      ).firstMatch(html);

      imageUrl = ogImageMatch?.group(1) ??
          twitterImageMatch?.group(1) ??
          normalImageMatch?.group(1);

      if (imageUrl != null && imageUrl.startsWith('/')) {
        imageUrl = '${uri.scheme}://${uri.host}$imageUrl';
      }

      // -------- ICON (fallback) ----------
      String? iconUrl;
      if (imageUrl == null) {
        final iconMatch = RegExp(
          r'''<link[^>]+rel=["'](?:shortcut icon|icon)["'][^>]*href=["']([^"']+)["']''',
          caseSensitive: false,
        ).firstMatch(html);

        if (iconMatch != null) {
          iconUrl = iconMatch.group(1);
          if (iconUrl != null && iconUrl.startsWith('/')) {
            iconUrl = '${uri.scheme}://${uri.host}$iconUrl';
          }
        } else {
          iconUrl = '${uri.scheme}://${uri.host}/favicon.ico';
        }
      }

      // -------- Update State ----------
      setState(() {
        webTitle = title ?? 'website';
        webIcon = imageUrl ?? iconUrl;
        _webLink = url;
        _loading = false;
      });
    }

    // ❌ No Internet / DNS / Domain does not exist
    on SocketException catch (e) {
      setState(() => _loading = false);
      final msg = e.message.toLowerCase();
      if (msg.contains('failed host lookup')) {
        AlertMessage.errorMsg(
          context,
          'Website does not exist or domain could not be found.',
          'Invalid Domain',
        );
      } else {
        AlertMessage.errorMsg(
          context,
          'No internet connection. Please check your network.',
          'Network Error',
        );
      }
    }

    // ❌ Slow Internet / Timeout
    on TimeoutException {
      setState(() => _loading = false);
      AlertMessage.errorMsg(
        context,
        'Request timed out. Your internet may be slow.',
        'Try Again',
      );
    }

    // ❌ Website returned error status
    on HttpException catch (e) {
      setState(() => _loading = false);
      AlertMessage.errorMsg(
        context,
        'Website is not reachable. ${e.message}',
        'Website Error',
      );
    }

    // ❌ Invalid URL / DNS fail
    on http.ClientException {
      setState(() => _loading = false);
      AlertMessage.errorMsg(
        context,
        'Invalid website address or DNS error.',
        'Invalid URL',
      );
    }

    // ❌ Cloudflare / access blocked
    on Exception catch (e) {
      setState(() => _loading = false);
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('cloudflare') ||
          errorMessage.contains('access denied') ||
          errorMessage.contains('captcha')) {
        AlertMessage.errorMsg(
          context,
          'This website is protected by Cloudflare and cannot be accessed.',
          'Access Blocked',
        );
      } else {
        AlertMessage.errorMsg(
          context,
          'Something went wrong while fetching website details.\n${e.toString()}',
          'Error',
        );
      }
    }

    // ❌ Unknown Error
    catch (e) {
      setState(() => _loading = false);
      AlertMessage.errorMsg(
        context,
        'Something went wrong while fetching website details.',
        'Error',
      );
    }
  }






  // Check selected Page to Redirect Page
  _goToPage(checkPage){
    // Check Data Safe send
    if(webIcon != null && webTitle != null && _webLink != null){
      if (checkPage == 'Visitors') {
        return Web_visitors(webLink: _webLink, webIcon: webIcon, webTitle: webTitle,);}


      else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
      }
    }else{
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Home(onPage: 3)), (route)=> false);
    }
  }

  String? validateWebsiteUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your website or article URL.';
    }

    String url = value.trim();

    // Length limit
    if (url.length > 500) {
      return 'URL length must be 500 characters or less.';
    }

    // Block explicit http
    if (url.startsWith('http://')) {
      return 'Website is not supported. Use HTTPS only.';
    }

    // 👉 If scheme missing, prepend https://
    if (!url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        uri.host.isEmpty ||
        uri.host.split('.').length < 2) {
      return 'Not supported. Please enter a valid personal website URL.';
    }

    final String hostLower = uri.host.toLowerCase();

    // Block localhost & IP addresses
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (hostLower == 'localhost' || ipRegex.hasMatch(hostLower)) {
      return 'IP addresses or localhost are not supported.';
    }

    // 🔒 Block educational / government domains (any level)
    if (hostLower.contains('.edu.') ||
        hostLower.endsWith('.edu') ||
        hostLower.contains('.gov.') ||
        hostLower.endsWith('.gov') ||
        hostLower.contains('.mil.') ||
        hostLower.endsWith('.mil') ||
        hostLower.contains('.gob.') ||
        hostLower.endsWith('.gob')) {
      return 'Educational and government websites are not supported.';
    }

    // 🚫 Block specific domains (social + adult + shorteners)
    final List<String> blockedDomains = [
      'facebook.com', 'fb.com', 'instagram.com', 'twitter.com', 'x.com',
      'tiktok.com', 'youtube.com', 'youtu.be', 'linkedin.com',
      'snapchat.com', 'pinterest.com', 'reddit.com',
      'whatsapp.com', 'telegram.org',
      'google.com', 'bing.com',
      'pornhub.com', 'xvideos.com', 'xnxx.com', 'redtube.com',
      'youporn.com', 'xhamster.com', 'spankbang.com',
      'tube8.com', 'brazzers.com', 'onlyfans.com',
      'fansly.com', 'manyvids.com', 'adultfriendfinder.com',
      'bit.ly', 'tinyurl.com', 'goo.gl', 't.co', 'shorturl.at',
      'rebrand.ly', 'cutt.ly', 'is.gd', 'buff.ly', 'ow.ly',
      'rb.gy', 'adf.ly', 'soo.gd', 'shorte.st', 'mcaf.ee',
    ];

    for (final domain in blockedDomains) {
      if (hostLower == domain || hostLower.endsWith('.$domain')) {
        return 'Not supported. Enter your personal website URL.';
      }
    }

    return null; // ✅ Valid
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
      if (campaign['social'] == 'Website' && !seenUrls.contains(campaign['videoUrl'])) {
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
              return pop.backAlert(context: context, bodyTxt:'Are you sure you want to exit? your website URL will be lost.');
            },
          ) ?? false;},
        child: Scaffold(backgroundColor: theme.primaryFixed,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text('Website $_onPage', style: const TextStyle(fontSize: 18),),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: theme.surfaceTint,
              statusBarIconBrightness: Brightness.light,),
          ),
          body: Stack(children: [
            // Main content getting link
            if (_loading || webTitle == null)
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
                        children: [Ui.input(context, _linkController, 'Web URL', 'https://www.example.com/',
                          TextInputType.url, validateWebsiteUrl,),
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
                                  setState(() {
                                    _loading = true;
                                  });
                                  _analyzeWebsite(_linkController.text.trim());
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
                            Text('Recent Websites', style: Theme.of(context).textTheme.labelSmall,),
                            const SizedBox(width: 5),
                            Expanded(child: Divider(color: theme.onPrimaryContainer, thickness: 1)),
                          ],),

                        // recent videos here
                        const SizedBox(height: 15),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: (uniqueCampaigns.isEmpty)
                                    ? const Row(mainAxisAlignment: MainAxisAlignment.center,
                                  spacing: 8,
                                  children: [
                                    Icon(CupertinoIcons.globe, size: 18,),
                                    Text("No Website History",),
                                  ],
                                ): Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: ListView.builder(
                                      itemCount: uniqueCampaigns.length,
                                      itemBuilder: (context, index) {
                                        final campaign = uniqueCampaigns[index];

                                        return InkWell(
                                          onTap: () async {
                                            setState(() {
                                              _loading = true;
                                              _webLink = campaign['videoUrl'];
                                            });

                                            await _analyzeWebsite(campaign['videoUrl']);
                                          },
                                          child: BgBox(
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            padding: const EdgeInsets.all(6),
                                            allRaduis: 10,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // 🖼 Image
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Ui.networkImage(context,
                                                    campaign['campaignImg'],
                                                    'assets/ico/web.webp',
                                                    80,
                                                    60,
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                // 📝 TEXT AREA (VERY IMPORTANT)
                                                Expanded(
                                                  child: Column(spacing: 2,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Title
                                                      Text(
                                                        campaign['title'] ?? '',
                                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                            fontSize: 14,
                                                            height: 1.1),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),

                                                      const SizedBox(height: 4),

                                                      // Option row
                                                      Row(
                                                        children: [
                                                           Icon(Icons.link, size: 15, color: theme.onPrimaryContainer,),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              campaign['videoUrl'] ?? '',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w600,
                                                                fontSize: 11,
                                                                color: theme.errorContainer,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
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
                    child: Ui.bottomBar(context, 'Only domain-based websites and article links are accepted.',
                      'ico/web.webp', 'Open Browser', 'https://www.google.com',),
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
            if (!_loading && webTitle != null && webIcon != null)
              _goToPage(widget.goPage),
          ],),
        ));
  }
}