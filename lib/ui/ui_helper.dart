import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'button.dart';

class Ui{
  static loading(BuildContext context){
    ColorScheme theme = Theme.of(context).colorScheme;
    return Center(
      child: Column(spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.onPrimaryContainer,),
          Text('Loading...', style: TextStyle(fontFamily: '3rdRoboto', fontSize: 16, color: theme.onPrimaryContainer, decoration: TextDecoration.none),)
        ],
      ),
    );
  }

  static screenLoading(BuildContext context){
    ColorScheme theme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
              width: 220, height: 110,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: theme.onPrimaryFixed, width: 0.5)
              ),
              child: loading(context)),
        ),
      ),
    );
  }

  /// ✅ No Internet UI
 static buildNoInternetUI(ColorScheme theme, TextTheme textTheme,bool errorEx, String title, String dec, IconData icon, VoidCallback onClick){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(spacing: 7,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: theme.error,),
          Text(title, style: textTheme.labelMedium?.copyWith(color: theme.error),),
          Text(dec,
            textAlign: TextAlign.center, style: textTheme.displaySmall,),
          const SizedBox(height: 10),
          (errorEx)?
          Text('◉ Check internet connection\n'
              '◉ Refresh the page\n'
              '◉ Restart App\n', style: textTheme.displaySmall?.copyWith(fontSize: 14, height: 1.5,),):const SizedBox(),
          SizedBox(height: 35,
            child: MyButton(txt: 'Refresh', onClick: onClick, borderRadius: 20,
              bgColor: theme.surfaceDim, txtSize: 15, shadowOn: true, shadowColor: theme.primaryFixed, txtColor: Colors.black,),),
        ],),
    );}

//🔹Sidebar Page Label Widget
  static sidebarLabel(IconData icon, String text, VoidCallback onclick) {
    return ListTile(
      minTileHeight: 45,
      leading: Container(margin: const EdgeInsets.only(left: 10),
          child: Icon(icon, size: 22,)
      ),
      title: Text(text, style: const TextStyle(fontSize: 17, fontFamily: '3rdRoboto'),),
      onTap: onclick,
    );}

//🔹 Light Border use
  static lightLine(){
    return const Divider(thickness: 0.5, height: 0, color: Color(0xff505050),);
  }

//🔹 Full Border
  static line(){
    return const Divider(thickness: 1, height: 0, color: Color(0xFF505050),);
  }

//🔹 input Field widget
  static Widget input(BuildContext context, TextEditingController controller, String label, String hint,
      TextInputType inputType,String? Function(String?) validator, { int minL=1, int maxL=1}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: inputType,
      minLines: minL,
      maxLines: maxL,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primaryContainer),
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primaryContainer)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
        borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  //🔹 input Field widget
  static Widget DisableInput(BuildContext context, String label, IconData icon, {dynamic defaultValue = ""}) {
    TextEditingController controller = TextEditingController(text: defaultValue?.toString() ?? "",);
    ColorScheme theme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
          boxShadow: <BoxShadow>[BoxShadow(color: theme.shadow, offset: Offset(0, 4), blurRadius: 3, spreadRadius: 2)]
      ),
      child: TextFormField(
        controller: controller,
        enabled: false,
        style: TextStyle(color: theme.onPrimaryContainer, fontSize: 15),
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          labelText: label,
          labelStyle: TextStyle(color: theme.onPrimaryContainer, fontWeight: FontWeight.bold),
          prefixIcon: Icon(icon, size: 18, color: theme.onPrimaryContainer,),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.onPrimaryFixed, width: 0.2),
          ),
        ),
      ),
    );
  }

//🔹 Image button
  static imgButton(VoidCallback onClick, String img, double width){
    return GestureDetector(
      onTap: onClick,
      child: Image.asset('assets/$img', width: width,));
  }

//🔹info intruction bottom bar widget
  static Widget bottomBar(BuildContext context, String instruction, String socialImg, String socialName, String goUrl){
    return Row(children: [
      const Icon(Icons.info, size: 30,),
      const SizedBox(width: 10,),
      Expanded(child: Text(instruction, style: Theme.of(context).textTheme.displaySmall,)),
      const SizedBox(width: 7,),
      Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(onTap: () async{
           final url = goUrl;
          if (await canLaunch(url)) {
          await launch(url);
          }},
          child:Image.asset('assets/$socialImg', width: 40,),),
          Text(socialName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontFamily: '3rdRoboto'),)
        ],)
    ],);
  }

//🔹 Popup display on Add_Campaign_button
  static Future<dynamic> Add_campaigns_pop(BuildContext context, String title, Widget child) async {
    return await showDialog(context: context, builder: (BuildContext context){
      ColorScheme theme = Theme.of(context).colorScheme;
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),),
        backgroundColor: theme.scrim,
        actionsPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: Theme.of(context).textTheme.labelMedium,),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        content: Container(
          width: double.infinity,
          color: theme.background,
          child: child,
        ),
        actions: [
          Ui.line(),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),
              color: theme.surfaceDim,
            ),
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: 40,
            child: TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text('Close', style: Theme.of(context).textTheme.bodyLarge,)),
          )
        ],
      );
    });
  }

//🔹 DropDown Manu in Pop
  static Widget DropdownManu(BuildContext context, List<Map<String, dynamic>> options, String? selectedOption, String? catagory, Function(String?) onChanged,){
    ColorScheme theme = Theme.of(context).colorScheme;
    return DropdownButton<String>(
        padding: const EdgeInsets.symmetric(horizontal: 30.00, vertical: 2.00),
        underline: Container(),
        isExpanded: true,
        value: selectedOption,
        hint: Text('$catagory'),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option['name'],
            child: Text(option['name'],style: TextStyle(fontSize: 15, color: theme.onPrimaryContainer),),
          );
        }).toList(),
        onChanged: (String? newValue) {
          onChanged(newValue);
          if (newValue != null) {
            final selectedOption = options.firstWhere((option) => option['name'] == newValue);
            Navigator.push(context, MaterialPageRoute(builder: (context) => selectedOption['page']),);
          }
        },
    );
  }

// Progress Bar Widget
  static Widget progressBar(double percent, String centertText, double height, double radius) {
    return LinearPercentIndicator(
      animation: true,
      lineHeight: height,
      animationDuration: 2000,
      barRadius: Radius.circular(radius),
      progressColor: Colors.green,
      backgroundColor: Colors.grey[400],
      percent: percent,
      center: Text(
        centertText,
        style: const TextStyle(
          fontSize: 9,
          height: 1,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  // Network Image ===========
  static Widget networkImage(BuildContext context, String networkImg, String loadingImg, double wth, double hgt) {
    return CachedNetworkImage(imageUrl: networkImg, width: wth, height: hgt, fit: BoxFit.cover,
      placeholder: (context, url) => Image.asset(
        loadingImg, width: wth, height: hgt, fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => Image.asset(loadingImg, width: wth, height: hgt, fit: BoxFit.cover,),
    );
  }



  // Get Country Flags
  static Widget countryFlag(String country) {
    Future<String> getCountryFlag(String countryName) async {
      String apiUrl = "https://restcountries.com/v3.1/name/$countryName?fullText=true";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data[0]['flags']['png']; // ✅ Correct way to get flag
      } else {
        throw Exception('Failed to load flag');
      }
    }
    return FutureBuilder<String>(
      future: getCountryFlag(country),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(); // ✅ Proper loading state
        } else if (snapshot.hasError) {
          return const Text("🏴", style: TextStyle(fontSize: 20)); // ✅ Error state
        } else {
          return Image.network(snapshot.data!, width: 50, height: 30);
        }
      },
    );
  }

  static Widget bgShineRays( BuildContext context, int reward){
   final texttheme = Theme.of(context).textTheme.displaySmall;
    final screen = MediaQuery.of(context).size;
      return TweenAnimationBuilder(
       tween: Tween(begin: 0.0, end: 1.0),
    duration:const Duration(milliseconds: 2000),
    curve: Curves.bounceIn,
    builder: (context, value, _) {
      return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: screen.width * value,
            height: screen.height * value,
            child: Stack(children: [
              Lottie.asset('assets/animations/bg_shine_rays.json', repeat: false, width: screen.width * value),
              Positioned(left: 0, right: 0, top: 170,
                child: Row(spacing: 3,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('+$reward', textAlign: TextAlign.center,
                      style: texttheme?.copyWith(fontSize: 42 * value,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        shadows: [const Shadow(blurRadius: 10, color: Colors.orange,),],
                      ),
                    ),
                    Image.asset('assets/ico/1xTickets.webp', width: 45 * value,),
                  ],
                ),
              ),
            ],),
          )
      );
    });
  }

  //Selected DropDown Options
  static Widget buildMultiSelectDropdown(BuildContext context,{
    required String title,
    required List<String> items,
    required List<String> selectedItems,
    required void Function(void Function()) setState,
  }) {
   ColorScheme theme = Theme.of(context).colorScheme;
    return DropdownButton2<String>(
      isExpanded: true,
      underline:const SizedBox(),
      customButton: Container(
        padding:const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white),),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isChecked = selectedItems.contains(item);
              return CheckboxListTile(
                activeColor: theme.onPrimaryContainer,
                checkColor: theme.primaryFixed,
                value: isChecked,
                title: Text(item, style:const TextStyle(fontSize: 17, fontFamily: '3rdRoboto'),),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                  });
                  menuSetState(() {});
                },
              );
            },
          ),
        );
      }).toList(),
      onChanged: (_) {},
    );
  }

}