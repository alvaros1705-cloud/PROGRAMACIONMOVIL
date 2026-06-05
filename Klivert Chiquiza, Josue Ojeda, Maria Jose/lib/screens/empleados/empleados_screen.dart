import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/empleado_provider.dart';
import '../../models/empleado.dart';

/// Pantalla: EmpleadosScreen - Version Ligera
class EmpleadosScreen extends ConsumerWidget {
  const EmpleadosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: empleadosAsync.when(
        data: (empleados) => _buildList(context, ref, empleados),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/empleados/nuevo'),
        tooltip: 'Nuevo empleado',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Empleado> empleados) {
    if (empleados.isEmpty) {
      return const Center(child: Text('No hay empleados registrados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: empleados.length,
      itemBuilder: (context, index) {
        final e = empleados[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF3F51B5).withValues(alpha: 0.1),
              child: Text(
                e.nombre.isNotEmpty ? e.nombre[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF3F51B5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${e.tipoTrabajo} - ${e.telefono}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF3F51B5)),
                  onPressed: () => context.go('/empleados/${e.id}/editar'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarEliminar(context, ref, e),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Empleado e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar?'),
        content: Text('Eliminar a ${e.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(empleadoNotifierProvider.notifier).eliminar(e.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
