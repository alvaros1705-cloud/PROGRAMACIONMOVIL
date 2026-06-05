import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/corte_provider.dart';
import '../../providers/pago_provider.dart';
import '../../providers/empleado_provider.dart';
import '../../models/corte.dart';
import '../../models/pago.dart';
import '../../models/empleado.dart';

/// ---------------------------------------------------------------------------
/// Pantalla: HistorialScreen
/// ---------------------------------------------------------------------------
/// Muestra el historial completo de cortes y pagos con filtros.
/// Usa TabBar para alternar entre vistas de Cortes y Pagos.
class HistorialScreen extends ConsumerStatefulWidget {
  const HistorialScreen({super.key});

  @override
  ConsumerState<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends ConsumerState<HistorialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filtros
  String? _empleadoIdSeleccionado;
  DateTimeRange? _rangoFechas;
  String _busquedaReferencia = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Refrescar la UI cuando cambie de tab
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.content_cut), text: 'Cortes'),
            Tab(icon: Icon(Icons.payments), text: 'Pagos'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtros
          _buildFiltros(),
          // Contenido de tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Cortes
                _buildCortesTab(),
                // Tab Pagos
                _buildPagosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la sección de filtros
  Widget _buildFiltros() {
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila 1: Dropdown empleado y selector de fechas
          Row(
            children: [
              // Dropdown empleado
              Expanded(
                flex: 2,
                child: empleadosAsync.when(
                  data: (empleados) => _buildEmpleadoDropdown(empleados),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error cargando empleados'),
                ),
              ),
              const SizedBox(width: 12),
              // Selector de rango de fechas
              Expanded(
                flex: 2,
                child: _buildFechaRangePicker(),
              ),
            ],
          ),
          // Fila 2: Búsqueda por referencia (solo en tab Cortes)
          if (_tabController.index == 0) ...[
            const SizedBox(height: 12),
            _buildBusquedaReferencia(),
          ],
        ],
      ),
    );
  }

  /// Dropdown para seleccionar empleado
  Widget _buildEmpleadoDropdown(List<Empleado> empleados) {
    return DropdownButtonFormField<String?>(
      value: _empleadoIdSeleccionado,
      decoration: const InputDecoration(
        labelText: 'Empleado',
        prefixIcon: Icon(Icons.person_outline),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: const Text('Todos'),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Todos los empleados'),
        ),
        ...empleados.map((empleado) {
          return DropdownMenuItem<String?>(
            value: empleado.id,
            child: Text(empleado.nombre),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _empleadoIdSeleccionado = value);
      },
    );
  }

  /// Selector de rango de fechas
  Widget _buildFechaRangePicker() {
    final fechaTexto = _rangoFechas != null
        ? '${DateFormat('dd/MM').format(_rangoFechas!.start)} - ${DateFormat('dd/MM').format(_rangoFechas!.end)}'
        : 'Todas las fechas';

    return InkWell(
      onTap: () => _seleccionarRangoFechas(),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Período',
          prefixIcon: Icon(Icons.date_range),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                fechaTexto,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_rangoFechas != null)
              InkWell(
                onTap: () => setState(() => _rangoFechas = null),
                child: const Icon(Icons.clear, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  /// Campo de búsqueda por referencia
  Widget _buildBusquedaReferencia() {
    return TextField(
      onChanged: (value) => setState(() => _busquedaReferencia = value),
      decoration: InputDecoration(
        labelText: 'Buscar por referencia',
        hintText: 'Ej: REF-501',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _busquedaReferencia.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() => _busquedaReferencia = '');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  /// Abre el selector de rango de fechas
  Future<void> _seleccionarRangoFechas() async {
    final hoy = DateTime.now();
    final inicial = _rangoFechas;

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(hoy.year + 1),
      initialDateRange: inicial ??
          DateTimeRange(
            start: hoy.subtract(const Duration(days: 30)),
            end: hoy,
          ),
      helpText: 'Seleccione el rango de fechas',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      saveText: 'Guardar',
    );

    if (result != null && mounted) {
      setState(() => _rangoFechas = result);
    }
  }

  /// Tab de Cortes
  Widget _buildCortesTab() {
    final cortesAsync = ref.watch(cortesStreamProvider);
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return cortesAsync.when(
      data: (cortes) {
        return empleadosAsync.when(
          data: (empleados) => _buildCortesList(cortes, empleados),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildCortesList(cortes, []),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error al cargar cortes: $error'),
      ),
    );
  }

  /// Construye la lista de cortes filtrada
  Widget _buildCortesList(List<Corte> cortes, List<Empleado> empleados) {
    // Aplicar filtros
    final cortesFiltrados = cortes.where((corte) {
      // Filtro por empleado
      if (_empleadoIdSeleccionado != null &&
          corte.empleadoId != _empleadoIdSeleccionado) {
        return false;
      }
      // Filtro por rango de fechas
      if (_rangoFechas != null) {
        final fechaCorte = DateTime(
          corte.fecha.year,
          corte.fecha.month,
          corte.fecha.day,
        );
        if (fechaCorte.isBefore(_rangoFechas!.start) ||
            fechaCorte.isAfter(_rangoFechas!.end)) {
          return false;
        }
      }
      // Filtro por referencia
      if (_busquedaReferencia.isNotEmpty &&
          !corte.referencia
              .toLowerCase()
              .contains(_busquedaReferencia.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Calcular total de piezas
    final totalPiezas = cortesFiltrados.fold<int>(
      0,
      (sum, corte) => sum + corte.cantidad,
    );

    final empleadosMap = {for (var e in empleados) e.id: e};

    return Column(
      children: [
        Expanded(
          child: cortesFiltrados.isEmpty
              ? _buildEmptyState('No hay cortes con los filtros seleccionados')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: cortesFiltrados.length,
                  itemBuilder: (context, index) {
                    final corte = cortesFiltrados[index];
                    final empleado = empleadosMap[corte.empleadoId];
                    return _CorteHistorialCard(
                      corte: corte,
                      empleado: empleado,
                    );
                  },
                ),
        ),
        // Total al pie
        _buildTotalBar(
          label: 'Total de piezas:',
          value: '$totalPiezas',
          icon: Icons.inventory_2_outlined,
        ),
      ],
    );
  }

  /// Tab de Pagos
  Widget _buildPagosTab() {
    final pagosAsync = ref.watch(pagosStreamProvider);
    final empleadosAsync = ref.watch(empleadosStreamProvider);

    return pagosAsync.when(
      data: (pagos) {
        return empleadosAsync.when(
          data: (empleados) => _buildPagosList(pagos, empleados),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildPagosList(pagos, []),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error al cargar pagos: $error'),
      ),
    );
  }

  /// Construye la lista de pagos filtrada
  Widget _buildPagosList(List<Pago> pagos, List<Empleado> empleados) {
    // Aplicar filtros
    final pagosFiltrados = pagos.where((pago) {
      // Filtro por empleado
      if (_empleadoIdSeleccionado != null &&
          pago.empleadoId != _empleadoIdSeleccionado) {
        return false;
      }
      // Filtro por rango de fechas
      if (_rangoFechas != null) {
        final fechaPago = DateTime(
          pago.fecha.year,
          pago.fecha.month,
          pago.fecha.day,
        );
        if (fechaPago.isBefore(_rangoFechas!.start) ||
            fechaPago.isAfter(_rangoFechas!.end)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Calcular total pagado
    final totalPagado = pagosFiltrados.fold<double>(
      0,
      (sum, pago) => sum + pago.total,
    );

    final empleadosMap = {for (var e in empleados) e.id: e};

    return Column(
      children: [
        Expanded(
          child: pagosFiltrados.isEmpty
              ? _buildEmptyState('No hay pagos con los filtros seleccionados')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: pagosFiltrados.length,
                  itemBuilder: (context, index) {
                    final pago = pagosFiltrados[index];
                    final empleado = empleadosMap[pago.empleadoId];
                    return _PagoHistorialCard(
                      pago: pago,
                      empleado: empleado,
                    );
                  },
                ),
        ),
        // Total al pie
        _buildTotalBar(
          label: 'Total pagado:',
          value: '\$${_formatearMoneda(totalPagado)}',
          icon: Icons.payments_outlined,
          valueColor: Colors.green,
        ),
      ],
    );
  }

  /// Estado vacío
  Widget _buildEmptyState(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajuste los filtros para ver resultados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Barra de totales al pie
  Widget _buildTotalBar({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFF3F51B5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearMoneda(double valor) {
    return valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }
}

/// ---------------------------------------------------------------------------
/// Widget: _CorteHistorialCard
/// ---------------------------------------------------------------------------
class _CorteHistorialCard extends StatelessWidget {
  final Corte corte;
  final Empleado? empleado;

  const _CorteHistorialCard({
    required this.corte,
    this.empleado,
  });

  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.content_cut,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    corte.referencia,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    empleado?.nombre ?? 'Empleado no encontrado',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatearFecha(corte.fecha),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Cantidad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${corte.cantidad} piezas',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Widget: _PagoHistorialCard
/// ---------------------------------------------------------------------------
class _PagoHistorialCard extends StatelessWidget {
  final Pago pago;
  final Empleado? empleado;

  const _PagoHistorialCard({
    required this.pago,
    this.empleado,
  });

  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  String _formatearMoneda(double valor) {
    return valor.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payments,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    empleado?.nombre ?? 'Empleado no encontrado',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pago.piezasPagadas} piezas × \$${_formatearMoneda(pago.valorUnidad)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatearFecha(pago.fecha),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (pago.nota != null && pago.nota!.isNotEmpty)
                    Text(
                      'Nota: ${pago.nota}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            // Total
            Text(
              '\$${_formatearMoneda(pago.total)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
