import 'package:flutter/material.dart';

class LightThemesSetup {
  // Light Theme Colors
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
   // All Colors Setup
    colorScheme: ColorScheme.light(
      primary: const Color(0xFFA6C4EA), // 10% light use button
      onPrimary: const Color(0xff5dacd6), // 50% light use button
      secondaryContainer: const Color(0xff004664), // orgnal theme defult color
      onSecondary:const Color(0xff3a6597), // orginal dark, bottom bar color
      secondary: const Color(0xff577DAB), // orgnal light,
      surfaceTint: const Color(0xff2e5178),// Status Bar Colors
      shadow: const Color(0xFFBCBCBC), // shadow
      background: const Color(0xFFE7E7EA), // background
      primaryFixed: Colors.white, // white
      primaryFixedDim: Colors.white70, // white 70% trastion
      onPrimaryContainer: Colors.black, // black text color black
      primaryContainer: Colors.black54, // black 70% trastion
      onPrimaryFixed: const Color(0xff505050), // Haf black
      scrim: const Color(0xff63afff), // dark buttons
      surfaceDim: const Color(0xff95c8fb), // buttons
      tertiary: const Color(0xff393939), // shadow 2
      tertiaryContainer: const Color(0xffbc9805), // yellow
      secondaryFixed: const Color(0xff004664), // App Bar Color
      secondaryFixedDim: Colors.red, // red
      errorContainer: const Color(0xFF006506), // success green
      error: const Color(0xFF8B0E16), // error red
      surfaceContainer: Colors.grey[300],
      surfaceBright: Colors.grey[100],
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff004664), // App Bar color
      foregroundColor: Colors.white,
    ),

    // Floating Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),

    // Text Styling Theme
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontFamily: '3rdRoboto', fontSize: 15),
      bodySmall: TextStyle(decoration: TextDecoration.none, color: Colors.black, fontSize: 11),
      labelSmall: TextStyle(decoration: TextDecoration.none, fontWeight: FontWeight.w500, color: Color(0xff335277), fontSize: 16, fontFamily: 'BoostAudience'),
      labelMedium: TextStyle(decoration: TextDecoration.none, color: Color(0xff335277), fontSize: 22, fontFamily: 'BoostAudience'),
      labelLarge: TextStyle(overflow: TextOverflow.ellipsis, decoration: TextDecoration.none, fontWeight: FontWeight.w500, height: 1, color: Color(0xFF007306), fontSize: 22, fontFamily: 'BoostAudience'),
    ),
  );
}
