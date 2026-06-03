// lib/screens/dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Dashboard con datos reales del usuario desde Firestore
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/common_widgets.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _entryCtrl;
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  // ── Datos reales ─────────────────────────────────────────────────────────
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  UserModel? _user;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ringAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic),
    );
    _cardFades = List.generate(8, (i) {
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.08, min(0.5 + i * 0.1, 1.0),
            curve: Curves.easeOut),
      ));
    });
    _cardSlides = List.generate(8, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.08, min(0.5 + i * 0.1, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    _loadUser();
  }

  // ── Carga el usuario desde Firestore ──────────────────────────────────────
  Future<void> _loadUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final user = await _firestoreService.getUser(firebaseUser.uid);
      if (mounted) {
        setState(() {
          _user = user;
          _loadingUser = false;
        });
      }
    } else {
      setState(() => _loadingUser = false);
    }

    // Inicia animaciones una vez cargado
    _entryCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ringCtrl.forward();
    });
  }

  // ── Cerrar sesión ──────────────────────────────────────────────────────────
  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int idx, Widget child) {
    return SlideTransition(
      position: _cardSlides[idx],
      child: FadeTransition(opacity: _cardFades[idx], child: child),
    );
  }

  // ── Saludo por hora ────────────────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Buenos días ☀️';
    if (h >= 12 && h < 19) return 'Buenas tardes 🌤️';
    return 'Buenas noches 🌕';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final size = MediaQuery.of(context).size;

    // Nombre a mostrar
    final displayName = _user?.firstName ??
        FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ??
        'Usuario';

    // Iniciales para el avatar
    final initials = _user?.initials ??
        (FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true
            ? FirebaseAuth.instance.currentUser!.displayName![0].toUpperCase()
            : 'U');

    // Foto de Google (si tiene)
    final photoUrl = _user?.photoUrl ??
        FirebaseAuth.instance.currentUser?.photoURL;

    return Scaffold(
      body: Stack(
        children: [
          const OrbsBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ─── HEADER con datos reales ───────────────────────
                        _animated(
                          0,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.text3Dark
                                          : AppColors.text3Light,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GradientText(
                                    'Hola, $displayName 👋',
                                    colors: AppColors.gradient1,
                                    style: GoogleFonts.sora(
                                      fontSize: size.width * 0.055,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Theme toggle
                                  GestureDetector(
                                    onTap: themeProvider.toggle,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.cardDark
                                            : AppColors.cardLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.border2Dark
                                              : AppColors.border2Light,
                                        ),
                                      ),
                                      child: Icon(
                                        isDark
                                            ? Icons.wb_sunny_rounded
                                            : Icons.nightlight_round,
                                        color: isDark
                                            ? AppColors.accent4
                                            : AppColors.accent,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Avatar: foto de Google o iniciales
                                  GestureDetector(
                                    onTap: () => _showProfileMenu(context,
                                        isDark: isDark,
                                        displayName: displayName),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: photoUrl == null
                                            ? const LinearGradient(
                                                colors: AppColors.gradient1,
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: photoUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                photoUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    _AvatarText(
                                                        initials: initials),
                                              ),
                                            )
                                          : _AvatarText(initials: initials),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── Chip de perfil (si tiene) ──────────────────────
                        if (_user?.profile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _animated(
                              0,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: AppColors.gradient1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _user!.profile!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ─── MAIN CARD: Ring + Stats ───────────────────────
                        _animated(
                          1,
                          GlassCard(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Animated ring
                                    AnimatedBuilder(
                                      animation: _ringAnim,
                                      builder: (_, __) {
                                        return SizedBox(
                                          width: size.width * 0.32,
                                          height: size.width * 0.32,
                                          child: CustomPaint(
                                            painter: _RingPainter(
                                              progress:
                                                  _ringAnim.value * 0.65,
                                              isDark: isDark,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '2h 34m',
                                                    style: GoogleFonts.sora(
                                                      fontSize:
                                                          size.width * 0.05,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: isDark
                                                          ? AppColors.text1Dark
                                                          : AppColors
                                                              .text1Light,
                                                    ),
                                                  ),
                                                  Text(
                                                    'hoy',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 11,
                                                      color: isDark
                                                          ? AppColors.text3Dark
                                                          : AppColors
                                                              .text3Light,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Uso de hoy',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: isDark
                                                  ? AppColors.text3Dark
                                                  : AppColors.text3Light,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GradientText(
                                            '65% del límite',
                                            colors: AppColors.gradient1,
                                            style: GoogleFonts.sora(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _StatRow(
                                            label: 'Desbloqueos',
                                            value: '47',
                                            icon: '🔓',
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: 10),
                                          _StatRow(
                                            label: 'Sesión más larga',
                                            value: '28m',
                                            icon: '⏱️',
                                            isDark: isDark,
                                          ),
                                          const SizedBox(height: 10),
                                          _StatRow(
                                            label: 'Apps usadas',
                                            value: '12',
                                            icon: '📱',
                                            isDark: isDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _WeekChart(isDark: isDark),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── QUICK ACTIONS ─────────────────────────────────
                        _animated(
                          2,
                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon: '🎯',
                                  label: 'Modo Focus',
                                  gradient: AppColors.gradient1,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: '📊',
                                  label: 'Estadísticas',
                                  gradient: AppColors.gradient4,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _QuickAction(
                                  icon: '⚙️',
                                  label: 'Límites',
                                  gradient: AppColors.gradient2,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Apps más usadas ───────────────────────────────
                        _animated(
                          3,
                          _SectionHeader(
                            title: 'Apps más usadas',
                            action: 'Ver todas →',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animated(
                          3,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: const [
                                _AppUsageCard(
                                  emoji: '📸',
                                  name: 'Instagram',
                                  time: '1h 24m',
                                  percent: 0.85,
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFFF9A3C)
                                  ],
                                  status: '⚠️ Alto',
                                  statusColor: AppColors.red,
                                ),
                                SizedBox(width: 12),
                                _AppUsageCard(
                                  emoji: '💬',
                                  name: 'WhatsApp',
                                  time: '48m',
                                  percent: 0.48,
                                  colors: AppColors.gradient3,
                                  status: '✓ OK',
                                  statusColor: AppColors.accent3,
                                ),
                                SizedBox(width: 12),
                                _AppUsageCard(
                                  emoji: '🎵',
                                  name: 'Spotify',
                                  time: '32m',
                                  percent: 0.32,
                                  colors: AppColors.gradient1,
                                  status: '✓ OK',
                                  statusColor: AppColors.accent2,
                                ),
                                SizedBox(width: 12),
                                _AppUsageCard(
                                  emoji: '▶️',
                                  name: 'YouTube',
                                  time: '28m',
                                  percent: 0.93,
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF9A3C)
                                  ],
                                  status: '⚡ Límite',
                                  statusColor: AppColors.orange,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Límites activos ───────────────────────────────
                        _animated(
                          4,
                          _SectionHeader(
                            title: 'Límites activos',
                            action: '+ Agregar',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animated(
                          5,
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _LimitItem(
                                  emoji: '📸',
                                  name: 'Instagram',
                                  used: '1h 24m',
                                  total: '1h 30m',
                                  percent: 0.85,
                                  colors: const [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFFF9A3C)
                                  ],
                                  badgeText: '85%',
                                  badgeType: _BadgeType.warn,
                                  isDark: isDark,
                                ),
                                Divider(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                    height: 24),
                                _LimitItem(
                                  emoji: '🎮',
                                  name: 'Juegos',
                                  used: '24m',
                                  total: '1h',
                                  percent: 0.4,
                                  colors: AppColors.gradient1,
                                  badgeText: '40%',
                                  badgeType: _BadgeType.ok,
                                  isDark: isDark,
                                ),
                                Divider(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                    height: 24),
                                _LimitItem(
                                  emoji: '▶️',
                                  name: 'YouTube',
                                  used: '28m',
                                  total: '30m',
                                  percent: 0.93,
                                  colors: const [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFFF9A3C)
                                  ],
                                  badgeText: '93%',
                                  badgeType: _BadgeType.over,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Recomendaciones ───────────────────────────────
                        _animated(
                          6,
                          _SectionHeader(
                            title: 'Para ti hoy 🌱',
                            action: 'Ver más',
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animated(
                          6,
                          Column(
                            children: [
                              _TipCard(
                                gradient: AppColors.gradient3,
                                icon: '🧘',
                                title: 'Toma un descanso',
                                subtitle:
                                    'Llevas 45 min seguidos. Descansa 5 min.',
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _TipCard(
                                gradient: AppColors.gradient1,
                                icon: '🎯',
                                title: 'Modo Focus disponible',
                                subtitle:
                                    'Activa el modo focus para concentrarte.',
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        // ─── Racha semanal ─────────────────────────────────
                        _animated(
                          7,
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: GlassCard(
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFD166),
                                          Color(0xFFFF9A3C)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Text('🔥',
                                          style: TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '¡Racha de ${_user?.streakDays ?? 0} días! 🎉',
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? AppColors.text1Dark
                                                : AppColors.text1Light,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cumpliste tu meta toda la semana.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: isDark
                                                ? AppColors.text2Dark
                                                : AppColors.text2Light,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: AppColors.accent3),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── BOTTOM NAV ─────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomNav(
              currentIndex: _navIndex,
              isDark: isDark,
              onTap: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu de perfil al tocar el avatar ──────────────────────────────────────
  void _showProfileMenu(BuildContext context,
      {required bool isDark, required String displayName}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info del usuario
            Text(
              displayName,
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.text1Dark : AppColors.text1Light,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _user?.email ??
                  FirebaseAuth.instance.currentUser?.email ??
                  '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? AppColors.text3Dark : AppColors.text3Light,
              ),
            ),
            if (_user?.profile != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.gradient1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _user!.profile!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Botón cerrar sesión
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.red.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        color: AppColors.red, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── AVATAR TEXT ─────────────────────────────────────────────────────────────
class _AvatarText extends StatelessWidget {
  final String initials;
  const _AvatarText({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ─── RING PAINTER ─────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _RingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = (isDark ? AppColors.border2Dark : AppColors.border2Light)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi,
      colors: const [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    );
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, fgPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── WEEK CHART ───────────────────────────────────────────────────────────────
class _WeekChart extends StatelessWidget {
  final bool isDark;
  const _WeekChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const heights = [0.5, 0.75, 0.4, 0.9, 0.65, 0.3, 0.2];
    const isToday = [false, false, false, false, true, false, false];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Esta semana',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.text3Dark : AppColors.text3Light,
                )),
            Text('Prom: 3h 45m/día',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppColors.text3Dark : AppColors.text3Light,
                )),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: 44 * heights[i],
                            decoration: BoxDecoration(
                              gradient: isToday[i]
                                  ? const LinearGradient(
                                      colors: AppColors.gradient1,
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : null,
                              color: isToday[i]
                                  ? null
                                  : (isDark
                                      ? AppColors.card2Dark
                                      : AppColors.card2Light),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(days[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: isToday[i]
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isToday[i]
                                ? AppColors.accent
                                : (isDark
                                    ? AppColors.text3Dark
                                    : AppColors.text3Light),
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── STAT ROW ─────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final String label, value, icon;
  final bool isDark;
  const _StatRow(
      {required this.label,
      required this.value,
      required this.icon,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppColors.text3Dark : AppColors.text3Light,
                ))),
        Text(value,
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.text1Dark : AppColors.text1Light,
            )),
      ],
    );
  }
}

// ─── QUICK ACTION ─────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String icon, label;
  final List<Color> gradient;
  final bool isDark;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.gradient,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withOpacity(0.15)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: gradient[0].withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.text1Dark : AppColors.text1Light,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, action;
  final bool isDark;
  const _SectionHeader(
      {required this.title, required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.text1Dark : AppColors.text1Light,
            )),
        GestureDetector(
          onTap: () {},
          child: Text(action,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              )),
        ),
      ],
    );
  }
}

// ─── APP USAGE CARD ───────────────────────────────────────────────────────────
class _AppUsageCard extends StatelessWidget {
  final String emoji, name, time, status;
  final double percent;
  final List<Color> colors;
  final Color statusColor;

  const _AppUsageCard({
    required this.emoji,
    required this.name,
    required this.time,
    required this.percent,
    required this.colors,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.border2Dark : AppColors.border2Light,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors[0].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 18))),
              ),
              Text(status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Text(time,
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.text1Dark : AppColors.text1Light,
              )),
          Text(name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: isDark ? AppColors.text3Dark : AppColors.text3Light,
              )),
          const SizedBox(height: 10),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? AppColors.card2Dark : AppColors.card2Light,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BADGE TYPE ───────────────────────────────────────────────────────────────
enum _BadgeType { ok, warn, over }

// ─── LIMIT ITEM ───────────────────────────────────────────────────────────────
class _LimitItem extends StatelessWidget {
  final String emoji, name, used, total, badgeText;
  final double percent;
  final List<Color> colors;
  final _BadgeType badgeType;
  final bool isDark;

  const _LimitItem({
    required this.emoji,
    required this.name,
    required this.used,
    required this.total,
    required this.percent,
    required this.colors,
    required this.badgeText,
    required this.badgeType,
    required this.isDark,
  });

  Color get _badgeColor {
    switch (badgeType) {
      case _BadgeType.ok:
        return AppColors.green;
      case _BadgeType.warn:
        return AppColors.orange;
      case _BadgeType.over:
        return AppColors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors[0].withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.text1Dark : AppColors.text1Light,
                  )),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.card2Dark
                            : AppColors.bg4Light,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percent.clamp(0, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$used / $total',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.text3Dark
                            : AppColors.text3Light,
                      )),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _badgeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(badgeText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _badgeColor,
              )),
        ),
      ],
    );
  }
}

// ─── TIP CARD ─────────────────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  final List<Color> gradient;
  final String icon, title, subtitle;
  final bool isDark;

  const _TipCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withOpacity(0.12)).toList(),
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gradient[0].withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.text1Dark : AppColors.text1Light,
                    )),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.text2Dark
                          : AppColors.text2Light,
                      height: 1.4,
                    )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: gradient[0].withOpacity(0.7)),
        ],
      ),
    );
  }
}

// ─── BOTTOM NAV ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;

  const _BottomNav(
      {required this.currentIndex,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🏠', 'Inicio'),
      ('📊', 'Stats'),
      ('⏱️', 'Focus'),
      ('🔔', 'Alertas'),
      ('👤', 'Perfil'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withOpacity(0.95)
            : AppColors.cardLight.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.border2Dark : AppColors.border2Light,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = currentIndex == i;
          final isFocus = i == 2;

          if (isFocus) {
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                width: 52,
                height: 44,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.gradient1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                    child: Text(items[i].$1,
                        style: const TextStyle(fontSize: 22))),
              ),
            );
          }

          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(items[i].$1,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(items[i].$2,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.accent
                            : (isDark
                                ? AppColors.text3Dark
                                : AppColors.text3Light),
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}