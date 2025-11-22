import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader {
 static int getRandomNumber({int min = 1, int max = 20}) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }


  static Widget homeTasksShimmerLoading(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.surfaceContainer,
          highlightColor: theme.surfaceBright,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.black38,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.black54, width: 1)),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 55,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5),),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 5),
                      Container(height: 14, width: 90, color: Colors.white),
                    ],),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text("${getRandomNumber(min: 5, max: 20)}", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 27)),
                    Text("Tikets", style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 static Widget oneTaskShimmerLoading(BuildContext context) {
   ColorScheme theme = Theme.of(context).colorScheme;
   TextTheme textTheme = Theme.of(context).textTheme;
   final List<String> actions = ["Like", "Subscribe",  "Follow", "Comment", "Favorite", "WatchTime"];
   final List<int> seconds = [20, 30, 40, 60, 90, 120, 45];
   final Random random = Random();
   String randomTask = actions[random.nextInt(actions.length)];
   int randomSeconds = seconds[random.nextInt(seconds.length)];
   return Padding(
     padding: const EdgeInsets.all(10),
     child: Column(
               children: [
                 // Task Image
                 Shimmer.fromColors(
                   baseColor: theme.surfaceContainer,
                   highlightColor: theme.surfaceBright,
                   child: Container(
                   margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                   width: double.infinity,
                   height: 300,
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5),),
                 ),),

                 // Ticket and Seconds Time
                 Stack(
                   children: [
                     Shimmer.fromColors(
                       baseColor: theme.surfaceContainer,
                       highlightColor: theme.surfaceBright,
                       child: Container(
                         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                         height: 50,
                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5),),
                       ),
                     ),
                     
                     Positioned(top: 10, left: 0, right: 0,
                         child: Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                           children: [
                             Row( spacing: 3,
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: [
                                 Text("${getRandomNumber(min: 5, max: 20)}", style: TextStyle(fontSize: 27, color: theme.primaryFixed, fontWeight: FontWeight.bold),),
                                 Text("Tickets", style: TextStyle(fontSize: 12, color: theme.primaryFixed, fontWeight: FontWeight.bold),),
                               ],
                             ),

                             Row( spacing: 3,
                               crossAxisAlignment: CrossAxisAlignment.end,
                               children: [
                                 Text("$randomSeconds", style: TextStyle(fontSize: 27, color: theme.primaryFixed, fontWeight: FontWeight.bold),),
                                 Text("Seconds", style: TextStyle(fontSize: 12, color: theme.primaryFixed, fontWeight: FontWeight.bold),),
                               ],
                             ),
                           ],
                         ))
                   ],),

                 // Buttons Like/Follow and Next Task
                 Row(
                   children: [
                     Expanded(
                       child: Stack(
                         children: [
                           Shimmer.fromColors(
                             baseColor: theme.surfaceContainer,
                             highlightColor: theme.surfaceBright,
                             child: Container(
                               margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                               height: 45,
                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),),
                             ),
                           ),
                           
                           Positioned(top: 16, left: 0, right: 0, child: Center(child: Text(randomTask,
                             style: textTheme.displaySmall?.copyWith(fontSize: 20, color: theme.primaryFixed, fontWeight: FontWeight.bold),)))
                         ],
                       ),
                     ),
                     Expanded(
                       child: Stack(
                         children: [
                           Shimmer.fromColors(
                             baseColor: theme.surfaceContainer,
                             highlightColor: theme.surfaceBright,
                             child: Container(
                               margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                               height: 45,
                               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),),
                             ),
                           ),
                           Positioned(top: 16, left: 0, right: 0, child: Center(
                               child: Text("Next Task",
                                 style: textTheme.displaySmall?.copyWith(fontSize: 18, color: theme.primaryFixed, fontWeight: FontWeight.bold),)))
                         ],
                       ),
                     ),
                   ],
                 ),
               ],
         ),
   );
 }

 static Widget leaderboardShimmerLoading(BuildContext context) {
   // Generate random descending numbers for ranks
   List<int> rankNumbers = List.generate(9, (index) {
     return getRandomNumber(min: 10, max: 1000);
   });
   // Sort descending so top rank is biggest
   rankNumbers.sort((a, b) => b.compareTo(a));
     final List<double> rightMarginList = [10, 20, 30, 40, 60, 80, 100, 120, 130];
     final Random random = Random();

   return ListView.builder(
     itemCount: rankNumbers.length,
     itemBuilder: (context, index) {
       double randomMargin = rightMarginList[random.nextInt(rightMarginList.length)];
       return Shimmer.fromColors(
         baseColor: Theme.of(context).colorScheme.surfaceContainer,
         highlightColor: Theme.of(context).colorScheme.surfaceBright,
         child: Container(
           margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
           padding: const EdgeInsets.all(4),
           decoration: BoxDecoration(
             color: Colors.black38,
             borderRadius: BorderRadius.circular(7),
             border: Border.all(color: Colors.black54, width: 1),
           ),
           child: Row(
             children: [
               const SizedBox(width: 5),
               // LEFT SIDE INDEX (1,2,3...)
               Text("${index + 1}", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 27),),
               const SizedBox(width: 12),
               // PROFILE IMAGE SHIMMER
               Container(
                 width: 40,
                 height: 40,
                 decoration: BoxDecoration(color: Colors.white,
                   borderRadius: BorderRadius.circular(50),),
               ),
               const SizedBox(width: 10),

               // NAME SHIMMER
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       margin: EdgeInsets.only(right: randomMargin),
                       height: 18,
                       width: double.infinity,
                       color: Colors.white,
                     ),
                   ],),
               ),
               const SizedBox(width: 10),
               // RIGHT SIDE RANK SCORE (Descending random)
               Text("${rankNumbers[index]}", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 25),),
             ],
           ),
         ),
       );
     },
   );
 }


}
