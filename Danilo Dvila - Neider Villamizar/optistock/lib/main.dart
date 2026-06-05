import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:optistock/theme/app_theme.dart';
import 'package:optistock/screens/splash_screen.dart';
import 'package:optistock/screens/auth/login_screen.dart';
import 'package:optistock/screens/home/dashboard_screen.dart';
import 'package:optistock/screens/inventory/excel_upload_screen.dart';
import 'package:optistock/screens/inventory/inventory_screen.dart';
import 'package:optistock/screens/reports/reports_screen.dart';

import 'package:optistock/screens/auth/register_screen.dart';
import 'package:optistock/screens/auth/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  
  runApp(const OptiStockApp());
}

class OptiStockApp extends StatelessWidget {
  const OptiStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OptiStock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/upload': (context) => const ExcelUploadScreen(),
        '/inventory': (context) => const InventoryScreen(),
        '/reports': (context) => const ReportsScreen(),
      },
    );
  }
}
