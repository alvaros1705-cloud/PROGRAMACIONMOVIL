import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/empleado.dart';

/// Servicio para gestionar operaciones CRUD de empleados en Firestore.
/// Esta clase proporciona métodos para crear, leer, actualizar y eliminar empleados.
class EmpleadoService {
  /// Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Nombre de la colección en Firestore
  static const String _coleccion = 'empleados';

  /// Crea un nuevo empleado en Firestore
  /// [empleado]: El empleado a crear (el ID se genera automáticamente)
  /// Lanza una excepción si hay error de conexión o permisos
  Future<void> crearEmpleado(Empleado empleado) async {
    try {
      await _firestore.collection(_coleccion).add(empleado.toMap());
    } catch (e) {
      throw Exception('Error al crear empleado: $e');
    }
  }

  /// Obtiene un stream con la lista de todos los empleados
  /// El stream se actualiza automáticamente cuando hay cambios en Firestore
  /// Retorna un Stream de lista vacía si hay error
  Stream<List<Empleado>> obtenerEmpleados() {
    return _firestore
        .collection(_coleccion)
        .orderBy('nombre')
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Empleado.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      throw Exception('Error al obtener empleados: $error');
    });
  }

  /// Actualiza los datos de un empleado existente
  /// [empleado]: El empleado con los datos actualizados (debe tener ID válido)
  /// Lanza una excepción si el empleado no existe o hay error de permisos
  Future<void> actualizarEmpleado(Empleado empleado) async {
    try {
      await _firestore
          .collection(_coleccion)
          .doc(empleado.id)
          .update(empleado.toMap());
    } catch (e) {
      throw Exception('Error al actualizar empleado: $e');
    }
  }

  /// Elimina un empleado de Firestore
  /// [id]: ID del documento del empleado a eliminar
  /// ⚠️ IMPORTANTE: Al eliminar un empleado, considerar que:
  /// - Los cortes asociados a este empleado quedarán con referencia huérfana
  /// - Los pagos asociados quedarán con referencia huérfana
  /// Considerar implementar borrado en cascada o restricción en el futuro
  Future<void> eliminarEmpleado(String id) async {
    try {
      await _firestore.collection(_coleccion).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar empleado: $e');
    }
  }

  /// Obtiene un empleado específico por su ID
  /// [id]: ID del empleado a buscar
  /// Retorna null si no se encuentra
  Future<Empleado?> obtenerEmpleadoPorId(String id) async {
    try {
      final doc = await _firestore.collection(_coleccion).doc(id).get();
      if (doc.exists) {
        return Empleado.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener empleado: $e');
    }
  }
}
