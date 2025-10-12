import 'dart:convert';

import 'package:app/ui/flash_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../config/config.dart';
import '../../server_model/functions_helper.dart';
import '../../server_model/premium.dart';
import '../../ui/bg_box.dart';
import '../../ui/ui_helper.dart';

class PremiumAccount extends StatefulWidget {
   PremiumAccount({super.key});

  @override
  State<PremiumAccount> createState() => _PremiumAccountState();
}

class _PremiumAccountState extends State<PremiumAccount> {
  final InAppPurchase _iap = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  List<Map<String, dynamic>> _planList = [];
  bool _loading = true;

  Set<String> _productIds = {'premium_weekly', 'premium_monthly', 'premium_yearly',};

  @override
  void initState() {
    super.initState();
    _initStore();
    _iap.purchaseStream.listen(_handlePurchaseUpdates);
  }

  Future<void> _initStore() async {
    final available = await _iap.isAvailable();
    if (!available) {
      setState(() => _loading = false);
      return;
    }

    final response = await _iap.queryProductDetails(_productIds);
    print("Not Found IDs: ${response.notFoundIDs}");
    print("Fetched products:");
    response.productDetails.forEach((p) => print("${p.id} - ${p.title} - ${p.price}"));

    setState(() {
      _products = response.productDetails;

      // Product details ko product ID ke hisaab se group karna
      Map<String, List<ProductDetails>> groupedProducts = {};

      for (var p in _products) {
        if (!groupedProducts.containsKey(p.id)) {
          groupedProducts[p.id] = [];
        }
        groupedProducts[p.id]!.add(p);
      }

      _planList = [];

      groupedProducts.forEach((productId, productList) {
        // Price ke hisaab se sort karna (numeric price nikal ke)
        productList.sort((a, b) {
          double priceA = double.tryParse(_extractDigits(a.price)) ?? 0;
          double priceB = double.tryParse(_extractDigits(b.price)) ?? 0;
          return priceA.compareTo(priceB);
        });

        // Sabse kam price discounted, sabse zyada price original price hoga
        final discountedProduct = productList.first;
        final originalProduct = productList.last;

        double originalPriceNum = double.tryParse(_extractDigits(originalProduct.price)) ?? 0;
        double discountedPriceNum = double.tryParse(_extractDigits(discountedProduct.price)) ?? 0;
        int discountPercent = 0;
        if (originalPriceNum > 0) {
          discountPercent = (((originalPriceNum - discountedPriceNum) / originalPriceNum) * 100).round();
        }

        _planList.add({
          'plan': cleanTitle(discountedProduct.title),
          'textLine': discountedProduct.description,
          'originalPrice': originalProduct.price,
          'price': discountedProduct.price,
          'discount': discountPercent.toString(),
          'onClick': () => _buy(discountedProduct),
        });
      });

      // Ab custom sort lagayen — "Weekly Premium" sabse pehle aayega
      _planList.sort((a, b) {
        if (a['plan'].toString().toLowerCase().contains('weekly')) {
          return -1;  // a ko b se pehle rakho
        } else if (b['plan'].toString().toLowerCase().contains('weekly')) {
          return 1;   // b ko a se pehle rakho
        } else {
          return 0;   // baki order jaisa hai waise hi rehne do
        }
      });

      _loading = false;
    });
  }
// Clean (Social Task Name)
  String cleanTitle(String title) {
    return title.replaceAll(RegExp(r'\s*\(Social Task\)'), '');
  }
// Helper function jo price string me se digits nikalti hai
  String _extractDigits(String price) {
    return price.replaceAll(RegExp(r'[^\d.]'), '');
  }


  void _buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Plan ID
        String planId = purchase.productID;

        // Backend API call
        final result = await subscribeToPremium(planId, purchase.verificationData.serverVerificationData,);

        // SnackBar message show
        if (result.containsKey("error")) {
          _showSnackBar(context, result["error"], isError: true);
        } else {
          _showSnackBar(context, "Premium subscription active successful!", isError: false);
        }

        // Complete purchase
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16),),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<Map<String, dynamic>> subscribeToPremium(String planId, String purchaseToke) async {
    try {
      String? userEmail = await Helper.getFirebaseEmail();
      if (userEmail == null) {
        return {"error": "User not authenticated"};
      }

      // Send API request to subscribe to premium
      final response = await http.post(
        Uri.parse(ApiPoints.premiumSubAPi),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "plan": planId,
          "purchaseToken": purchaseToke,
          "userEmail": userEmail,
        }),
      );
      // Handle response
      if (response.statusCode == 200) {
        AlertMessage.flashMsg(context, "Your premium account has been activated.", "Congratulations!", Icons.workspace_premium, 10);
        return jsonDecode(response.body);
      } else {
        return {"error": "Failed to subscribe: ${response.body}"};
      }
    } catch (e) {
      return {"error": "Error: $e"};
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    TextStyle? justBold = const TextStyle(fontWeight: FontWeight.bold);
    TextStyle? textStyle = Theme.of(context).textTheme.displaySmall;
    TextStyle? textStyleFree = Theme.of(context).textTheme.displaySmall?.copyWith(color: theme.secondaryFixedDim, fontSize: 15);
    TextStyle? textStyleVip = Theme.of(context).textTheme.displaySmall?.copyWith(color: theme.errorContainer, fontSize: 15);
    return Scaffold(backgroundColor: theme.primaryFixed,
        appBar: AppBar(title: const Text('Premium Subscription', style: TextStyle(fontSize: 18)),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surfaceTint,
            statusBarIconBrightness: Brightness.light,),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Background box with premium benefits
                  BgBox(
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    allRaduis: 10,
                    child: SizedBox(width: double.infinity,
                        child: Column(
                          children: [
                            Image.asset('assets/ico/crown-icon.webp', width: 60,),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [theme.background, Colors.amber, theme.background]),
                                  borderRadius: BorderRadius.circular(7),
                                  border: const Border(bottom: BorderSide(color: Colors.black, width: 1))
                                ),
                                child: Text('Benefits of Premium Plan',style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black))),
                            const SizedBox(height: 30,),

                            // Features table comparing free vs premium
                            DataTable(
                              columnSpacing: 12.0,
                              columns: [
                                DataColumn(label: Text('Features', style: justBold)),
                                DataColumn(label: Text('Free', style: justBold)),
                                DataColumn(label: Text('Premium', style: justBold)),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(Text('AutoPlay', style: textStyle,)),
                                  DataCell(Center(child: Text('20', style: textStyleFree,))),
                                  DataCell(Center(child: Text('1000', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Ads', style: textStyle,)),
                                  DataCell(Center(child: Icon(Icons.done, color: theme.secondaryFixedDim,))),
                                  DataCell(Center(child: Icon(Icons.close, color: theme.errorContainer))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Daily Tickets', style: textStyle,)),
                                  DataCell(Center(child: Text('20', style: textStyleFree,))),
                                  DataCell(Center(child: Text('100', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Bonus', style: textStyle,)),
                                  DataCell(Center(child: Icon(Icons.close, color: theme.secondaryFixedDim,))),
                                  DataCell(Center(child: Icon(Icons.done, color: theme.errorContainer,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Campaign Limit', style: textStyle,)),
                                  DataCell(Center(child: Text('10', style: textStyleFree,))),
                                  DataCell(Center(child: Text('100', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Campaign Cost Discount', style: textStyle,)),
                                  DataCell(Center(child: Text('0%', style: textStyleFree,))),
                                  DataCell(Center(child: Text('20%', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Campaign Progress', style: textStyle,)),
                                  DataCell(Center(child: Text('Slow', style: textStyleFree,))),
                                  DataCell(Center(child: Text('Fast', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('LevelUp Score', style: textStyle,)),
                                  DataCell(Center(child: Text('Slow', style: textStyleFree,))),
                                  DataCell(Center(child: Text('Fast', style: textStyleVip,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Rewards', style: textStyle,)),
                                  DataCell(Center(child: Text('1x', style: textStyleFree,))),
                                  DataCell(Center(child: Text('10x', style: textStyleVip,))),
                                ]),
                              ],),
                            const SizedBox(height: 450,)
                          ],),
                      ),
                    ),

                  // Premium Plans Section
                  Positioned(bottom: 0, left: 0, right: 0,
                    child: Column(children: [
                      // Container with shadow effect
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: theme.primaryFixed,
                            border: Border(top: BorderSide(color: theme.onPrimaryFixed, width: 1)),
                            boxShadow: [BoxShadow(color: theme.shadow, spreadRadius: 30, blurRadius: 50)],
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                        ),
                        child: Column(children: [
                          Container(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                              margin: const EdgeInsets.all(22),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [theme.errorContainer,Colors.green,]),
                                border: Border(bottom: BorderSide(color: theme.onPrimaryContainer, width: 2)),
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
                              ),
                              child: Text('PREMIUM PLANS',style: textStyle?.copyWith(color: theme.primaryFixed, fontSize: 20))),

                          // List of premium plans
                    _planList.isEmpty
                        ? Ui.loading(context)
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _planList.length,
                      itemBuilder: (context, index) {
                        final plan = _planList[index];
                        return _premiumPlan(
                          context,
                          plan['plan'],
                          plan['textLine'],
                          plan['originalPrice'],
                          plan['price'],
                          plan['discount'],
                          plan['onClick'],
                        );
                      },
                    ),
                    const SizedBox(height: 20,),

                          // Subscription renewal info
                          Container(
                            color: theme.background,
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 15),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'All subscriptions automatically renew after the selected subscription period.'
                                    'The account will be charged for each renewal unless the subscription is canceled. ',
                                style: TextStyle(fontSize: 11,height: 1.3, fontWeight: FontWeight.w400, color: theme.onPrimaryFixed),
                                children: [
                                      TextSpan( text: 'How to cancel?',
                                        style: TextStyle(fontSize: 11, color: theme.onPrimaryContainer,  fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                        Ui.Add_campaigns_pop(context, 'Cancel Subscription',
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                                          child: const Text('⚠️ Your subscription will not be cancelled if you uninstall the app.\n\n\n'
                                              'Follow the instructions\n\n'
                                              '1. On your android device open the google play store.\n'
                                              '2. Check if you are signed in to the correct google account.\n'
                                              '3. Tap menu subscriptions.\n'
                                              '4. Select the subscription you want to cancel.\n'
                                              '5. Tap cancel subscription.',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, height: 1.3),),));
                                          },),
                                    ],),
                            ),
                          )
                        ],),
                      )
                    ],),
                  )
                ],),
            ],),
        ),

    );
  }

   // Premium Plan List Widget
   Widget _premiumPlan(BuildContext context, String planName, String textLine,
       String originalPrice, String price, String discount, VoidCallback onClick){
     TextStyle? textStyle = Theme.of(context).textTheme.displaySmall;
     ColorScheme theme = Theme.of(context).colorScheme;
     return InkWell(
       onTap: onClick,
       child: Container(
         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
         width: double.infinity,
         decoration: BoxDecoration(
           gradient: LinearGradient(colors: [Colors.orange, Colors.yellow.shade100]),
           borderRadius: BorderRadius.circular(10),
           border: Border.all(color: const Color(0xFF007306), width: 2),
           boxShadow: [BoxShadow(color: theme.onPrimaryFixed, offset: Offset(2, 4), blurRadius: 2, spreadRadius: 1)]
         ),

         child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Expanded(
               child: Padding(
                 padding: const EdgeInsets.only(left: 10),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(planName, style: const TextStyle(fontSize: 22, height: 1, wordSpacing: 3,
                         color: Colors.black, fontWeight: FontWeight.bold,),),
                     Row(children: [
                       // Expands to prevent overflow
                       Expanded(
                         child: LayoutBuilder(
                           builder: (context, constraints) {
                             // Dynamically adjusts font size based on width
                             double fontSize = constraints.maxWidth * 0.08;
                             fontSize = fontSize.clamp(13, 22); // Min 13, Max 22
                             return Text(textLine,
                               maxLines: 1, overflow: TextOverflow.ellipsis,
                               style: textStyle?.copyWith(fontSize: fontSize, color: const Color(0xFF007306),),
                             );
                           },
                         ),
                       ),


                       // Original price with strikethrough
                       Text(originalPrice, style: textStyle?.copyWith(fontSize: 18, color: Colors.black,
                         decoration: TextDecoration.lineThrough, decorationThickness: 2,
                         decorationColor: Colors.red,
                       ),),
                       // Space between elements
                       const SizedBox(width: 7),
                     ],),
                   ],),
               ),
             ),

             // Right-side price box
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
               decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(7),),
               child: Column(
                 children: [
                   // Discounted price
                   Text('$price', style: textStyle?.copyWith(fontSize: 20, color: Colors.black),),

                   // Discount percentage box
                   Container(
                     margin: const EdgeInsets.only(top: 1),
                     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                     decoration: const BoxDecoration(
                       color: Color(0xFF007306),
                       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(7), bottomRight: Radius.circular(7),
                       ),
                     ),
                     child: Text('$discount% OFF', style: const TextStyle(fontFamily: '3rdRoboto',
                       fontSize: 16, color: Colors.white,),),
                   ),
                 ],),
             ),
           ],),
       ),
     );
   }
}
