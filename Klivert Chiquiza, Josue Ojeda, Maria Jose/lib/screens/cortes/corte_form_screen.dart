import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/empleado_provider.dart';
import '../../services/corte_service.dart';
import '../../models/corte.dart';
import '../../models/empleado.dart';

/// Pantalla: CorteFormScreen - Version Ligera
class CorteFormScreen extends ConsumerStatefulWidget {
  const CorteFormScreen({super.key});

  @override
  ConsumerState<CorteFormScreen> createState() => _CorteFormScreenState();
}

class _CorteFormScreenState extends ConsumerState<CorteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _cantidadController = TextEditingController();

  String? _empleadoId;
  DateTime _fecha = DateTime.now();
  bool _guardando = false;
  final _service = CorteService();

  @override
  void dispose() {
    _refController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_empleadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un empleado')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final corte = Corte(
        id: '',
        fecha: _fecha,
        referencia: _refController.text.trim().toUpperCase(),
        cantidad: int.parse(_cantidadController.text.trim()),
        empleadoId: _empleadoId!,
      );

      await _service.crearCorte(corte);
      if (mounted) context.go('/cortes');
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Corte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cortes'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _refController,
                decoration: const InputDecoration(
                  labelText: 'Referencia',
                  prefixIcon: Icon(Icons.label),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Numero invalido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              empleadosAsync.when(
                data: (empleados) => DropdownButtonFormField<String>(
                  value: _empleadoId,
                  decoration: const InputDecoration(
                    labelText: 'Empleado',
                    prefixIcon: Icon(Icons.person),
                  ),
                  hint: const Text('Selecciona un empleado'),
                  items: empleados.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text(e.nombre),
                  )).toList(),
                  onChanged: (v) => setState(() => _empleadoId = v),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error cargando empleados'),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                onTap: _pickFecha,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
