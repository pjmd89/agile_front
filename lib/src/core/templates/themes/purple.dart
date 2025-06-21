String themePurple = r'''import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurpleTheme {
  ThemeData get materialTheme{
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.purple,
        secondary: Colors.purple,
        brightness: Brightness.dark
      ),
      brightness: Brightness.dark
    );
  }
}''';