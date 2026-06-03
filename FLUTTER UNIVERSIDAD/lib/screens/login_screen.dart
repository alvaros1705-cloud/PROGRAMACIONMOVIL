// lib/screens/login_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Login con Firebase: Email/Password + Google Sign-In + Reset Password
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // ── Animaciones ────────────────────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>> _fades;

  // ── Controladores ──────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _obscurePass = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slides = List.generate(6, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.1, 0.6 + i * 0.07, curve: Curves.easeOutCubic),
      ));
    });
    _fades = List.generate(6, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.1, 0.6 + i * 0.07, curve: Curves.easeOut),
      ));
    });
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _goToDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN EMAIL / PASSWORD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailPassword(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      _showSnackBar(AuthService.translateError(e.code));
    } catch (e) {
      _showSnackBar('Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN-IN
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loginWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        _goToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(AuthService.translateError(e.code));
    } catch (e) {
      _showSnackBar('No se pudo iniciar sesión con Google.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD — muestra un dialog para pedir el email
  // ─────────────────────────────────────────────────────────────────────────

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Restablecer contraseña',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? AppColors.text1Dark : AppColors.text1Light,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa tu correo y te enviaremos un enlace para crear una nueva contraseña.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? AppColors.text2Dark : AppColors.text2Light,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppColors.text1Dark : AppColors.text1Light,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'tu@correo.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isDark ? AppColors.text3Dark : AppColors.text3Light,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppColors.text3Dark : AppColors.text3Light,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final email = resetEmailCtrl.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await _authService.sendPasswordResetEmail(email);
                _showSnackBar(
                  '📧 Correo enviado a $email. Revisa tu bandeja.',
                  isError: false,
                );
              } on FirebaseAuthException catch (e) {
                _showSnackBar(AuthService.translateError(e.code));
              } catch (_) {
                _showSnackBar('No se pudo enviar el correo.');
              }
            },
            child: Text(
              'Enviar enlace',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANIMACIÓN HELPER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _animated(int idx, Widget child) {
    return SlideTransition(
      position: _slides[idx],
      child: FadeTransition(opacity: _fades[idx], child: child),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;

    return Scaffold(
      body: Stack(
        children: [
          const OrbsBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────────────────────────────────
                      _animated(
                        0,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: AppColors.gradient1,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('🧘',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GradientText(
                                  'MindfulPhone',
                                  colors: AppColors.gradient1,
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            // Toggle tema
                            GestureDetector(
                              onTap: themeProvider.toggle,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
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
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),

                      // ── Saludo según la jornada ────────────────────────────
                      _animated(
                        1,
                        _GreetingWidget(isDark: isDark, isSmall: isSmall),
                      ),
                      SizedBox(height: size.height * 0.04),

                      // ── Formulario ─────────────────────────────────────────
                      _animated(
                        2,
                        GlassCard(
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark
                                      ? AppColors.text1Dark
                                      : AppColors.text1Light,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Correo electrónico',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: isDark
                                        ? AppColors.text3Dark
                                        : AppColors.text3Light,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(v)) {
                                    return 'Correo inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              // Contraseña
                              TextFormField(
                                controller: _passCtrl,
                                obscureText: _obscurePass,
                                style: GoogleFonts.plusJakartaSans(
                                  color: isDark
                                      ? AppColors.text1Dark
                                      : AppColors.text1Light,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Contraseña',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: isDark
                                        ? AppColors.text3Dark
                                        : AppColors.text3Light,
                                    size: 20,
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                        () => _obscurePass = !_obscurePass),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 14),
                                      child: Icon(
                                        _obscurePass
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: isDark
                                            ? AppColors.text3Dark
                                            : AppColors.text3Light,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              // ¿Olvidaste tu contraseña?
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Botón Login ────────────────────────────────────────
                      _animated(
                        3,
                        _isLoading
                            ? Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.gradient1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              )
                            : GradientButton(
                                text: 'Iniciar Sesión',
                                onTap: _login,
                              ),
                      ),
                      const SizedBox(height: 20),

                      // ── Divisor ────────────────────────────────────────────
                      _animated(
                        4,
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? AppColors.border2Dark
                                    : AppColors.border2Light,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'o continúa con',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.text3Dark
                                      : AppColors.text3Light,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark
                                    ? AppColors.border2Dark
                                    : AppColors.border2Light,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Botón Google ───────────────────────────────────────
                      _animated(
                        4,
                        _GoogleButton(
                          isDark: isDark,
                          isLoading: _isGoogleLoading,
                          onTap: _loginWithGoogle,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Registro link ──────────────────────────────────────
                      _animated(
                        5,
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.text2Dark
                                    : AppColors.text2Light,
                              ),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) =>
                                              const RegisterScreen(),
                                          transitionsBuilder:
                                              (_, anim, __, child) =>
                                                  SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1, 0),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: anim,
                                              curve: Curves.easeOutCubic,
                                            )),
                                            child: child,
                                          ),
                                          transitionDuration:
                                              const Duration(milliseconds: 400),
                                        ),
                                      );
                                    },
                                    child: ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: AppColors.gradient1,
                                      ).createShader(bounds),
                                      child: Text(
                                        'Regístrate',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Saludo por jornada (Buenos días / Buenas tardes / Buenas noches)
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingWidget extends StatelessWidget {
  final bool isDark;
  final bool isSmall;

  const _GreetingWidget({required this.isDark, required this.isSmall});

  static String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '¡Buenos días! ☀️';
    if (hour >= 12 && hour < 19) return '¡Buenas tardes! 🌤️';
    return '¡Buenas noches! 🌙';
  }

  static String _getSubtitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Empieza el día con conciencia digital.\nInicia sesión para continuar.';
    }
    if (hour >= 12 && hour < 19) {
      return 'Una tarde más para mejorar tus hábitos.\nInicia sesión para continuar.';
    }
    return 'Cierra el día revisando tu bienestar.\nInicia sesión para continuar.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          _getGreeting(),
          colors: AppColors.gradient1,
          style: GoogleFonts.sora(
            fontSize: isSmall ? 26 : 30,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _getSubtitle(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isDark ? AppColors.text2Dark : AppColors.text2Light,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Botón de Google con estado de carga
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleButton extends StatefulWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleButton({
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                widget.isDark ? AppColors.border2Dark : AppColors.border2Light,
            width: 1.5,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
                  ? AppColors.border2Dark
                  : AppColors.border2Light,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continuar con Google',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark
                      ? AppColors.text1Dark
                      : AppColors.text1Light,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}