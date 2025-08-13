import 'capmaign_setup/instagram/instagram_link_getting.dart';
import 'capmaign_setup/tiktok/Tiktok_link_getting.dart';
import 'capmaign_setup/webSEO/webSEO_link_getting.dart';
import 'capmaign_setup/youtube/YT_link_getting.dart';

final List<Map<String, dynamic>> youtube = [
  {'name': '🔔 Subscribers', 'page': YT_LinkGetting(goPage: 'Subscribers',)},
  {'name': '🕑 Watch Time', 'page': YT_LinkGetting(goPage: 'Viewers',)},
  {'name': '👍 Likes', 'page': YT_LinkGetting(goPage: 'Likes',)},
  {'name': '💬 Comments', 'page': YT_LinkGetting(goPage: 'Comments',)},
];

final List<Map<String, dynamic>> tiktok = [
  {'name': '👥 Followers', 'page': Tiktok_LinkGetting(goPage: 'Followers',)},
  {'name': '❤️ Likes Video', 'page': Tiktok_LinkGetting(goPage: 'Likes',)},
  {'name': '💬 Comments', 'page': Tiktok_LinkGetting(goPage: 'Comments',)},
  {'name': '🔖 Favorites', 'page': Tiktok_LinkGetting(goPage: 'Favorites',)},
];

final List<Map<String, dynamic>> instagram = [
  {'name': '👥 Followers', 'page': instagram_LinkGetting(goPage: 'Followers',)},
  {'name': '👍 Post Likes', 'page': instagram_LinkGetting(goPage: 'Likes',)},
  {'name': '💬 Comments', 'page': instagram_LinkGetting(goPage: 'Comments',)},
];

// final List<Map<String, dynamic>> facebook = [
//   {'name': 'Public Post Reaction', 'page': FbLinkGetting(goPage: 'Post Reaction',)},
//   {'name': 'Page Likes', 'page': LinkGetting(goPage: '',)},
//   {'name': 'Page Follow', 'page': LinkGetting(goPage: '',)},
//   {'name': 'Group Joining', 'page': LinkGetting(goPage: 'subscribe',)},
// ];

final List<Map<String, dynamic>> webvisit = [
  {'name': 'SEO Website', 'page': WebSEO_LinkGetting(goPage: 'SEO',)},
  {'name': 'Website Visitors', 'page': WebSEO_LinkGetting(goPage: 'Visitors',)},
];
