import 'dart:math';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _minSplashDuration = Duration(seconds: 6);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  late final AnimationController _bubblesController;
  late final AnimationController _sheenController;
  final List<_BubbleData> _bubbles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _initBubbles();
    _startFlow();
  }

  void _initBubbles() {
    final rnd = Random(42);
    // Create a set of bubbles with varying sizes, horizontal positions and speeds
    for (int i = 0; i < 8; i++) {
      _bubbles.add(_BubbleData(
        xPct: rnd.nextDouble(),
        yPct: 0.2 + rnd.nextDouble() * 0.6,
        size: 18 + rnd.nextDouble() * 42,
        speed: 0.6 + rnd.nextDouble() * 1.4,
        dxPhase: rnd.nextDouble() * pi * 2,
        dyPhase: rnd.nextDouble() * pi * 2,
        color: (i % 2 == 0)
            ? AppColors.limeGreen.withAlpha(120)
            : AppColors.lightBlue.withAlpha(110),
      ));
    }
  }

  Future<void> _startFlow() async {
    final hasSessionFuture = AuthService.hasActiveSession();
    await Future.delayed(_minSplashDuration);
    final hasSession = await hasSessionFuture;

    if (!mounted) return;

    final next = hasSession ? const MainShell() : const AuthScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => next,
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubblesController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              // decorative static large circles
              Positioned(
                top: -60,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.limeGreen.withAlpha(35),
                  ),
                ),
              ),
              Positioned(
                bottom: -70,
                right: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightBlue.withAlpha(35),
                  ),
                ),
              ),
              // animated soap-bubble layer: gentle floating in both axes with sheen + sparkles
              AnimatedBuilder(
                animation: _bubblesController,
                builder: (_, __) {
                  return AnimatedBuilder(
                    animation: _sheenController,
                    builder: (_, __) {
                      return Stack(
                        children: _bubbles.map((b) {
                          final t = (_bubblesController.value * b.speed + 0.0001) % 1.0;
                          final angle = t * 2 * pi;
                          // central position with small orbit offsets
                          final orbitX = sin(angle + b.dxPhase) * (width * 0.06);
                          final orbitY = cos(angle + b.dyPhase) * (height * 0.04);
                          final x = (b.xPct * width) + orbitX;
                          final y = (b.yPct * height) + orbitY;
                          // subtle scale (pulsing like a soap bubble)
                          final scale = 0.92 + 0.12 * (0.5 + 0.5 * sin(angle + b.dxPhase));
                          final opacity = (0.35 + 0.65 * (0.6 + 0.4 * sin(angle - b.dyPhase))).clamp(0.12, 0.95);

                          // sheen rotation
                          final sheenAngle = _sheenController.value * 2 * pi;

                          return Positioned(
                            left: (x - b.size / 2).clamp(-b.size, width - b.size),
                            top: (y - b.size / 2).clamp(-b.size, height - b.size),
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: SizedBox(
                                  width: b.size,
                                  height: b.size,
                                  child: ClipOval(
                                    child: Stack(
                                      children: [
                                        // base bubble
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: RadialGradient(
                                              center: const Alignment(-0.3, -0.4),
                                              radius: 0.9,
                                              colors: [
                                                Colors.white.withOpacity(0.95),
                                                b.color.withOpacity(0.28),
                                                b.color.withOpacity(0.12),
                                              ],
                                              stops: const [0.0, 0.18, 1.0],
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.28),
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        // moving sheen overlay
                                        Transform.rotate(
                                          angle: sheenAngle,
                                          child: Center(
                                            child: Container(
                                              width: b.size * 1.6,
                                              height: b.size * 0.5,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.white.withOpacity(0.0),
                                                    Colors.white.withOpacity(0.55),
                                                    Colors.white.withOpacity(0.0),
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // tiny sparkle that drifts across the bubble
                                        Positioned(
                                          left: (b.size * 0.35) + sin(angle * 4 + b.dxPhase) * (b.size * 0.18),
                                          top: (b.size * 0.18) + cos(angle * 4 + b.dyPhase) * (b.size * 0.12),
                                          child: Opacity(
                                            opacity: (0.2 + 0.8 * (0.5 + 0.5 * sin(angle * 3 - b.dyPhase))).clamp(0.0, 1.0),
                                            child: Container(
                                              width: max(2.0, b.size * 0.12),
                                              height: max(2.0, b.size * 0.12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.95),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.7),
                                                    blurRadius: 6,
                                                    spreadRadius: 0.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppGradients.main,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkBlue.withAlpha(45),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(child: AppLogo(size: 76)),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Inclúyeme',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Educación inclusiva para todos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                              ),
                        ),
                        const SizedBox(height: 34),
                        const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BubbleData {
  final double xPct; // horizontal position as percentage
  final double yPct; // vertical central position as percentage
  final double size;
  final double speed;
  final double dxPhase;
  final double dyPhase;
  final Color color;

  _BubbleData({
    required this.xPct,
    required this.yPct,
    required this.size,
    required this.speed,
    required this.dxPhase,
    required this.dyPhase,
    required this.color,
  });
}

