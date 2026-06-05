import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';

/// Pantalla de configuración de Judisa Taller.
///
/// Muestra perfil, modo oscuro, información de la app y cierre de sesión.
class ConfiguracionScreen extends ConsumerWidget {
  const ConfiguracionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'usuario@ejemplo.com';
    final inicial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(inicial, email),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'APARIENCIA'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: const Text('Activa el tema oscuro de la aplicación'),
                secondary: const Icon(Icons.dark_mode),
                activeThumbColor: const Color(0xFF3F51B5),
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTema(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'CUENTA'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF3F51B5)),
                title: const Text('Sesión iniciada como:'),
                subtitle: Text(email),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'INFORMACIÓN'),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Color(0xFF3F51B5)),
                    title: const Text('Versión de la app'),
                    trailing: const Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.factory, color: Color(0xFF3F51B5)),
                    title: const Text('Judisa Taller'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Cerrar sesión'),
                onPressed: () => _confirmSignOut(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String inicial, String email) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text(
              inicial,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Usuario conectado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      try {
        await GoogleSignIn().disconnect();
      } catch (_) {
        // Ignorar errores de desconexión si no había sesión de Google activa.
      }
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      context.go('/');
    }
  }
}
