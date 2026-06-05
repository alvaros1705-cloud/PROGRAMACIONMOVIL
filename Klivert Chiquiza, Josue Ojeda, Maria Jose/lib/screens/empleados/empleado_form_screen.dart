import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:judisa_taller/services/empleado_service.dart';
import '../../models/empleado.dart';

/// Pantalla: EmpleadoFormScreen - Version Ligera
class EmpleadoFormScreen extends StatefulWidget {
  final String? empleadoId;
  const EmpleadoFormScreen({super.key, this.empleadoId});

  @override
  State<EmpleadoFormScreen> createState() => _EmpleadoFormScreenState();
}

class _EmpleadoFormScreenState extends State<EmpleadoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _tipoTrabajo = 'Fileteador';
  bool _guardando = false;

  final _tipos = ['Fileteador', 'Ensamblador', 'Terminador', 'Cortador', 'Otro'];
  final _service = EmpleadoService();

  @override
  void initState() {
    super.initState();
    if (widget.empleadoId != null) {
      _cargarEmpleado();
    }
  }

  Future<void> _cargarEmpleado() async {
    final e = await _service.obtenerEmpleadoPorId(widget.empleadoId!);
    if (e != null && mounted) {
      setState(() {
        _nombreController.text = e.nombre;
        _documentoController.text = e.documento;
        _telefonoController.text = e.telefono;
        _tipoTrabajo = e.tipoTrabajo;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final empleado = Empleado(
        id: widget.empleadoId ?? '',
        nombre: _nombreController.text.trim(),
        documento: _documentoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        tipoTrabajo: _tipoTrabajo,
      );

      if (widget.empleadoId != null) {
        await _service.actualizarEmpleado(empleado);
      } else {
        await _service.crearEmpleado(empleado);
      }

      if (mounted) {
        context.go('/empleados');
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.empleadoId != null ? 'Editar Empleado' : 'Nuevo Empleado'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/empleados'),
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
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _documentoController,
                decoration: const InputDecoration(
                  labelText: 'Documento',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoTrabajo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de trabajo',
                  prefixIcon: Icon(Icons.work),
                ),
                items: _tipos.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t),
                )).toList(),
                onChanged: (v) => setState(() => _tipoTrabajo = v!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.empleadoId != null ? 'Actualizar' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
