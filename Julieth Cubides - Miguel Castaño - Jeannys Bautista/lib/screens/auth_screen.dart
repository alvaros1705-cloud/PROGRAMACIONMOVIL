import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';
import 'main_shell.dart';

enum _AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePrimaryAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? error;

    if (_mode == _AuthMode.login) {
      error = await AuthService.login(email: email, password: password);
    } else {
      error = await AuthService.register(email: email, password: password);
    }

    if (!mounted) return;

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    _goToApp();
  }

  Future<void> _handleProviderLogin(String provider) async {
    setState(() => _isLoading = true);

    final providerKey = provider.toLowerCase();
    NativeSignInAttempt result;

    if (providerKey == 'google') {
      result = await AuthService.tryNativeGoogleSignIn();
    } else {
      result = const NativeSignInAttempt.failed('Proveedor no soportado.');
    }

    if (!mounted) return;

    if (result.wasCancelled) {
      setState(() => _isLoading = false);
      return;
    }

    if (result.error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Si llegamos aquí, la sesión ya está iniciada en Firebase por AuthService
    _goToApp();
  }


  Future<void> _handlePasswordReset() async {
    final result = await showDialog<_PasswordResetResult>(
      context: context,
      builder: (dialogContext) {
        return const _PasswordResetDialog();
      },
    );

    if (result == null || !mounted) return;

    final error = await AuthService.resetPassword(
      email: result.email,
      newPassword: result.newPassword,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Se ha enviado un correo para restablecer la contraseña.'),
        backgroundColor: AppColors.darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const MainShell(),
        transitionsBuilder: (_, animation, __, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(opacity: curve, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _setMode(_AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _isLoading = false;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeroCard(context),
                  const SizedBox(height: 18),
                  _buildModeToggle(context),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _buildAuthCard(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        gradient: AppGradients.main,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Center(child: AppLogo(size: 56)),
          ),
          const SizedBox(height: 18),
          Text(
            'Inclúyeme',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accede para continuar con toda la información educativa',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(230),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Iniciar sesión',
              selected: _mode == _AuthMode.login,
              onTap: () => _setMode(_AuthMode.login),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ModeButton(
              label: 'Registrarme',
              selected: _mode == _AuthMode.register,
              onTap: () => _setMode(_AuthMode.register),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey(_mode),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: isDark ? null : AppGradients.authCard,
        color: isDark ? Theme.of(context).cardColor : null,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            _buildSectionTitle(context),
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              decoration: _inputDecoration(
                label: 'Correo electrónico',
                hint: 'docente@incluyeme.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo electrónico';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: _mode == _AuthMode.login
                  ? TextInputAction.done
                  : TextInputAction.next,
              onFieldSubmitted: (_) {
                if (_mode == _AuthMode.login) {
                  _handlePrimaryAction();
                } else {
                  FocusScope.of(context).nextFocus();
                }
              },
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              decoration: _inputDecoration(
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'La contraseña debe tener al menos 6 caracteres';
                }
                return null;
              },
            ),
            if (_mode == _AuthMode.register) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handlePrimaryAction(),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
                decoration: _inputDecoration(
                  label: 'Confirmar contraseña',
                  hint: 'Repite tu contraseña',
                  icon: Icons.lock_person_outlined,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey[500],
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
            if (_mode == _AuthMode.login) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handlePasswordReset,
                  child: const Text('¿Olvidaste la contraseña?'),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: _isLoading ? null : AppGradients.main,
                  color: _isLoading ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isLoading
                      ? const []
                      : [
                          BoxShadow(
                            color: AppColors.darkGreen.withAlpha(70),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          _mode == _AuthMode.login ? 'Iniciar sesión' : 'Crear cuenta',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            if (_mode == _AuthMode.login) ...[
              const SizedBox(height: 18),
              _buildDivider(context),
              const SizedBox(height: 14),
              _SocialButton(
                label: 'Continuar con Google',
                icon: Icons.g_mobiledata_rounded,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha(15)
                    : const Color(0xFFF7F7F7),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.textDark,
                onTap: _isLoading ? null : () => _handleProviderLogin('Google'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    final title = _mode == _AuthMode.login ? 'Inicia sesión' : 'Crear cuenta';
    final subtitle = _mode == _AuthMode.login
        ? 'Accede a tu cuenta docente'
        : 'Regístrate con cualquier correo válido';

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'O continúa con',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white70 : Colors.grey[700],
      ),
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.blue),
      filled: true,
      fillColor: isDark ? Colors.white.withAlpha(10) : const Color(0xFFF9FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.transparent : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.main : null,
            color: selected ? null : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withAlpha(20) : const Color(0xFFF5F6FA)),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white : AppColors.textDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: foregroundColor),
        label: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: Colors.grey.shade200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _PasswordResetResult {
  const _PasswordResetResult({
    required this.email,
    required this.newPassword,
  });

  final String email;
  final String newPassword;
}

class _PasswordResetDialog extends StatefulWidget {
  const _PasswordResetDialog();

  @override
  State<_PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<_PasswordResetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Recuperar contraseña'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electronico',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu correo electronico';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una nueva contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma la nueva contraseña';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                _PasswordResetResult(
                  email: _emailController.text.trim(),
                  newPassword: _newPasswordController.text,
                ),
              );
            }
          },
          child: const Text('Restaurar'),
        ),
      ],
    );
  }
}

