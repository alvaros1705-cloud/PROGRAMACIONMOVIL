import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ---------------------------------------------------------------------------
/// Pantalla: DashboardScreen - Version Ligera
/// ---------------------------------------------------------------------------
/// Panel de control principal optimizado para rendimiento.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Control'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuración',
            onPressed: () => context.go('/configuracion'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titulo
            const Text(
              'Accesos Directos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Accesos compactos en fila
            _buildAccesosCompactos(context),

            const SizedBox(height: 24),

            // Resumen simple
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildResumenSimple(context),
          ],
        ),
      ),
    );
  }

  /// Accesos directos compactos en filas
  Widget _buildAccesosCompactos(BuildContext context) {
    final accesos = [
      _AccesoData('Empleados', Icons.people, '/empleados', Colors.indigo),
      _AccesoData('Cortes', Icons.content_cut, '/cortes', Colors.green),
      _AccesoData('Pagos', Icons.payments, '/pagos', Colors.pink),
      _AccesoData('Historial', Icons.history, '/historial', Colors.blue),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: accesos.map((acceso) => _AccesoChiclet(
        titulo: acceso.titulo,
        icono: acceso.icono,
        ruta: acceso.ruta,
        color: acceso.color,
      )).toList(),
    );
  }

  /// Resumen simple con cards pequeñas
  Widget _buildResumenSimple(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.content_cut, color: Colors.green),
            title: const Text('Cortes'),
            subtitle: const Text('Gestionar produccion'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/cortes'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.payments, color: Colors.pink),
            title: const Text('Pagos'),
            subtitle: const Text('Registrar pagos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/pagos'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.people, color: Colors.indigo),
            title: const Text('Empleados'),
            subtitle: const Text('Ver empleados'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/empleados'),
          ),
        ),
      ],
    );
  }
}

/// Datos de acceso
class _AccesoData {
  final String titulo;
  final IconData icono;
  final String ruta;
  final Color color;

  const _AccesoData(this.titulo, this.icono, this.ruta, this.color);
}

/// Widget de acceso compacto tipo "chiclet"
class _AccesoChiclet extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final String ruta;
  final Color color;

  const _AccesoChiclet({
    required this.titulo,
    required this.icono,
    required this.ruta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go(ruta),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width / 2 - 22, // Mitad de pantalla menos padding
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Icon(icono, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
