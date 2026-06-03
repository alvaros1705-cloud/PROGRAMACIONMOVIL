import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _contentCtrl;
  late AnimationController _pageCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _slideUp;
  late Animation<double> _contentOpacity;
  late Animation<double> _pageOpacity;

  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      icon: '📊',
      gradient: AppColors.gradient1,
      title: 'Conoce tu uso real',
      subtitle:
          'Descubre cuánto tiempo pasas en cada app con estadísticas claras y detalladas en tiempo real.',
    ),
    _OnboardData(
      icon: '⏱️',
      gradient: AppColors.gradient4,
      title: 'Pon tus propios límites',
      subtitle:
          'Establece límites personalizados por app y recibe alertas inteligentes antes de excederlos.',
    ),
    _OnboardData(
      icon: '🌱',
      gradient: AppColors.gradient3,
      title: 'Construye hábitos sanos',
      subtitle:
          'Desarrolla una relación más consciente con tu celular y mejora tu bienestar digital.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
    );
    _pageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut),
    );

    _logoCtrl.forward().then((_) {
      _contentCtrl.forward().then((_) => _pageCtrl.forward());
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _contentCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      setState(() => _currentPage++);
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const OrbsBackground(),
          SafeArea(
            child: Column(
              children: [
                // TOP: Logo + Brand
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, __) {
                    return Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              PulsingLogo(size: size.width * 0.18),
                              const SizedBox(height: 16),
                              GradientText(
                                'MindfulPhone',
                                colors: AppColors.gradient1,
                                style: GoogleFonts.sora(
                                  fontSize: size.width * 0.07,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Uso consciente del celular',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.text3Dark
                                      : AppColors.text3Light,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // MIDDLE: Onboarding card
                Expanded(
                  child: FadeTransition(
                    opacity: _pageOpacity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: 24,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, anim) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.15, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: _OnboardCard(
                          key: ValueKey(_currentPage),
                          data: _pages[_currentPage],
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ),
                ),

                // BOTTOM: Dots + Button
                SlideTransition(
                  position: _slideUp,
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        size.width * 0.06,
                        0,
                        size.width * 0.06,
                        32,
                      ),
                      child: Column(
                        children: [
                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: i == _currentPage ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: i == _currentPage
                                      ? const LinearGradient(
                                          colors: AppColors.gradient1)
                                      : null,
                                  color: i != _currentPage
                                      ? (isDark
                                          ? AppColors.border2Dark
                                          : AppColors.border2Light)
                                      : null,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          GradientButton(
                            text: _currentPage < _pages.length - 1
                                ? 'Siguiente'
                                : 'Comenzar',
                            onTap: _nextPage,
                            colors: _pages[_currentPage].gradient,
                          ),
                          const SizedBox(height: 16),
                          if (_currentPage < _pages.length - 1)
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const LoginScreen(),
                                      transitionsBuilder: (_, anim, __, child) =>
                                          FadeTransition(
                                            opacity: anim,
                                            child: child,
                                          ),
                                    ),
                                  ),
                              child: Text(
                                'Saltar',
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark
                                      ? AppColors.text3Dark
                                      : AppColors.text3Light,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardData {
  final String icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  const _OnboardData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardCard extends StatelessWidget {
  final _OnboardData data;
  final bool isDark;

  const _OnboardCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GlassCard(
      padding: EdgeInsets.all(size.width * 0.07),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: size.width * 0.28,
            height: size.width * 0.28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(size.width * 0.08),
              boxShadow: [
                BoxShadow(
                  color: data.gradient[0].withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                data.icon,
                style: TextStyle(fontSize: size.width * 0.11),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.05),
          GradientText(
            data.title,
            colors: data.gradient,
            style: GoogleFonts.sora(
              fontSize: size.width * 0.065,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? AppColors.text2Dark : AppColors.text2Light,
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
