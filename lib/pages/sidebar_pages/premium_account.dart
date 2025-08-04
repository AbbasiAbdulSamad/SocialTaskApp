import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../server_model/premium.dart';
import '../../ui/bg_box.dart';
import '../../ui/ui_helper.dart';

class PremiumAccount extends StatelessWidget {
   PremiumAccount({super.key});
   // List of premium plans with details
  final List<Map<String, dynamic>> _planList = [
    {'plan':'Weekly Premium', 'textLine':'7-days Unlocked Premium', 'originalPrice':'3.00', 'price':'1.95',
      'discount':'35', 'onClick':() async{await PremiumSubscription.subscribeToPremium("weekly");
    }},

    {'plan':'Monthly Premium', 'textLine':'30-days Unlocked Premium', 'originalPrice':'12.00', 'price':'5.99',
      'discount':'50', 'onClick':() async{await PremiumSubscription.subscribeToPremium("monthly"); }},

    {'plan':'Yearly Premium', 'textLine':'360-days+60-days Extra Free', 'originalPrice':'144.00', 'price':'28.80',
      'discount':'80', 'onClick':() async{await PremiumSubscription.subscribeToPremium("yearly"); }},

    {'plan':'Lifetime Plane', 'textLine':'Unlocked Premium Features', 'originalPrice':'1,440', 'price':'71.99',
      'discount':'95', 'onClick':() async{await PremiumSubscription.subscribeToPremium("lifetime"); }},
  ];

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
                                  DataCell(Center(child: Icon(Icons.close, color: theme.secondaryFixedDim,))),
                                  DataCell(Center(child: Icon(Icons.done, color: theme.errorContainer,))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Ads', style: textStyle,)),
                                  DataCell(Center(child: Icon(Icons.done, color: theme.secondaryFixedDim,))),
                                  DataCell(Center(child: Icon(Icons.close, color: theme.errorContainer))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Daily Tickets', style: textStyle,)),
                                  DataCell(Center(child: Text('1x', style: textStyleFree,))),
                                  DataCell(Center(child: Text('10x', style: textStyleVip,))),
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
                                  DataCell(Text('Task CountDown', style: textStyle,)),
                                  DataCell(Center(child: Text('Full', style: textStyleFree,))),
                                  DataCell(Center(child: Text('Half', style: textStyleVip,))),
                                ]),
                              ],),
                            const SizedBox(height: 540,)
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
                         ListView.builder(
                             physics: const NeverScrollableScrollPhysics(), // Disables scrolling
                             shrinkWrap: true, // Ensures proper height inside Column
                             itemCount: _planList.length,
                             itemBuilder: (context, index){
                           return _premiumPlan(context,
                               _planList[index]['plan'] ?? 'loading...',
                               _planList[index]['textLine'] ?? 'loading...',
                               _planList[index]['originalPrice'] ?? 'loading...',
                               _planList[index]['price'] ?? '',
                               _planList[index]['discount'] ?? '',
                               _planList[index]['onClick']);
                         }),
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
         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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

                       // Dollar sign
                       Text('\$', style: textStyle?.copyWith(fontSize: 20, height: 1, color: Colors.black),),

                       // Original price with strikethrough
                       Text(originalPrice, style: textStyle?.copyWith(fontSize: 22, color: Colors.black,
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
               padding: const EdgeInsets.only(top: 1),
               decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(7),),
               child: Column(
                 children: [
                   // Discounted price
                   Text('\$$price', style: textStyle?.copyWith(fontSize: 20, color: Colors.black),),

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
