import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'splash_screen.dart';

// ─────────────────────────────────────────────
//  MODELO DE PARTÍCULA
// ─────────────────────────────────────────────
class _Particle {
  Offset position;
  Offset velocity;
  double size;
  double life;
  Color color;

  _Particle({required Offset center, required Random rng})
      : position = center,
        velocity = Offset(
          (rng.nextDouble() - 0.5) * 14,
          (rng.nextDouble() - 0.5) * 14,
        ),
        size = rng.nextDouble() * 7 + 2,
        life = 1.0,
        color = [
          const Color(0xFF7B6FE8),
          const Color(0xFF4FC3F7),
          const Color(0xFF40E0D0),
          const Color(0xFFB39DDB),
          const Color(0xFF80DEEA),
          const Color(0xFFCE93D8),
        ][rng.nextInt(6)];

  void update() {
    position += velocity;
    velocity *= 0.91;
    life -= 0.018;
  }

  bool get isDead => life <= 0;
}

// ─────────────────────────────────────────────
//  PAINTER: ONDAS DE PULSO
// ─────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final double t;
  _WavePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = size.longestSide * 0.72;
    for (int i = 0; i < 6; i++) {
      final wave = ((t + i / 6) % 1.0);
      final r = maxR * wave;
      final alpha = (1.0 - wave) * 0.22;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = const Color(0xFF7B6FE8).withOpacity(alpha),
      );
      canvas.drawCircle(
        c,
        r * 0.82,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = const Color(0xFF40E0D0).withOpacity(alpha * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter o) => o.t != t;
}

// ─────────────────────────────────────────────
//  PAINTER: PARTÍCULAS
// ─────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        p.position,
        p.size * p.life,
        Paint()
          ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => true;
}

// ─────────────────────────────────────────────
//  WIDGET PRINCIPAL
// ─────────────────────────────────────────────
class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash>
    with TickerProviderStateMixin {
  // ── Controladores ─────────────────────────────────────────────────────────
  late AnimationController _waveCtrl;  // ondas infinitas
  late AnimationController _burstCtrl; // tick para mover partículas
  late AnimationController _logoCtrl;  // logo entra
  late AnimationController _exitCtrl;  // logo sale

  // ── Animaciones ───────────────────────────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _exitScale;
  late Animation<double> _exitFade;
  late Animation<double> _bgFade;

  // ── Partículas ────────────────────────────────────────────────────────────
  final List<_Particle> _particles = [];
  final _rng = Random();
  Offset _center = Offset.zero;

  // ── Audio ─────────────────────────────────────────────────────────────────
  final _player = AudioPlayer();

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Ondas de fondo — loop infinito
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Burst de partículas — dispara una vez
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo entra con rebote elástico
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Salida: encoge + desvanece
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _logoScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
    _subtitleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );
    _exitScale = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInBack),
    );
    _exitFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _bgFade = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  // ── Reproduce el sonido ───────────────────────────────────────────────────
  Future<void> _playSound() async {
    try {
      await _player.setVolume(0.8);
      await _player.play(AssetSource('sounds/splash_sound.mp3'));
    } catch (e) {
      // Si el archivo no existe, continúa sin sonido
      debugPrint('Audio no disponible: $e');
    }
  }

  // ── Secuencia principal ───────────────────────────────────────────────────
  Future<void> _runSequence() async {
    final size = MediaQuery.of(context).size;
    _center = Offset(size.width / 2, size.height / 2);

    // Sonido + partículas al mismo tiempo
    _playSound();
    _spawnBurst();
    _burstCtrl.addListener(_tickParticles);
    _burstCtrl.forward();

    // Logo aparece 250ms después
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _logoCtrl.forward();

    // Mantiene el splash 2.6s y sale
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    await _exitCtrl.forward();
    if (!mounted) return;

    // Navega al onboarding
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SplashScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Genera partículas desde el centro ─────────────────────────────────────
  void _spawnBurst() {
    for (int i = 0; i < 90; i++) {
      _particles.add(_Particle(center: _center, rng: _rng));
    }
  }

  // ── Actualiza partículas cada frame ───────────────────────────────────────
  void _tickParticles() {
    if (!mounted) return;
    setState(() {
      for (final p in _particles) p.update();
      _particles.removeWhere((p) => p.isDead);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _waveCtrl.dispose();
    _burstCtrl.dispose();
    _logoCtrl.dispose();
    _exitCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, __) => Opacity(
        opacity: _bgFade.value,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0B2A),
          body: Stack(
            children: [
              // ── Gradiente radial de fondo ────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.3,
                    colors: [Color(0xFF1E1760), Color(0xFF0D0B2A)],
                  ),
                ),
              ),

              // ── Ondas de pulso ───────────────────────────────────────────
              AnimatedBuilder(
                animation: _waveCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _WavePainter(_waveCtrl.value),
                  child: const SizedBox.expand(),
                ),
              ),

              // ── Partículas de explosión ──────────────────────────────────
              CustomPaint(
                painter: _ParticlePainter(List.from(_particles)),
                child: const SizedBox.expand(),
              ),

              // ── Logo + textos ────────────────────────────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl, _exitCtrl]),
                  builder: (_, __) {
                    final isExiting =
                        _exitCtrl.isAnimating || _exitCtrl.value > 0;
                    final scale =
                        isExiting ? _exitScale.value : _logoScale.value;
                    final fade =
                        isExiting ? _exitFade.value : _logoFade.value;
                    final subFade =
                        isExiting ? _exitFade.value : _subtitleFade.value;

                    return Opacity(
                      opacity: fade.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale.clamp(0.0, 1.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Halo + Logo ──────────────────────────────
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Halo pulsante detrás del logo
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.9, end: 1.08),
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.easeInOut,
                                  builder: (_, v, __) => Transform.scale(
                                    scale: v,
                                    child: Container(
                                      width: 210,
                                      height: 210,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF7B6FE8)
                                                .withOpacity(0.35),
                                            blurRadius: 70,
                                            spreadRadius: 20,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF40E0D0)
                                                .withOpacity(0.2),
                                            blurRadius: 90,
                                            spreadRadius: 35,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Logo de la app
                                Image.asset(
                                  'assets/logo.png',
                                  width: 165,
                                  height: 165,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // ── Nombre con gradiente ─────────────────────
                            ShaderMask(
                              shaderCallback: (b) => const LinearGradient(
                                colors: [
                                  Color(0xFF8B80F8),
                                  Color(0xFF40E0D0),
                                ],
                              ).createShader(b),
                              child: const Text(
                                'MindfulPhone',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ── Subtítulo con fade propio ────────────────
                            Opacity(
                              opacity: subFade.clamp(0.0, 1.0),
                              child: Text(
                                'USO CONSCIENTE DEL CELULAR',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 3.8,
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}