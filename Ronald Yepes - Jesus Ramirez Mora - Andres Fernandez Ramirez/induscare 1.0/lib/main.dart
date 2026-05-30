import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'viewmodels/app_viewmodel.dart';
import 'views/splash_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/home_screen.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final viewModel = AppViewModel();
  await viewModel.bootstrap();

  runApp(
    ChangeNotifierProvider.value(
      value: viewModel,
      child: const IndusCareApp(),
    ),
  );
}

class IndusCareApp extends StatelessWidget {
  const IndusCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppViewModel, ThemeMode>((vm) => vm.themeMode);
    final locale = context.select<AppViewModel, Locale>((vm) => vm.locale);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
