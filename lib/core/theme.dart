import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RpgColors {
  static const Color background = Color(0xff0c0c14);
  static const Color cardBg = Color(0xff161626);
  static const Color primary = Color(0xff00e5ff); // Neon Cyan
  static const Color secondary = Color(0xffff007f); // Neon Magenta
  static const Color accent = Color(0xffffd700); // Gold
  static const Color success = Color(0xff39ff14); // Neon Green
  static const Color textPrimary = Color(0xffffffff);
  static const Color textSecondary = Color(0xff8b8da4);
  static const Color border = Color(0xff2a2b45);

  // Rarity Colors
  static const Color common = Color(0xffb0bec5);
  static const Color rare = Color(0xff2196f3);
  static const Color epic = Color(0xff9c27b0);
  static const Color legendary = Color(0xffff9800);
}

class RpgTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RpgColors.background,
      primaryColor: RpgColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: RpgColors.primary,
        secondary: RpgColors.secondary,
        surface: RpgColors.cardBg,
        error: Colors.redAccent,
      ),
      cardTheme: CardThemeData(
        color: RpgColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RpgColors.border, width: 1),
        ),
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: RpgColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: RpgColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: RpgColors.textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: RpgColors.textSecondary, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RpgColors.cardBg,
        labelStyle: const TextStyle(color: RpgColors.textSecondary),
        hintStyle: const TextStyle(color: RpgColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RpgColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RpgColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RpgColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
