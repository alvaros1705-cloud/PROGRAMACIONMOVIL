// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
// ignore: uri_does_not_exist
import 'firebase_options.dart'; // generado por FlutterFire CLI
import 'screens/intro_splash.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inicializar Firebase ───────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MindfulPhoneApp(),
    ),
  );
}

class MindfulPhoneApp extends StatelessWidget {
  const MindfulPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MindfulPhone',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // ── Auth gate: muestra splash → login o dashboard según sesión ──────────
      home: const IntroSplash(),
    );
  }
}

/// Widget que escucha el estado de autenticación y redirige correctamente.
/// - Primera vez (sin sesión): SplashScreen → LoginScreen
/// - Con sesión activa (ej. volvió a abrir la app): directo al Dashboard
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Esperando conexión con Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        // Usuario con sesión activa
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        // Sin sesión → onboarding / splash
        return const SplashScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}