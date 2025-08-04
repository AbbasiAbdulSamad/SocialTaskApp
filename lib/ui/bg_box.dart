import 'package:flutter/material.dart';

class BgBox extends StatelessWidget {
  final double? wth;
  final double? hgt;
  final double allRaduis;
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  BgBox({super.key, this.wth, this.hgt, this.allRaduis=00, required this.child,
    this.margin, this.padding});
  @override
  Widget build(BuildContext context) {
    ColorScheme theme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: padding,
      width: wth,
      height: hgt,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(allRaduis),
        border: Border.all(color: theme.onPrimaryFixed, width: 0.2),
        boxShadow: <BoxShadow>[BoxShadow(color: theme.shadow, offset: Offset(0, 4), blurRadius: 3, spreadRadius: 2)]
      ),
      child: child,
    );
  }
}
