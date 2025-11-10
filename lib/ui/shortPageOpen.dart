import 'package:flutter/material.dart';

class Shortpageopen{

static Future shortPage(BuildContext context, IconData icon, String heading, Widget child){
    ColorScheme theme = Theme.of(context).colorScheme;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.primaryFixed,
      shape: const RoundedRectangleBorder(
        borderRadius:const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.4,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:const BorderRadius.vertical(top: Radius.circular(20)),
                    color: theme.secondaryContainer,
                    boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2),),],),
                  child: Row(spacing: 8,
                    children: [
                      Icon(icon, color: Colors.white, size: 28,),
                      Text(heading, style: Theme.of(context).textTheme.labelMedium?.
                      copyWith(color: Colors.white, fontSize: 22),),
                    ],
                  ),
                ),

                Expanded(child: child),
              ],
            );
          },
        );
      },
    );
  }
}