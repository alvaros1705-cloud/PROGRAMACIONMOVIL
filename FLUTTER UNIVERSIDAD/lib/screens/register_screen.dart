// lib/screens/register_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Registro con Firebase: Email/Password + Google Sign-In
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late List<Animation<Offset>> _slides;
  late List<Animation<double>> _fades;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _acceptTerms = false;

  String? _selectedProfile;
  final _profiles = [
    ('🎓', 'Estudiante'),
    ('💼', 'Profesional'),
    ('👨‍👩‍👧', 'Familia'),
    ('✨', 'Bienestar'),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slides = List.generate(7, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.08, 0.5 + i * 0.07, curve: Curves.easeOutCubic),
      ));
    });
    _fades = List.generate(7, (i) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: Interval(i * 0.08, 0.5 + i * 0.07, curve: Curves.easeOut),
      ));
    });
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
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
          child: child,
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
  // REGISTRO EMAIL / PASSWORD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showSnackBar('Debes aceptar los términos para continuar.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.registerWithEmailPassword(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      _showSnackBar('¡Cuenta creada exitosamente! 🎉', isError: false);
      await Future.delayed(const Duration(milliseconds: 600));
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
  // REGISTRO CON GOOGLE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _registerWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        _goToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(AuthService.translateError(e.code));
    } catch (e) {
      _showSnackBar('No se pudo registrar con Google.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    _animated(
                      0,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                                Icons.arrow_back_ios_new_rounded,
                                color: isDark
                                    ? AppColors.text1Dark
                                    : AppColors.text1Light,
                                size: 16,
                              ),
                            ),
                          ),
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
                    SizedBox(height: size.height * 0.03),

                    // ── Título ───────────────────────────────────────────────
                    _animated(
                      1,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GradientText(
                            'Crea tu cuenta ✨',
                            colors: AppColors.gradient4,
                            style: GoogleFonts.sora(
                              fontSize: isSmall ? 26 : 30,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Empieza tu camino hacia el bienestar digital.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.text2Dark
                                  : AppColors.text2Light,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),

                    // ── Selector de perfil ───────────────────────────────────
                    _animated(
                      2,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tu perfil',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.text3Dark
                                  : AppColors.text3Light,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: _profiles.map((p) {
                              final isSelected = _selectedProfile == p.$2;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedProfile = p.$2),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: AppColors.gradient4,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : (isDark
                                              ? AppColors.cardDark
                                              : AppColors.cardLight),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : (isDark
                                                ? AppColors.border2Dark
                                                : AppColors.border2Light),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.accent
                                                    .withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(p.$1,
                                            style: const TextStyle(
                                                fontSize: 20)),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.$2,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                    ? AppColors.text2Dark
                                                    : AppColors.text2Light),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Campos del formulario ────────────────────────────────
                    _animated(
                      3,
                      GlassCard(
                        child: Column(
                          children: [
                            // Nombre
                            TextFormField(
                              controller: _nameCtrl,
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark
                                    ? AppColors.text1Dark
                                    : AppColors.text1Light,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nombre completo',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: isDark
                                      ? AppColors.text3Dark
                                      : AppColors.text3Light,
                                  size: 20,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Ingresa tu nombre'
                                  : null,
                            ),
                            const SizedBox(height: 14),
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
                                    padding: const EdgeInsets.only(right: 14),
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
                                  return 'Ingresa una contraseña';
                                }
                                if (v.length < 6) {
                                  return 'Mínimo 6 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            // Confirmar contraseña
                            TextFormField(
                              controller: _confirmCtrl,
                              obscureText: _obscureConfirm,
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark
                                    ? AppColors.text1Dark
                                    : AppColors.text1Light,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Confirmar contraseña',
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: isDark
                                      ? AppColors.text3Dark
                                      : AppColors.text3Light,
                                  size: 20,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() =>
                                      _obscureConfirm = !_obscureConfirm),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 14),
                                    child: Icon(
                                      _obscureConfirm
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
                                  return 'Confirma tu contraseña';
                                }
                                if (v != _passCtrl.text) {
                                  return 'Las contraseñas no coinciden';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Términos y condiciones ────────────────────────────────
                    _animated(
                      4,
                      GestureDetector(
                        onTap: () =>
                            setState(() => _acceptTerms = !_acceptTerms),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                gradient: _acceptTerms
                                    ? const LinearGradient(
                                        colors: AppColors.gradient1)
                                    : null,
                                color: _acceptTerms
                                    ? null
                                    : (isDark
                                        ? AppColors.cardDark
                                        : AppColors.cardLight),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _acceptTerms
                                      ? Colors.transparent
                                      : (isDark
                                          ? AppColors.border2Dark
                                          : AppColors.border2Light),
                                  width: 1.5,
                                ),
                              ),
                              child: _acceptTerms
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Acepto los ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.text2Dark
                                        : AppColors.text2Light,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Términos de uso',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' y la ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.text2Dark
                                            : AppColors.text2Light,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Política de privacidad',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Botón Crear cuenta ───────────────────────────────────
                    _animated(
                      5,
                      _isLoading
                          ? Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: AppColors.gradient4),
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
                              text: 'Crear cuenta',
                              onTap: _register,
                              colors: AppColors.gradient4,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ── Botón Google ─────────────────────────────────────────
                    _animated(
                      5,
                      _isGoogleLoading
                          ? Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.border2Dark
                                      : AppColors.border2Light,
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _registerWithGoogle,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
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
                                      'Registrarse con Google',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.text1Dark
                                            : AppColors.text1Light,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 28),

                    // ── Link a Login ─────────────────────────────────────────
                    _animated(
                      6,
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.text2Dark
                                  : AppColors.text2Light,
                            ),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: AppColors.gradient4,
                                    ).createShader(bounds),
                                    child: Text(
                                      'Inicia sesión',
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}