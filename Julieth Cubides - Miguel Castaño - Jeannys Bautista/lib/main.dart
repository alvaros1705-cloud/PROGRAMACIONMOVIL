import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const IncluyemeApp());
}

class IncluyemeApp extends StatelessWidget {
  const IncluyemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Inclúyeme',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.limeGreen,
              primary: AppColors.limeGreen,
              secondary: AppColors.lightBlue,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.background,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.limeGreen,
              brightness: Brightness.dark,
              primary: AppColors.limeGreen,
              secondary: AppColors.lightBlue,
              surface: const Color(0xFF1E1E2C),
            ),
            scaffoldBackgroundColor: const Color(0xFF12121A),
            cardColor: const Color(0xFF1E1E2C),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
