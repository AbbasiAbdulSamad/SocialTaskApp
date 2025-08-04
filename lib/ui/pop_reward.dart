import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../server_model/internet_provider.dart';
import 'button.dart';
import 'flash_message.dart';

class RewardPop{
  static Widget rewardPop({required BuildContext context, bool useForLevel=false, int level=1, String congratulations="Congratulations!", required String img,required String reward,required String description,
    required IconData buttonIcon,required String buttonText,required VoidCallback apiCall}){
    ColorScheme theme = Theme.of(context).colorScheme;
    TextTheme textStyle = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100,),
          Container(width: 300, height: useForLevel? 450: 422, color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                      color: theme.background,
                      border: Border.all(color: theme.onPrimaryFixed, width: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: theme.tertiary, spreadRadius: 1, blurRadius: 30,)]
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Text(reward, textAlign: TextAlign.center,
                        style: textStyle.displaySmall?.copyWith(fontSize: useForLevel? 28:30, letterSpacing: 0, color: theme.errorContainer),
                      ),
                      const SizedBox(height: 3),
                      Text(congratulations, textAlign: TextAlign.center, style: textStyle.labelSmall?.copyWith(fontSize: 25, color: Colors.deepOrange),),
                      SizedBox(height:useForLevel? 7: 40),
                      Text(description, textAlign: TextAlign.center,
                        style: textStyle.displaySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: theme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 15),
                    ],),
                ),
                Container(width: double.infinity, height:180,
                    alignment: Alignment.center,
                    child: Lottie.asset(img)),

                Positioned(top: 82, right: 5,
                    child: SizedBox(
                      width: 35,
                      height: 35,
                      child: Opacity(opacity: 0.8,
                        child: IconButton(
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              padding: EdgeInsets.zero),
                          color: Colors.black,
                          icon: Icon(Icons.close, size: 28,), onPressed: (){Navigator.pop(context);},),
                      ),
                    )
                ),

                Positioned( bottom: 0, left: 0, right: 0,
                  child: Center(
                    child: MyButton(txt: buttonText, onClick: (){
                      final internetProvider = Provider.of<InternetProvider>(context, listen: false);
                      if (internetProvider.isConnected){
                        apiCall();
                      } else {
                        AlertMessage.snackMsg(context: context, message: 'No internet connection. Please connect to the network.', time: 3);
                        Navigator.pop(context);
                      }},
                      shadowOn: true, borderRadius: useForLevel?30:20, pading: EdgeInsets.symmetric(vertical:useForLevel?15:0, horizontal: useForLevel?31:20), txtSize: 15, fontfamily: '3rdRoboto', borderLineOn: true,
                      ico: buttonIcon, icoSize: 18, bgColor:Colors.amber,
                    ),
                  ),
                ),
                // if Level Box Use this Ui
                useForLevel?
                Positioned( bottom: 24, left: 0, right: 0,
                    child: Center(
                        child: Stack(
                          children: [
                            Positioned(top: 0, left: 0, right: 0, child: Text('$level', textAlign: TextAlign.center,
                              style: textStyle.displaySmall?.copyWith(fontSize: 70, fontWeight: FontWeight.w800,
                              color: Colors.orange, shadows: [
                                  const Shadow(offset: Offset(2.0, 2.0), color: Colors.black, blurRadius: 2.0,),
                                  const Shadow(offset: Offset(-2.0, -2.0), color: Colors.black, blurRadius: 2.0,),
                                ],),)),
                            Container(margin:const EdgeInsets.only(left: 25, right: 20, top: 43),
                                child: Image.asset('assets/ico/levelUp_bg.png')),
                          ],
                        )
                    ),
                ):SizedBox()
              ],
            ),

          ),
        ],
      ),
    );
  }
}