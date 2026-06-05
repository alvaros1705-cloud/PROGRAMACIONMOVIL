import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/corte.dart';

/// Servicio para gestionar operaciones CRUD de cortes en Firestore.
/// Un corte representa un lote de piezas asignadas a un empleado.
class CorteService {
  /// Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nombre de la colección en Firestore
  static const String _coleccion = 'cortes';

  /// Crea un nuevo corte en Firestore
  /// [corte]: El corte a crear (el ID se genera automáticamente)
  /// Lanza una excepción si hay error de conexión o permisos
  Future<void> crearCorte(Corte corte) async {
    try {
      await _firestore.collection(_coleccion).add(corte.toMap());
    } catch (e) {
      throw Exception('Error al crear corte: $e');
    }
  }

  /// Obtiene un stream con la lista de todos los cortes
  /// Ordenados por fecha descendente (más recientes primero)
  /// El stream se actualiza automáticamente cuando hay cambios en Firestore
  Stream<List<Corte>> obtenerCortes() {
    return _firestore
        .collection(_coleccion)
        .orderBy('fecha', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Corte.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      throw Exception('Error al obtener cortes: $error');
    });
  }

  /// Obtiene un stream con los cortes de un empleado específico
  /// [empleadoId]: ID del empleado para filtrar
  /// Ordenados por fecha descendente (más recientes primero)
  Stream<List<Corte>> obtenerCortesPorEmpleado(String empleadoId) {
    return _firestore
        .collection(_coleccion)
        .where('empleadoId', isEqualTo: empleadoId)
        .snapshots()
        .map((snapshot) {
      final cortes = snapshot.docs.map((doc) {
        return Corte.fromMap(doc.data(), doc.id);
      }).toList();
      cortes.sort((a, b) => b.fecha.compareTo(a.fecha));
      return cortes;
    }).handleError((error) {
      throw Exception('Error al obtener cortes del empleado: $error');
    });
  }

  /// Elimina un corte de Firestore
  /// [id]: ID del documento del corte a eliminar
  /// ⚠️ IMPORTANTE: Eliminar un corte no afecta los pagos ya registrados
  Future<void> eliminarCorte(String id) async {
    try {
      await _firestore.collection(_coleccion).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar corte: $e');
    }
  }

  /// Obtiene la cantidad total de piezas cortadas por un empleado
  /// [empleadoId]: ID del empleado
  /// Útil para calcular saldos y estadísticas
  Future<int> obtenerTotalPiezasPorEmpleado(String empleadoId) async {
    try {
      final snapshot = await _firestore
          .collection(_coleccion)
          .where('empleadoId', isEqualTo: empleadoId)
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['cantidad'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      throw Exception('Error al calcular total de piezas: $e');
    }
  }
}
