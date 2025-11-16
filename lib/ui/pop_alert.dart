import 'package:flutter/material.dart';
import 'button.dart';
class pop{

//🔹 Back Pop Confirm Alert
  static backAlert({required BuildContext context, IconData icon=Icons.warning, String title='Confirm Exit',
    required String bodyTxt, String confirm='Confirm',  VoidCallback? onConfirm, }) {
    ColorScheme theme = Theme.of(context).colorScheme;
    final VoidCallback confirmAction = onConfirm ?? () => Navigator.of(context).pop(true);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryContainer, width: 0.5),
        borderRadius: BorderRadius.circular(7),),
      title: Row(spacing: 5,
        children: [
          Icon(icon, size: 28, color: theme.secondaryFixedDim),
          Text(title, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),),
        ],
      ),
      content: Text(bodyTxt, style: Theme.of(context).textTheme.displaySmall?.copyWith(wordSpacing: 1, fontSize: 15)),
      actions: <Widget>[
        SizedBox(height: 36,
          child: MyButton(txt: 'Cancel', borderRadius: 40, pading: const EdgeInsets.only(left: 20, right: 20), shadowOn: true,
              bgColor: Colors.transparent, txtSize: 12, shadowColor: theme.primaryFixed,
              txtColor: theme.onPrimaryContainer,
              onClick: () {Navigator.of(context).pop(false);}),
        ),
        SizedBox(height: 36,
          child: MyButton(txt: confirm, borderRadius: 40, pading: const EdgeInsets.only(left: 20, right: 20), shadowOn: true,
              bgColor: theme.primaryFixedDim, borderLineOn: true, borderLineSize: 1, borderColor: theme.onPrimaryContainer, txtSize: 12, txtColor: theme.onPrimaryContainer,
              onClick: () => confirmAction() ),
        ),
      ],
    );
  }


}