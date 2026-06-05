import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/empleado.dart';
import '../services/empleado_service.dart';

/// Instancia única del servicio de empleados
/// Se usa como dependencia en los providers
final _empleadoService = EmpleadoService();

/// ---------------------------------------------------------------------------
/// StreamProvider: empleadosStreamProvider
/// ---------------------------------------------------------------------------
/// Escucha en tiempo real todos los cambios en la colección 'empleados' de Firestore.
/// Se actualiza automáticamente cuando:
/// - Se crea un nuevo empleado
/// - Se actualiza un empleado existente
/// - Se elimina un empleado
///
/// Uso: final empleados = ref.watch(empleadosStreamProvider);
final empleadosStreamProvider = StreamProvider.autoDispose<List<Empleado>>((ref) {
  return _empleadoService.obtenerEmpleados();
});

/// ---------------------------------------------------------------------------
/// StreamProvider: empleadoPorIdStreamProvider
/// ---------------------------------------------------------------------------
/// Obtiene un empleado específico por su ID.
/// Es un Provider.family porque recibe un parámetro (el ID).
///
/// Uso: final empleado = ref.watch(empleadoPorIdStreamProvider('abc123'));
final empleadoPorIdStreamProvider =
    StreamProvider.autoDispose.family<Empleado?, String>((ref, empleadoId) {
  return _empleadoService
      .obtenerEmpleadoPorId(empleadoId)
      .asStream()
      .asyncMap((empleado) => empleado);
});

/// ---------------------------------------------------------------------------
/// AsyncNotifier: EmpleadoNotifier
/// ---------------------------------------------------------------------------
/// Maneja las operaciones de modificación de empleados con estado de carga.
/// Proporciona:
/// - Estado de carga (isLoading)
/// - Manejo de errores (errorMessage)
/// - Métodos asíncronos para crear, actualizar y eliminar
///
/// El estado es AsyncValue<void> porque no necesitamos mantener datos,
/// solo el estado de la operación.
class EmpleadoNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // El estado inicial es completado (no hay operación activa)
    return;
  }

  /// Crea un nuevo empleado en Firestore
  /// [empleado]: El empleado a crear
  /// En caso de error, el estado cambia a AsyncError
  Future<void> crear(Empleado empleado) async {
    state = const AsyncLoading(); // Indica que la operación está en curso

    state = await AsyncValue.guard(() async {
      await _empleadoService.crearEmpleado(empleado);
    });
  }

  /// Actualiza un empleado existente en Firestore
  /// [empleado]: El empleado con los datos actualizados
  /// Requiere que el empleado tenga un ID válido
  Future<void> actualizar(Empleado empleado) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _empleadoService.actualizarEmpleado(empleado);
    });
  }

  /// Elimina un empleado de Firestore
  /// [id]: ID del empleado a eliminar
  /// ⚠️ Advertencia: Esto no elimina los cortes ni pagos asociados
  Future<void> eliminar(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _empleadoService.eliminarEmpleado(id);
    });
  }
}

/// Provider del EmpleadoNotifier
/// Uso: final notifier = ref.watch(empleadoNotifierProvider.notifier);
///      ref.watch(empleadoNotifierProvider) // para ver el estado
final empleadoNotifierProvider =
    AsyncNotifierProvider<EmpleadoNotifier, void>(EmpleadoNotifier.new);

/// ---------------------------------------------------------------------------
/// Provider de utilidad: tiposDeTrabajoProvider
/// ---------------------------------------------------------------------------
/// Lista de tipos de trabajo disponibles para los empleados del taller.
/// Es un Provider.simple porque nunca cambia.
///
/// Uso: final tipos = ref.watch(tiposDeTrabajoProvider);
final tiposDeTrabajoProvider = Provider<List<String>>((ref) {
  return [
    'Fileteador', // Cose las piezas con máquina fileteadora
    'Ensamblador', // Une las piezas cortadas
    'Terminador', // Hace los últimos detalles (presillas, botones, etc.)
    'Cortador', // Cortador de tela y piezas
    'Otro', // Otra labor del taller
  ];
});
