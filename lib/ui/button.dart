import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String txt; // Button Text
  final VoidCallback onClick; // Funtion
  final Color bgColor; // Background Color
  final Color txtColor; // Text/Icon color
  final Color borderColor; // Border color
  final Color shadowColor; // Shadow color
  final IconData? ico; // Icon
  final String? img; // Image Path
  final double borderRadius; // Border Radius
  final double imgSize; // image Size
  final double txtSpace; // Icon/Imag and Text Space width
  final double icoSize; // Icon Size
  final double txtSize; // Font Size
  final bool borderLineOn; // border line on/off
  final bool shadowOn;   // Shadow on/off
  final double borderLineSize; // Border Line Width
  final String fontfamily; // font family style
  final EdgeInsets pading;

  const MyButton({
    super.key,
    required this.txt,
    required this.onClick,
    this.borderRadius = 0.0,
    this.bgColor = Colors.white,
    this.txtColor = Colors.black,
    this.ico,
    this.img,
    this.txtSpace = 6.0,
    this.icoSize = 20.0,
    this.txtSize = 18.0,
    this.borderColor = Colors.black,
    this.imgSize = 20.0,
    this.shadowColor = Colors.black,
    this.borderLineOn = false,
    this.shadowOn = false,
    this.borderLineSize = 0.5,
    this.fontfamily='',
    this.pading = const EdgeInsets.symmetric(horizontal: 15.00, vertical: 0.00)
  });

  @override
  Widget build(BuildContext context) {
     return ElevatedButton(
       onPressed: onClick,
       style: ElevatedButton.styleFrom(
         foregroundColor: txtColor, // Text/Icon color
         backgroundColor: bgColor, // BackGround color
         shadowColor:(shadowOn)?shadowColor.withOpacity(0.5): null, // Shadow color
         elevation: 15, // Elevation of the button
         padding: pading,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(borderRadius), // Rounded corners
           side: borderLineOn? BorderSide(color: borderColor, width: borderLineSize): BorderSide.none, // Border
         ),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [

           if(img!=null) Row(children: [
               Image.asset('assets/ico/$img', width: imgSize,),
               SizedBox(width: txtSpace,)
             ],),

           if(ico!=null)
             Row(children: [
                 Icon(ico, size: icoSize, color: txtColor,),
                 SizedBox(width: txtSpace,)
               ],),
           Text(txt, style: TextStyle(fontSize: txtSize, fontFamily: fontfamily)),
         ],),
     );
  }
}
