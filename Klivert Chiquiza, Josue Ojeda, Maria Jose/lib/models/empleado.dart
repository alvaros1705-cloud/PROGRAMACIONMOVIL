/// Modelo que representa a un empleado del taller de confección.
/// Los empleados pueden ser fileteadores, ensambladores o terminadores.
class Empleado {
  /// ID del documento en Firestore
  final String id;

  /// Nombre completo del empleado
  final String nombre;

  /// Número de documento de identidad (Cédula, DNI, etc.)
  final String documento;

  /// Número de teléfono de contacto
  final String telefono;

  /// Tipo de trabajo que realiza: 'fileteador', 'ensamblador', 'terminador'
  final String tipoTrabajo;

  /// Constructor con todos los campos requeridos
  Empleado({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.tipoTrabajo,
  });

  /// Crea un Empleado desde un Map (datos de Firestore)
  /// [map]: Mapa con los datos del documento
  /// [id]: ID del documento Firestore
  factory Empleado.fromMap(Map<String, dynamic> map, String id) {
    return Empleado(
      id: id,
      nombre: map['nombre'] ?? '',
      documento: map['documento'] ?? '',
      telefono: map['telefono'] ?? '',
      tipoTrabajo: map['tipoTrabajo'] ?? '',
    );
  }

  /// Convierte el empleado a un Map para guardar en Firestore
  /// El ID no se incluye porque es la clave del documento
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'documento': documento,
      'telefono': telefono,
      'tipoTrabajo': tipoTrabajo,
    };
  }

  /// Crea una copia del empleado con valores modificados
  /// Útil para edición de datos
  Empleado copyWith({
    String? id,
    String? nombre,
    String? documento,
    String? telefono,
    String? tipoTrabajo,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      tipoTrabajo: tipoTrabajo ?? this.tipoTrabajo,
    );
  }

  /// Representación en string para debug
  @override
  String toString() {
    return 'Empleado(id: $id, nombre: $nombre, documento: $documento, telefono: $telefono, tipoTrabajo: $tipoTrabajo)';
  }
}
