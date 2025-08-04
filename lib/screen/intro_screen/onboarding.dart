import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/authentication.dart';
import '../../ui/button.dart';
import 'flash.dart';

class OnBoarding extends StatefulWidget{
  const OnBoarding({super.key});
  @override
  State<OnBoarding> createState() => _OnBoardingState();
}
class _OnBoardingState extends State<OnBoarding> {
  final List _introData = [
    {"image": 'onboarding_1.gif',
      "title": 'Complete Tasks & Earn Tickets',},

    {"image": 'onboarding_2.webp',
      "title": 'Create Custom Campaign',},

    {"image": 'onboarding_3.gif',
      "title": 'Campaigns Progress',},

    // {"image": 'task4task.webp',
    //   "title": 'Track Campaign Progress',},
  ];

// currentPage / Page Controller
  PageController _pageControl = PageController();
  int _currentPage =0;

  // OnPage funtion
  _onPage(int index){
    setState(() {_currentPage = index;});}

// Continue to Login Page
  _continueMethod() async{
    var sharePref = await SharedPreferences.getInstance();
    sharePref.setBool(Flash.KEYLOGIN, true);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> Authentication()), (route)=> false);
  }
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(backgroundColor: Colors.transparent,toolbarHeight: 50,
            actions: [
              // Skip Button Padding
              Padding(
                padding: const EdgeInsets.only(right: 15.00),
                child: TextButton(onPressed: _continueMethod,
                    child: Text('SKIP',style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),)),
              ),],),
          backgroundColor: Colors.white,
          body: Stack(children: [
      
            // PageView All Pages Manage
            PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageControl,
              itemCount: _introData.length,
              onPageChanged: _onPage,
              itemBuilder: (context, index){
      
                // Page in Show Content throw Array List
                return Column(children:[
                  const SizedBox(height: 10,),
                  Image.asset('assets/images/'+_introData[index]['image'], width: 250, height: 450,),
                  const SizedBox(height: 20,),
                  Text(_introData[index]['title'], style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.black, fontSize: 22,),),
                  const SizedBox(height: 5,),
                ],);
              },
            ),
      
            // All Pages of bottom padding size
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  (_currentPage == (_introData.length -1))?
      
                  // Get Started button padding out side arrange
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 85, vertical: 10),
                    child: MyButton(txt: 'GET STARTED', borderLineOn: true, borderColor: Colors.white, bgColor: theme.onSecondary, borderRadius: 8.00, shadowOn: true, shadowColor: theme.onSecondary, txtColor: Colors.white, onClick: _continueMethod,),
                  ) :
      
                  // indicator and next button row
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
      
                      // small circles pages indicator row
                      Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                              _introData.length,
                                  (index){
      
                                // some animation for circle indicator
                                return AnimatedContainer(duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  height: (index == _currentPage)? 13 : 8, width: (index == _currentPage)? 13 : 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
      
                                      // color circle indicator index page
                                      color: (index == _currentPage)
                                          ? theme.secondaryFixedDim
                                          : theme.onSecondary
                                  ),
                                );}
                          )),
      
                      // Next Button
                      TextButton(onPressed: (){
                        if (_currentPage < _introData.length - 1) {
                          _pageControl.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,);}},
                        child: Row(children: [
                          Text('Next', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.black),),
                          const Icon(Icons.arrow_forward_outlined, size: 25, color: Colors.black,)
                        ],),)
                    ],
                  )
                ],),
            )
          ],)
      ),
    );
  }
}