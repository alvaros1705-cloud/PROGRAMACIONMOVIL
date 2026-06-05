import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/corte_provider.dart';
import '../../providers/empleado_provider.dart';
import '../../models/corte.dart';
import '../../models/empleado.dart';

/// Pantalla: CortesScreen - Version Ligera
class CortesScreen extends ConsumerWidget {
  const CortesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cortesAsync = ref.watch(cortesStreamProvider);
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cortes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: cortesAsync.when(
        data: (cortes) {
          return empleadosAsync.when(
            data: (empleados) => _buildList(context, ref, cortes, empleados),
            loading: () => _buildList(context, ref, cortes, []),
            error: (_, __) => _buildList(context, ref, cortes, []),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/cortes/nuevo'),
        backgroundColor: const Color(0xFF43E97B),
        tooltip: 'Nuevo corte',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref,
      List<Corte> cortes, List<Empleado> empleados) {
    if (cortes.isEmpty) {
      return const Center(child: Text('No hay cortes registrados'));
    }

    final empleadosMap = {for (var e in empleados) e.id: e};

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cortes.length,
      itemBuilder: (context, index) {
        final c = cortes[index];
        final empleado = empleadosMap[c.empleadoId];
        return Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${c.cantidad}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text('REF: ${c.referencia}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${empleado?.nombre ?? "Sin asignar"} - ${DateFormat('dd MMM yyyy').format(c.fecha)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarEliminar(context, ref, c),
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Corte c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar?'),
        content: Text('Eliminar corte ${c.referencia}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(corteNotifierProvider.notifier).eliminar(c.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
