import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/pago_provider.dart';
import '../../providers/empleado_provider.dart';
import '../../models/pago.dart';
import '../../models/empleado.dart';

/// Pantalla: PagosScreen - Version Ligera
class PagosScreen extends ConsumerWidget {
  const PagosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagosAsync = ref.watch(pagosStreamProvider);
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: pagosAsync.when(
        data: (pagos) {
          return empleadosAsync.when(
            data: (empleados) => _buildList(context, ref, pagos, empleados),
            loading: () => _buildList(context, ref, pagos, []),
            error: (_, __) => _buildList(context, ref, pagos, []),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/pagos/nuevo'),
        backgroundColor: const Color(0xFFFF6B9D),
        tooltip: 'Nuevo pago',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref,
      List<Pago> pagos, List<Empleado> empleados) {
    if (pagos.isEmpty) {
      return const Center(child: Text('No hay pagos registrados'));
    }

    final empleadosMap = {for (var e in empleados) e.id: e};

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pagos.length,
      itemBuilder: (context, index) {
        final p = pagos[index];
        final empleado = empleadosMap[p.empleadoId];
        return Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '\$${p.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: Text(empleado?.nombre ?? 'Sin empleado',
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${p.piezasPagadas} piezas x \$${p.valorUnidad.toStringAsFixed(0)} - ${DateFormat('dd MMM').format(p.fecha)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmarEliminar(context, ref, p),
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref, Pago p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar?'),
        content: Text('Eliminar pago de \$${p.total.toStringAsFixed(0)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(pagoNotifierProvider.notifier).eliminar(p.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
