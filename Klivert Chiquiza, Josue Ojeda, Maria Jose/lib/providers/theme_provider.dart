import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider global para manejar el modo de tema de la aplicación.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Notifier que carga el tema desde SharedPreferences y lo alterna.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light) {
    _cargarTema();
  }

  Future<void> _cargarTema() async {
    final prefs = await SharedPreferences.getInstance();
    final oscuro = prefs.getBool('modo_oscuro') ?? false;
    state = oscuro ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTema() async {
    final prefs = await SharedPreferences.getInstance();
    final esOscuro = state == ThemeMode.dark;
    state = esOscuro ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('modo_oscuro', !esOscuro);
  }
}
