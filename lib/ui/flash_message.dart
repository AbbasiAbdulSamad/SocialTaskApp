import 'package:flutter/material.dart';
class AlertMessage{

//🔹error message display
  static errorMsg(BuildContext context, String message, String title, {int time=5}){
    ColorScheme theme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: time),
        backgroundColor: theme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16.0,),),
        //🔹Spacing between text lines
            const SizedBox(height: 4.0),
            Text(message, style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        // Add a close icon button (optional)
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }

  //🔹error message display
  static successMsg(BuildContext context, String message, String title, {int time=3}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: time),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold, fontSize: 16.0,),),
            //🔹Spacing between text lines
            const SizedBox(height: 4.0),
            Text(message, style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        // Add a close icon button (optional)
        showCloseIcon: true,
        closeIconColor: Colors.white,
      ),
    );
  }

//🔹 simple white and black flaah message
  static flashMsg(BuildContext context, String message, String title, IconData icon,int time){
    ColorScheme theme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: time),
        backgroundColor: theme.primaryFixed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),),
        margin: const EdgeInsets.only(bottom: 30, left: 15, right: 15),
        padding: const EdgeInsets.all(16.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(spacing: 5,
              children: [
                Icon(icon, size: 17,),
                Text(title, style: TextStyle(color: theme.onPrimaryContainer,fontWeight: FontWeight.bold, fontSize: 16.0,),),
              ],),
            const SizedBox(height: 4.0), // Spacing between text lines
            Text(message, style: TextStyle(color: theme.onPrimaryContainer),
            ),
          ],
        ),
        showCloseIcon: true,
        closeIconColor: Colors.red,
      ),
    );
  }

  static void snackMsg({required BuildContext context, required String message, int time=2}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                margin: EdgeInsetsGeometry.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: time)).then((_) => overlayEntry.remove());
  }
}