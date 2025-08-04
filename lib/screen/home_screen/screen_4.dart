import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class screen4 extends StatefulWidget{
  const screen4({super.key});
  @override
  State<screen4> createState() => _screen4State();
}
class _screen4State extends State<screen4> {
  @override
  Widget build(BuildContext context) {
    return Container(alignment: Alignment.center,
      child: Text('4 Page', style: Theme.of(context).textTheme.labelMedium,)
      ,);
  }
}