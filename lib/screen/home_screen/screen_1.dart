import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/shimmer_loading.dart';
class screen1 extends StatelessWidget{
  const screen1({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerLoader.leaderboardShimmerLoading(context);
  }
}


