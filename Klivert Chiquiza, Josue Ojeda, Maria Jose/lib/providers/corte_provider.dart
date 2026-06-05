import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/corte.dart';
import '../services/corte_service.dart';

/// Instancia única del servicio de cortes
final _corteService = CorteService();

/// ---------------------------------------------------------------------------
/// StreamProvider: cortesStreamProvider
/// ---------------------------------------------------------------------------
/// Escucha en tiempo real todos los cortes registrados.
/// Los cortes se ordenan por fecha descendente (más recientes primero).
///
/// Uso: final cortes = ref.watch(cortesStreamProvider);
final cortesStreamProvider = StreamProvider.autoDispose<List<Corte>>((ref) {
  return _corteService.obtenerCortes();
});

/// ---------------------------------------------------------------------------
/// StreamProvider: cortesPorEmpleadoProvider
/// ---------------------------------------------------------------------------
/// Obtiene los cortes de un empleado específico.
/// Es un Provider.family porque recibe el ID del empleado como parámetro.
/// Útil para ver el historial de trabajo de un empleado.
///
/// Uso: final cortes = ref.watch(cortesPorEmpleadoProvider('empleado123'));
final cortesPorEmpleadoProvider =
    StreamProvider.autoDispose.family<List<Corte>, String>((ref, empleadoId) {
  return _corteService.obtenerCortesPorEmpleado(empleadoId);
});

/// ---------------------------------------------------------------------------
/// StreamProvider: cortesHoyProvider
/// ---------------------------------------------------------------------------
/// Filtra y devuelve únicamente los cortes realizados hoy.
/// Útil para el dashboard de resumen diario.
/// Compara la fecha del corte con la fecha actual (sin hora).
///
/// Uso: final cortesHoy = ref.watch(cortesHoyProvider);
final cortesHoyProvider = StreamProvider.autoDispose<List<Corte>>((ref) {
  return _corteService.obtenerCortes().map((cortes) {
    final hoy = DateTime.now();
    return cortes.where((corte) {
      return corte.fecha.year == hoy.year &&
          corte.fecha.month == hoy.month &&
          corte.fecha.day == hoy.day;
    }).toList();
  });
});

/// ---------------------------------------------------------------------------
/// StreamProvider: totalPiezasPorEmpleadoProvider
/// ---------------------------------------------------------------------------
/// Calcula el total de piezas cortadas por un empleado específico.
/// Útil para comparar contra las piezas pagadas y calcular saldos.
///
/// Uso: final total = ref.watch(totalPiezasPorEmpleadoProvider('empleado123'));
final totalPiezasPorEmpleadoProvider =
    StreamProvider.autoDispose.family<int, String>((ref, empleadoId) {
  return _corteService
      .obtenerCortesPorEmpleado(empleadoId)
      .map((cortes) => cortes.fold<int>(
            0,
            (sum, corte) => sum + corte.cantidad,
          ));
});

/// ---------------------------------------------------------------------------
/// AsyncNotifier: CorteNotifier
/// ---------------------------------------------------------------------------
/// Maneja las operaciones de modificación de cortes.
/// El corte representa un lote de piezas asignadas a un empleado para trabajar.
class CorteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Estado inicial
    return;
  }

  /// Crea un nuevo corte en Firestore
  /// [corte]: El corte a crear con todos los datos
  /// El ID se genera automáticamente en Firestore
  Future<void> crear(Corte corte) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _corteService.crearCorte(corte);
    });
  }

  /// Elimina un corte de Firestore
  /// [id]: ID del documento del corte a eliminar
  /// ⚠️ Advertencia: Eliminar un corte no afecta los pagos ya registrados.
  /// Considerar mostrar una advertencia al usuario.
  Future<void> eliminar(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _corteService.eliminarCorte(id);
    });
  }

  /// Obtiene el total de piezas de un empleado (método de utilidad)
  /// Esto es un Future normal, no actualiza el estado del notifier
  Future<int> obtenerTotalPiezas(String empleadoId) async {
    return await _corteService.obtenerTotalPiezasPorEmpleado(empleadoId);
  }
}

/// Provider del CorteNotifier
final corteNotifierProvider =
    AsyncNotifierProvider<CorteNotifier, void>(CorteNotifier.new);
