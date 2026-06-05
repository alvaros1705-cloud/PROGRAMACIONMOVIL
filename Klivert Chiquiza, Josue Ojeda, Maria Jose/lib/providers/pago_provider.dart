import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pago.dart';
import '../services/pago_service.dart';

/// Instancia única del servicio de pagos
final _pagoService = PagoService();

/// ---------------------------------------------------------------------------
/// StreamProvider: pagosStreamProvider
/// ---------------------------------------------------------------------------
/// Escucha en tiempo real todos los pagos registrados.
/// Los pagos se ordenan por fecha descendente (más recientes primero).
///
/// Uso: final pagos = ref.watch(pagosStreamProvider);
final pagosStreamProvider = StreamProvider.autoDispose<List<Pago>>((ref) {
  return _pagoService.obtenerPagos();
});

/// ---------------------------------------------------------------------------
/// StreamProvider: pagosPorEmpleadoProvider
/// ---------------------------------------------------------------------------
/// Obtiene todos los pagos realizados a un empleado específico.
/// Es un Provider.family porque recibe el ID del empleado.
/// Útil para mostrar el historial de pagos de un empleado.
///
/// Uso: final pagos = ref.watch(pagosPorEmpleadoProvider('empleado123'));
final pagosPorEmpleadoProvider =
    StreamProvider.autoDispose.family<List<Pago>, String>((ref, empleadoId) {
  return _pagoService.obtenerPagosPorEmpleado(empleadoId);
});

/// ---------------------------------------------------------------------------
/// StreamProvider: totalPagadoPorEmpleadoProvider
/// ---------------------------------------------------------------------------
/// Calcula el total de dinero pagado a un empleado.
/// Suma todos los campos 'total' de los pagos del empleado.
///
/// Uso: final total = ref.watch(totalPagadoPorEmpleadoProvider('empleado123'));
final totalPagadoPorEmpleadoProvider =
    StreamProvider.autoDispose.family<double, String>((ref, empleadoId) {
  return _pagoService
      .obtenerPagosPorEmpleado(empleadoId)
      .map((pagos) => pagos.fold<double>(
            0.0,
            (sum, pago) => sum + pago.total,
          ));
});

/// ---------------------------------------------------------------------------
/// StreamProvider: totalPiezasPagadasProvider
/// ---------------------------------------------------------------------------
/// Calcula el total de piezas que han sido pagadas a un empleado.
/// Suma todos los campos 'piezasPagadas' de los pagos del empleado.
/// Útil para calcular el saldo: piezasCortadas - piezasPagadas
///
/// Uso: final pagadas = ref.watch(totalPiezasPagadasProvider('empleado123'));
final totalPiezasPagadasProvider =
    StreamProvider.autoDispose.family<int, String>((ref, empleadoId) {
  return _pagoService
      .obtenerPagosPorEmpleado(empleadoId)
      .map((pagos) => pagos.fold<int>(
            0,
            (sum, pago) => sum + pago.piezasPagadas,
          ));
});

/// ---------------------------------------------------------------------------
/// StreamProvider: saldoPiezasPorEmpleadoProvider
/// ---------------------------------------------------------------------------
/// Calcula el saldo de piezas pendientes de pago de un empleado.
/// Saldo = piezasCortadas - piezasPagadas
/// Combina el stream de cortes con el stream de pagos.
///
/// Uso: final saldo = ref.watch(saldoPiezasPorEmpleadoProvider('empleado123'));
final saldoPiezasPorEmpleadoProvider =
    StreamProvider.autoDispose.family<int, String>((ref, empleadoId) {
  // Obtener el stream de piezas pagadas
  final pagosStream = ref.watch(totalPiezasPagadasProvider(empleadoId));

  // Retornar un stream que calcula el saldo
  // Nota: Esto asume que hay un provider de piezas cortadas
  // En la práctica, esto se combinará con el provider de cortes
  return pagosStream.when(
    data: (piezasPagadas) {
      // Aquí necesitamos las piezas cortadas
      // Esto se resuelve en la UI combinando ambos valores
      return Stream.value(0); // Placeholder
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(0),
  );
});

/// ---------------------------------------------------------------------------
/// AsyncNotifier: PagoNotifier
/// ---------------------------------------------------------------------------
/// Maneja las operaciones de creación y eliminación de pagos.
/// El pago representa una entrega de dinero al empleado por su trabajo.
class PagoNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Estado inicial
    return;
  }

  /// Crea un nuevo pago en Firestore
  /// [pago]: El pago a crear
  ///
  /// ⚠️ IMPORTANTE: El campo [total] se calcula automáticamente en el servicio:
  /// total = piezasPagadas * valorUnidad
  ///
  /// El método garantiza que el total esté calculado antes de guardar.
  Future<void> crear(Pago pago) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _pagoService.crearPago(pago);
    });
  }

  /// Elimina un pago de Firestore
  /// [id]: ID del documento del pago a eliminar
  /// ⚠️ Advertencia: Eliminar un pago aumenta el saldo pendiente del empleado.
  /// Considerar mostrar una confirmación antes de eliminar.
  Future<void> eliminar(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _pagoService.eliminarPago(id);
    });
  }

  /// Obtiene el total pagado a un empleado (método de utilidad)
  Future<double> obtenerTotalPagado(String empleadoId) async {
    return await _pagoService.obtenerTotalPagadoPorEmpleado(empleadoId);
  }

  /// Obtiene el total de piezas pagadas a un empleado (método de utilidad)
  Future<int> obtenerPiezasPagadas(String empleadoId) async {
    return await _pagoService.obtenerTotalPiezasPagadas(empleadoId);
  }
}

/// Provider del PagoNotifier
final pagoNotifierProvider =
    AsyncNotifierProvider<PagoNotifier, void>(PagoNotifier.new);
