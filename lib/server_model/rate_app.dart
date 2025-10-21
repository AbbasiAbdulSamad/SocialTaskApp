import 'package:flutter/cupertino.dart';
import 'package:rate_my_app/rate_my_app.dart';

class AppRating{
  rateApp(BuildContext context){
    RateMyApp rateMyApp = RateMyApp(
      preferencesPrefix: "rateMyApp_",
      minDays: 2,
      minLaunches: 5,
      remindDays: 15,
      remindLaunches: 15,
      googlePlayIdentifier: "com.socialtask.app",
      appStoreIdentifier: "4974844175063206450"
    );
    rateMyApp.init().then((_){
      if(rateMyApp.shouldOpenDialog){
        rateMyApp.showRateDialog(context,
          title: "Rate Social Task",
          message: "Your feedback helps us improve and bring you new features!",
          rateButton: "Rate Now",
          noButton: "NO",
          laterButton: "Not Now Later",
          listener: (button) {
          switch (button){
            case RateMyAppDialogButton.rate:
              debugPrint("Clicked on Rate");
              break;

            case RateMyAppDialogButton.no:
              debugPrint("Clicked on No");
              break;

            case RateMyAppDialogButton.later:
              debugPrint("Clicked on Later");
              break;
          }
          return true;
          },
          dialogStyle: const DialogStyle(),
          onDismissed:()=> rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
  }
}