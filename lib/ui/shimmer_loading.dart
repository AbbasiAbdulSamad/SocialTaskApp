import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader {
 static int getRandomNumber({int min = 1, int max = 30}) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  static Widget buildShimmerLoading() {
    return ListView.builder(
      itemCount: 7, // Dummy shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.black54, width: 1)
            ),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 5),
                      Container(height: 14, width: 90, color: Colors.white),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Text("${getRandomNumber(min: 5, max: 30)}", style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 27)),
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
}
