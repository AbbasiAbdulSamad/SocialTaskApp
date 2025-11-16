import 'dart:convert';
import 'package:app/server_model/functions_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/home.dart';
import '../server_model/LocalNotificationManager.dart';
import '../server_model/signout.dart';
import '../ui/button.dart';
import '../ui/flash_message.dart';
import 'api_config.dart';
import 'config.dart';

class Authentication extends StatefulWidget {
   Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
   final FirebaseAuth _auth = FirebaseAuth.instance;

   final GoogleSignIn _googleSignIn = GoogleSignIn();

   bool _loading = false;

   // ✅ Google Sign-In and Authentication with Backend
   Future<UserCredential?> signInWithGoogle(BuildContext context) async {
     if (!mounted) return null;
     setState(() => _loading = true);
     try {
       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
       if (googleUser == null) throw Exception("Google sign-in aborted");

       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
       final credential = GoogleAuthProvider.credential(
         accessToken: googleAuth.accessToken,
         idToken: googleAuth.idToken,
       );

       final UserCredential userCredential = await _auth.signInWithCredential(credential);
       User? user = userCredential.user;

       if (user != null) {
         await user.reload();
         user = FirebaseAuth.instance.currentUser;
         String? token = await user!.getIdToken();
         if (token == null) throw Exception("Failed to get authentication token");

         // ✅ Get FCM token
         String? fcmToken = await FirebaseMessaging.instance.getToken();
         debugPrint("📲 FCM Token: $fcmToken");

         String country = await getUserCountry();
         var prefs = await SharedPreferences.getInstance();
         await prefs.setString('auth_token', token);

         // ✅ Read referral code from SharedPreferences
         String? referralCodeFromPrefs = prefs.getString('pending_referral_code');
         debugPrint('📥 Referral from SharedPreferences: $referralCodeFromPrefs');

         // 🔹 Send Data to Backend with Referral Code
         final response = await http.post(
           Uri.parse(ApiPoints.authentication),
           headers: {
             "Content-Type": "application/json",
             "Authorization": "Bearer $token",
           },
           body: jsonEncode({
             "country": country,
             "fcmToken": fcmToken,
             if (referralCodeFromPrefs != null) "referralCode": referralCodeFromPrefs,
           }),
         );

         final data = jsonDecode(response.body);

         if (response.statusCode == 200 || (response.statusCode == 400 && data["message"] == "User already exists")) {
           debugPrint("✅ Login Successful Country : $country}");


           // ✅ Clear referral after using
           if (referralCodeFromPrefs != null) {
             await prefs.remove('pending_referral_code');
             debugPrint('🗑️ Referral code cleared from SharedPreferences');
           }

           bool userExists = await checkUserExists(context);
           if (!userExists) return null;

           Helper.navigateAndRemove(context, const Home(onPage: 1));

           await LocalNotificationManager.saveNotification(
               title: 'Login Successfully',
               body: '📍$country',
               screenId: "Login"
           );
         } else {
           AlertMessage.errorMsg(context, '${data['message']}', 'Error!');
         }
       }

       return userCredential;
     } catch (e) {
       String errorMessage = SignOut().handleError(e);
       AlertMessage.errorMsg(context, errorMessage, 'Error!');
       return null;
     } finally {
       if (!mounted) return null;
       setState(() => _loading = false);
     }
   }

   // ✅ Function to Get User Country from IP
   Future<String> getUserCountry() async {
     try {
       final response = await http.get(Uri.parse("https://ipinfo.io/json"));
       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         return data["country"] ?? "";
       } else {
         return "";
       }
     } catch (e) {
       debugPrint("❌ Error fetching country: $e");
       return "";
     }
   }

   // ✅ Function to Check if User Exists in Database
   Future<bool> checkUserExists(BuildContext context) async {
     try {
       String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
       if (token == null) return false;

       final response = await http.get(
         Uri.parse(ApiPoints.currentUserData),
         headers: {
           "Authorization": "Bearer $token",
         },
       );

       if (response.statusCode == 200) {
         return true; // ✅ User found, continue
       } else {
         debugPrint("⚠️ User not found in database, logging out...");
         await SignOut().signOutFromFirebase(context);
         return false;
       }
     } catch (e) {
       debugPrint("❌ Error checking user: $e");
       return false;
     }
   }

  @override
  Widget build(BuildContext context) {
    // colors
     ColorScheme theme = Theme.of(context).colorScheme;
    return  Container( // Background image container
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(
                0xff002473), Color(0xff00b5fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,),),

        // Display All Widgets Colum
        child: Scaffold(backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Welcome Text Container
              Center(
                  child: const Text('Welcome to Social Task', style: TextStyle(decoration: TextDecoration.none,
                    fontFamily: 'WelcomeFont', color: Colors.white, fontSize: 30, shadows: [
                      Shadow(offset: Offset(2.0, 2.0), color: Colors.black, blurRadius: 2.0,),
                      Shadow(offset: Offset(-2.0, -2.0), color: Colors.black, blurRadius: 2.0,),
                    ],),
                  )),
          SizedBox(height: 150,),

          // White Box Container
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryFixedDim,
                  border: Border(top: BorderSide(color: theme.onPrimaryContainer, width: 0.2)),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25)),
                ),
                width: double.infinity,
                height: 290,
                padding: const EdgeInsets.only(top: 15),

          // White Box in All Widget's
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

          // Sign with Google Button Container
                     (_loading==true)? Center(child: CircularProgressIndicator(color: theme.onPrimaryContainer, strokeWidth: 3,),):
                  Container(margin: const EdgeInsets.symmetric(horizontal: 20.00, vertical: 10.00),
                    child: SizedBox(width: double.infinity,
                      child: MyButton(txt: 'Sign in with Google', borderLineOn: true, shadowOn: true, shadowColor: theme.onPrimaryContainer, borderColor: theme.onPrimaryContainer, txtSize: 20,
                          img: 'google_login_icon.webp', bgColor: theme.primaryFixed, txtColor: theme.onPrimaryContainer, txtSpace: 10, borderLineSize: 0.8, borderRadius: 25.00,
                          pading: const EdgeInsets.symmetric(horizontal: 10.00, vertical: 8.00),
                          onClick: () async{
                            await signInWithGoogle(context);
                      }
                      ),


                    ),
                  ),

          // Center Text Boost Your Content
                    IntrinsicWidth(
                    child: Column(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                            child: Text('Boost your content and increase your audience', style: Theme.of(context).textTheme.labelSmall,),),

                          // Line Below Text
                          Divider(thickness: 0.7, color: theme.onPrimaryContainer,),
                        ],
                      ),
                  ),

          // Last Text Agree confirm privacy policy
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'You agree to Social Task and confirm that you have read and understand it by continuing ',
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [

                          TextSpan(text: 'Terms of Use',
                            style: TextStyle(fontSize: 11, color: theme.onPrimaryContainer, fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () { launchUrl(Uri.parse('https://socialtask.xyz/terms-and-conditions/'));},),

                          TextSpan(text: ' and ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [

                              TextSpan( text: 'Privacy Policy',
                                style: TextStyle(fontSize: 11, color: theme.onPrimaryContainer,  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {launchUrl(Uri.parse('https://socialtask.xyz/privacy-policy/'));},),
                            ],),
                        ],),
                    ),
                  )
                ],),
              )
            ],),
        )
    );
  }
}
