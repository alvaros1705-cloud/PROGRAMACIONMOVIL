import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Archivo generado automáticamente por FlutterFire CLI
import 'firebase_options.dart';

// Configuración de rutas
import 'config/routes.dart';
import 'providers/theme_provider.dart';

/// ---------------------------------------------------------------------------
/// Punto de entrada de la aplicación Judisa Taller
/// ---------------------------------------------------------------------------
///
/// Esta aplicación gestiona un taller de confección de jeans sin autenticación.
/// Permite administrar empleados, registrar cortes de tela y controlar pagos.
///
/// Tecnologías utilizadas:
/// - Flutter para la interfaz de usuario
/// - Firebase Firestore para persistencia de datos en tiempo real
/// - Riverpod para manejo de estado reactivo
/// - GoRouter para navegación declarativa
///
/// FASES DEL PROYECTO:
/// - FASE 1: Modelos y servicios ✅
/// - FASE 2: Providers y navegación ✅
/// - FASE 3: Pantallas y UI (próxima)
void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  // antes de cualquier operación asíncrona (como Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase con las opciones específicas de la plataforma
  // Las opciones vienen del archivo generado por FlutterFire CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Habilitar caché offline de Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Inicia la aplicación envuelta en ProviderScope
  // ProviderScope es obligatorio para que Riverpod funcione correctamente
  // Mantiene el estado de los providers en toda la app
  runApp(
    const ProviderScope(
      child: JudisaTallerApp(),
    ),
  );
}

/// ---------------------------------------------------------------------------
/// Widget raíz de la aplicación
/// ---------------------------------------------------------------------------
class JudisaTallerApp extends ConsumerWidget {
  /// Constructor constante para optimizaciones del compilador
  const JudisaTallerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      // Información de la aplicación
      title: 'Judisa Taller',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,

      // Configuración de rutas con GoRouter
      routerConfig: appRouter,

      // Tema visual de la aplicación
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
    );
  }

  /// -------------------------------------------------------------------------
  /// Construye el tema claro de la aplicación con los colores especificados
  /// -------------------------------------------------------------------------
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3F51B5),
        brightness: Brightness.light,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF5F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF3F51B5), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: GoogleFonts.robotoTextTheme(),
    );
  }

  /// -------------------------------------------------------------------------
  /// Construye el tema oscuro de la aplicación con los colores especificados
  /// -------------------------------------------------------------------------
  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5C6BC0),
        secondary: Color(0xFFFFC107),
      ),
      cardColor: const Color(0xFF1E1E2E),
      scaffoldBackgroundColor: const Color(0xFF12121F),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF5C6BC0), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    );
  }
}
