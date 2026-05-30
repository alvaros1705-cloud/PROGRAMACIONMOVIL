import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color limeGreen = Color(0xFF7DC143);
  static const Color darkGreen = Color(0xFF1E7B34);
  static const Color lightBlue = Color(0xFF5C9AEA);
  static const Color darkBlue = Color(0xFF2B5FC7);
  static const Color blue = Color(0xFF5C7AEA);
  static const Color background = Color(0xFFF5F7FF);
  static const Color textDark = Color(0xFF2D3250);
  static const Color textMid = Color(0xFF4A5580);
}

abstract class AppGradients {
  /// Main brand gradient: lime green (top-left) → dark green (bottom-right).
  /// Used for AppBars, welcome card, and icon backgrounds.
  static const LinearGradient main = LinearGradient(
    colors: [
      AppColors.limeGreen,
      AppColors.lightBlue,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue gradient for strategy count badges.
  static const LinearGradient blue = LinearGradient(
    colors: [AppColors.lightBlue, AppColors.darkBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Elegant gray gradient used for the auth hero card.
  static const LinearGradient auth = LinearGradient(
    colors: [
      Color(0xFF6B6F76),
      Color(0xFFF2F4F8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle gray card background used for auth form container.
  static const LinearGradient authCard = LinearGradient(
    colors: [
      Color(0xFFF6F7F9),
      Color(0xFFEFF1F4),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Custom [PageRouteBuilder] with a slide-from-right + fade transition.
Route<T> slideRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, animation, __) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}
