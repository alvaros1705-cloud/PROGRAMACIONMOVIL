import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/empleado_provider.dart';
import '../../services/pago_service.dart';
import '../../models/pago.dart';
import '../../models/empleado.dart';

/// Pantalla: PagoFormScreen - Version Ligera
class PagoFormScreen extends ConsumerStatefulWidget {
  const PagoFormScreen({super.key});

  @override
  ConsumerState<PagoFormScreen> createState() => _PagoFormScreenState();
}

class _PagoFormScreenState extends ConsumerState<PagoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _piezasController = TextEditingController();
  final _valorController = TextEditingController();
  final _notaController = TextEditingController();

  String? _empleadoId;
  DateTime _fecha = DateTime.now();
  bool _guardando = false;
  final _service = PagoService();

  double get _total {
    final piezas = int.tryParse(_piezasController.text) ?? 0;
    final valor = double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0;
    return piezas * valor;
  }

  @override
  void dispose() {
    _piezasController.dispose();
    _valorController.dispose();
    _notaController.dispose();
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
    if (_total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El total debe ser mayor a 0')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final pago = Pago(
        id: '',
        empleadoId: _empleadoId!,
        fecha: _fecha,
        piezasPagadas: int.parse(_piezasController.text.trim()),
        valorUnidad: double.parse(_valorController.text.replaceAll(',', '.')),
        total: _total,
        nota: _notaController.text.trim().isEmpty ? null : _notaController.text.trim(),
      );

      await _service.crearPago(pago);
      if (mounted) context.go('/pagos');
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
        title: const Text('Nuevo Pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/pagos'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _piezasController,
                      decoration: const InputDecoration(
                        labelText: 'Piezas',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (int.tryParse(v) == null) return 'Invalido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor unit.',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) return 'Invalido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '\$${_total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notaController,
                decoration: const InputDecoration(
                  labelText: 'Nota (opcional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
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
