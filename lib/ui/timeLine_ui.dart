import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter/material.dart';

class TimeLine{
  //🔹 Level Steps to complete timeline
 static Widget timelineLevelSteps(BuildContext context, bool isFirst, bool isLast, bool isPast, IconData icon, String txt){
    return SizedBox(
      height: 100,
      width: 90,
      child: TimelineTile(
        axis: TimelineAxis.horizontal,
        isFirst: isFirst,  //🔹 if true value show first indicator
        isLast: isLast,   //🔹 if true show last indicator
        beforeLineStyle: LineStyle(

      //🔹isPast true to color changing
          color: isPast ? Colors.green : Colors.green.shade200,),

      //🔹TimeLine Circle style/height/Colors
        indicatorStyle: IndicatorStyle(
          height: 40,
          color: isPast ? Colors.green : Colors.green.shade200,
          iconStyle: IconStyle(
            iconData: isPast ? Icons.done : icon,
            color: isPast ? Colors.white : Colors.black,
            fontSize: 22,
          ),
        ),

      //🔹child exp: leve/score/nextlevel step guiding container
        endChild: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: isPast ? Colors.green : Colors.green.shade200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceTint,
              width: 0.2,),
            boxShadow: [BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                spreadRadius: 1,
                blurRadius: 10),],
          ),
          child: Align(
            alignment: Alignment.center,

        //🔹in Container Text display from level data List
            child: Text(txt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 13,
                color: isPast ? Colors.white : Colors.black,),),
          ),
        ),
      ),
    );
  }
}







