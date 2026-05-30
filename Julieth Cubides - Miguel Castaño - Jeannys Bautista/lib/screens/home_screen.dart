import 'package:flutter/material.dart';
import '../utils/app_theme.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildWelcomeCard(context),
              const SizedBox(height: 28),
              _buildTipCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.main,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withAlpha(80),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '¡Bienvenido/a, docente!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí encontrarás información clara y estrategias pedagógicas, para apoyar a tus estudiantes con diversas discapacidades cognitivas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(230),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.amber.withAlpha(20)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.amber.withAlpha(80)
              : const Color(0xFFFFCC02),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recuerda',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.amber.shade200
                            : const Color(0xFF8D6E00),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cada estudiante es único. Las estrategias presentadas son puntos de partida, adáptalas siempre a las necesidades individuales de cada alumno.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.amber.shade100
                            : const Color(0xFF8D6E00),
                        height: 1.5,
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
