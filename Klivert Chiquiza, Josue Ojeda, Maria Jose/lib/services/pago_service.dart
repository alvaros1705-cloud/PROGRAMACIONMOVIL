import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pago.dart';

/// Servicio para gestionar operaciones CRUD de pagos en Firestore.
/// Los pagos representan el dinero entregado a los empleados por su trabajo.
class PagoService {
  /// Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nombre de la colección en Firestore
  static const String _coleccion = 'pagos';

  /// Crea un nuevo pago en Firestore
  /// [pago]: El pago a crear (el ID se genera automáticamente)
  ///
  /// ⚠️ IMPORTANTE: El campo [total] debe calcularse ANTES de llamar este método:
  ///   double total = pago.piezasPagadas * pago.valorUnidad;
  ///
  /// Lanza una excepción si hay error de conexión o permisos
  Future<void> crearPago(Pago pago) async {
    try {
      // Validar que el total esté calculado correctamente
      final totalCalculado = pago.piezasPagadas * pago.valorUnidad;

      // Crear el pago con el total calculado
      final pagoConTotal = Pago(
        id: pago.id,
        empleadoId: pago.empleadoId,
        fecha: pago.fecha,
        piezasPagadas: pago.piezasPagadas,
        valorUnidad: pago.valorUnidad,
        total: totalCalculado,
        nota: pago.nota,
      );

      await _firestore.collection(_coleccion).add(pagoConTotal.toMap());
    } catch (e) {
      throw Exception('Error al crear pago: $e');
    }
  }

  /// Obtiene un stream con la lista de todos los pagos
  /// Ordenados por fecha descendente (más recientes primero)
  /// El stream se actualiza automáticamente cuando hay cambios en Firestore
  Stream<List<Pago>> obtenerPagos() {
    return _firestore
        .collection(_coleccion)
        .orderBy('fecha', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Pago.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      throw Exception('Error al obtener pagos: $error');
    });
  }

  /// Obtiene un stream con los pagos de un empleado específico
  /// [empleadoId]: ID del empleado para filtrar
  /// Ordenados por fecha descendente (más recientes primero)
  Stream<List<Pago>> obtenerPagosPorEmpleado(String empleadoId) {
    return _firestore
        .collection(_coleccion)
        .where('empleadoId', isEqualTo: empleadoId)
        .snapshots()
        .map((snapshot) {
      final pagos = snapshot.docs.map((doc) {
        return Pago.fromMap(doc.data(), doc.id);
      }).toList();
      pagos.sort((a, b) => b.fecha.compareTo(a.fecha));
      return pagos;
    }).handleError((error) {
      throw Exception('Error al obtener pagos del empleado: $error');
    });
  }

  /// Obtiene el total pagado a un empleado
  /// [empleadoId]: ID del empleado
  /// Útil para calcular saldos y estadísticas
  Future<double> obtenerTotalPagadoPorEmpleado(String empleadoId) async {
    try {
      final snapshot = await _firestore
          .collection(_coleccion)
          .where('empleadoId', isEqualTo: empleadoId)
          .get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['total'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total pagado: $e');
    }
  }

  /// Obtiene el total de piezas pagadas a un empleado
  /// [empleadoId]: ID del empleado
  /// Útil para comparar contra las piezas cortadas y calcular saldo
  Future<int> obtenerTotalPiezasPagadas(String empleadoId) async {
    try {
      final snapshot = await _firestore
          .collection(_coleccion)
          .where('empleadoId', isEqualTo: empleadoId)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['piezasPagadas'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular piezas pagadas: $e');
    }
  }

  /// Elimina un pago de Firestore
  /// [id]: ID del documento del pago a eliminar
  /// ⚠️ ADVERTENCIA: Eliminar un pago afecta el saldo del empleado
  Future<void> eliminarPago(String id) async {
    try {
      await _firestore.collection(_coleccion).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar pago: $e');
    }
  }
}
