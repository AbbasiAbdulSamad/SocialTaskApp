import 'package:flutter/material.dart';

class OverlayEntryWidget extends StatelessWidget {
  const OverlayEntryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 120,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              "Hello from Overlay!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
