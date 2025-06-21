String themeTeal = r'''import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TealTheme {
  ThemeData get materialTheme{
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        secondary: Colors.teal,
        brightness: Brightness.dark
      ),
      brightness: Brightness.dark
    );
  }
}''';