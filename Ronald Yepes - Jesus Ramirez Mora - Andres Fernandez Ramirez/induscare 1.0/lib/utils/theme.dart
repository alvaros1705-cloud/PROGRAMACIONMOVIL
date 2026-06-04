import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryPurple = Color(0xFF8B5CF6);
  static const Color _primaryContainerPurple = Color(0xFF2A1F3D);
  static const Color _lightPrimary = Color(0xFF7C5CE3);
  static const Color _lightPrimaryContainer = Color(0xFFE8DFFC);
  static const Color _lightBackground = Color(0xFFF3EFF9);
  static const Color _lightSurface = Color(0xFFE8E1F2);
  static const Color _lightDrawer = Color(0xFFE9E2F4);
  static const Color _lightDialog = Color(0xFFF0EAF8);
  static const Color _darkBackground = Color(0xFF0D0B14);
  static const Color _darkSurface = Color(0xFF1B1726);
  static const Color _darkDrawer = Color(0xFF1C1828);
  static const Color _darkDialog = Color(0xFF1E1A2B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      primaryContainer: _lightPrimaryContainer,
      secondary: Color(0xFF8D78C4),
      surface: _lightSurface,
      background: _lightBackground,
      surfaceContainerHigh: Color(0xFFD5CCE6),
      onSurface: Color(0xFF2A2436),
      onPrimary: Color(0xFFF9F7FF),
      onPrimaryContainer: Color(0xFF2C1F46),
      error: Color(0xFFCC6161),
      onError: Color(0xFFFFF6F6),
    ),
    scaffoldBackgroundColor: _lightBackground,
    canvasColor: _lightBackground,
    shadowColor: const Color(0x1F2B1F44),
    drawerTheme: const DrawerThemeData(
      backgroundColor: _lightDrawer,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightDialog,
      surfaceTintColor: Colors.transparent,
      barrierColor: const Color(0x8A2A2436),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: Color(0xFF2A2436),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xCC332C41),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6E6387),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _lightSurface,
      elevation: 2,
      shadowColor: const Color(0x1F2A2240),
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x223E3354),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: const Color(0xFF54456F),
      textColor: const Color(0xFF2D2540),
      selectedColor: const Color(0xFF241B36),
      tileColor: Colors.transparent,
      selectedTileColor: _lightPrimary.withValues(alpha: 0.14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: const Color(0xFFF9F7FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFEAE3F3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBCADD8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimary),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6D5D89)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: Color(0xFFF9F7FF),
      elevation: 5,
      hoverElevation: 6,
      highlightElevation: 7,
      focusElevation: 6,
      shape: CircleBorder(),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: _primaryPurple,
      primaryContainer: _primaryContainerPurple,
      secondary: Color(0xFFA78BFA),
      surface: _darkSurface,
      background: _darkBackground,
      surfaceContainerHigh: Color(0xFF241F33),
      onSurface: Color(0xFFEDE9FE),
      onPrimary: Color(0xFFF5F3FF),
      error: Color(0xFFF87171),
      errorContainer: Color(0xFF3A1D2B),
      onErrorContainer: Color(0xFFFFDCE5),
      onError: Color(0xFF2B1212),
    ),
    scaffoldBackgroundColor: _darkBackground,
    canvasColor: _darkBackground,
    shadowColor: const Color(0xFF090712),
    drawerTheme: const DrawerThemeData(
      backgroundColor: _darkDrawer,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkDialog,
      surfaceTintColor: Colors.transparent,
      barrierColor: const Color(0xC20A0811),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        color: Color(0xFFEDE9FE),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: const TextStyle(
        color: Color(0xCCDAD3EE),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFB2A2D9),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: _darkSurface,
      elevation: 2,
      shadowColor: const Color(0x26090712),
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0x1AEDE9FE),
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: const Color(0xFFD3C7F1),
      textColor: const Color(0xFFE6E0F7),
      selectedColor: const Color(0xFFF0EAFF),
      tileColor: Colors.transparent,
      selectedTileColor: _primaryPurple.withValues(alpha: 0.16),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryPurple,
      foregroundColor: Color(0xFFF5F3FF),
      elevation: 5,
      hoverElevation: 6,
      highlightElevation: 7,
      focusElevation: 6,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        foregroundColor: const Color(0xFFF5F3FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF171326),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A2F4F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryPurple),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB9ADD4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryPurple;
        }
        return const Color(0xFF3A2F4F);
      }),
      checkColor: WidgetStateProperty.all(const Color(0xFFF5F3FF)),
    ),
  );
}
