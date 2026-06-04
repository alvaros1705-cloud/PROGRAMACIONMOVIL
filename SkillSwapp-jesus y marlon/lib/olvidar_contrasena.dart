import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OlvidarContrasenaScreen extends StatefulWidget {
  const OlvidarContrasenaScreen({super.key});

  @override
  State<OlvidarContrasenaScreen> createState() => _OlvidarContrasenaScreenState();
}

class _OlvidarContrasenaScreenState extends State<OlvidarContrasenaScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Colores de marca
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color secondaryBlue = const Color(0xFF00A99D);
  final Color darkText = const Color(0xFF334A5F);

  // Animaciones
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _jumpController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enlace de recuperación enviado a tu correo'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error';
      if (e.code == 'user-not-found') {
        message = 'No existe un usuario con este correo';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo
          Image.asset(
            'assets/Fondo_SkillSwap.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.05)),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  
                  // Botón Volver
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: darkText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header / Logo
                  _buildAnimatedHeader(),

                  const SizedBox(height: 50),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recuperar Contraseña",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Form(
                            key: _formKey,
                            child: _buildEmailField(),
                          ),

                          const SizedBox(height: 40),

                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _jumpController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _jumpController.value),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/imagen_skillwasp.jpeg',
                  height: 80,
                  width: 80,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Skill",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: primaryGreen,
                ),
              ),
              TextSpan(
                text: "Swap",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: secondaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: "Correo electrónico",
          prefixIcon: Icon(Icons.email_outlined, color: primaryGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'El correo es obligatorio';
          if (!value.contains('@')) return 'Ingresa un correo válido';
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedScale(
      scale: _isSubmitting ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleResetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: primaryGreen.withOpacity(0.5),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  "ENVIAR ENLACE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
