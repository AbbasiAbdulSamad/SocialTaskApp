import 'package:flutter/material.dart';

class DarkThemesSetup {
  // Dark Theme Colors
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    // All Colors Setup
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFCDE1FB), // 10% light use button
      onPrimary: Color(0xff5dacd6), // 50% light use button
      secondaryContainer: Color(0xff004664), // orgnal theme defult color
      onSecondary:Color(0xff215795), // orginal dark, bottom bar color
      secondary: Color(0xff577DAB), // orgnal light,
      surfaceTint: Color(0xff002a59),// Status Bar Colors
      shadow: Color(0xFF3A3A3A), // shadow
      background: Color(0xFF1C1C1C), // background
      primaryFixed: Colors.black, // black
      primaryFixedDim: Colors.black54, // black 70% trastion
      onPrimaryContainer: Colors.white, // white text color black
      primaryContainer: Colors.white70, // white 70% trastion
      onPrimaryFixed: Color(0x80ffffff), // Haf White
      scrim: Color(0xff004388), // dark buttons
      surfaceDim: Color(0xff006cb8), // buttons
      tertiary: Color(0xff424242), // shadow 2
      tertiaryContainer: Color(0xffffd500), // yellow
      secondaryFixed: Color(0xff003a68), // AppBar Color
      secondaryFixedDim: Colors.red, // red
      errorContainer: Color(0xFF00FF09), // success green
      error: Color(0xFF8B0E16), // error red
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff003a68), // App Bar color
      foregroundColor: Colors.white,
    ),

    // Floating Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.red,
    ),

    // Text Styling Theme
    textTheme: const TextTheme(
        displaySmall: TextStyle(fontFamily: '3rdRoboto', fontSize: 15),
        bodySmall: TextStyle(decoration: TextDecoration.none, color: Colors.white, fontSize: 11),
        labelSmall: TextStyle(decoration: TextDecoration.none, fontWeight: FontWeight.w500, color: Color(0xffffffff), fontSize: 16, fontFamily: 'BoostAudience'),
        labelMedium: TextStyle(decoration: TextDecoration.none, color: Color(0xffffffff), fontSize: 22, fontFamily: 'BoostAudience'),
        labelLarge: TextStyle(overflow: TextOverflow.ellipsis, decoration: TextDecoration.none, fontWeight: FontWeight.w500, height: 1, color: Color(0xFF00FF09), fontSize: 22, fontFamily: 'BoostAudience'),
    ),
  );
}
