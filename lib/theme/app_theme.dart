import 'package:flutter/material.dart';

class AppTheme {
  /* ───────────────────── LIGHT ───────────────────── */
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: const Color(0xFFF0F2F5),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF111418), // main text & selected icon
      secondary: Color(0xFF60758A),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: Color(0xFF111418),
    ),
  );

  /* ───────────────────── DARK ───────────────────── */
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    dividerColor: const Color(0xFF2C2C2C),

    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: Color(0xFFB0BEC5),
      surface: Color(0xFF121212),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Color(0xFFB0BEC5),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
