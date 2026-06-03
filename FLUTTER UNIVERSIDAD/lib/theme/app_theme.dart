import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark mode
  static const bgDark = Color(0xFF0A0C14);
  static const bg2Dark = Color(0xFF111320);
  static const bg3Dark = Color(0xFF181B2E);
  static const bg4Dark = Color(0xFF1F2340);
  static const cardDark = Color(0xFF1A1D30);
  static const card2Dark = Color(0xFF222540);
  static const borderDark = Color(0x14FFFFFF);
  static const border2Dark = Color(0x24FFFFFF);
  static const text1Dark = Color(0xFFF0F2FF);
  static const text2Dark = Color(0xFFA8ADCC);
  static const text3Dark = Color(0xFF6B7194);

  // Light mode
  static const bgLight = Color(0xFFF0F2FF);
  static const bg2Light = Color(0xFFE8EBFF);
  static const bg3Light = Color(0xFFFFFFFF);
  static const bg4Light = Color(0xFFDDE1FF);
  static const cardLight = Color(0xFFFFFFFF);
  static const card2Light = Color(0xFFF4F5FF);
  static const borderLight = Color(0x1F6C63FF);
  static const border2Light = Color(0x336C63FF);
  static const text1Light = Color(0xFF0D0F2E);
  static const text2Light = Color(0xFF3A3D6B);
  static const text3Light = Color(0xFF8B8FB5);

  // Accents
  static const accent = Color(0xFF6C63FF);
  static const accent2 = Color(0xFF8B85FF);
  static const accent3 = Color(0xFF4ECDC4);
  static const accent4 = Color(0xFFFFD166);
  static const accent5 = Color(0xFFFF6B9D);
  static const green = Color(0xFF43E97B);
  static const red = Color(0xFFFF6B6B);
  static const orange = Color(0xFFFF9A3C);

  // Gradients
  static const gradient1 = [Color(0xFF6C63FF), Color(0xFF4ECDC4)];
  static const gradient2 = [Color(0xFFFF6B9D), Color(0xFFFFD166)];
  static const gradient3 = [Color(0xFF43E97B), Color(0xFF38F9D7)];
  static const gradient4 = [Color(0xFF6C63FF), Color(0xFFFF6B9D)];
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent3,
      surface: AppColors.cardDark, // M3 usa surface para el fondo de cards
      error: AppColors.red,
    ),
    textTheme: _buildTextTheme(AppColors.text1Dark, AppColors.text2Dark),
    
    // CORRECCIÓN: Se usa CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    
    inputDecorationTheme: _buildInputTheme(
      AppColors.cardDark,
      AppColors.borderDark,
      AppColors.text3Dark,
    ),
    elevatedButtonTheme: _buildButtonTheme(),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      secondary: AppColors.accent3,
      surface: AppColors.cardLight,
      error: AppColors.red,
    ),
    textTheme: _buildTextTheme(AppColors.text1Light, AppColors.text2Light),
    
    // CORRECCIÓN: Se usa CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    
    inputDecorationTheme: _buildInputTheme(
      AppColors.cardLight,
      AppColors.borderLight,
      AppColors.text3Light,
    ),
    elevatedButtonTheme: _buildButtonTheme(),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme(
    Color fill,
    Color border,
    Color hint,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: GoogleFonts.plusJakartaSans(color: hint, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}