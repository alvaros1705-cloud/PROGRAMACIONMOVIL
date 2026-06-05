import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa un corte de jeans en el taller.
/// Un corte es un lote de piezas que se asignan a un empleado para trabajar.
class Corte {
  /// ID del documento en Firestore
  final String id;

  /// Fecha en que se registró el corte
  final DateTime fecha;

  /// Referencia o código del modelo de jean (ej: 'REF-501', 'Jean Clásico')
  final String referencia;

  /// Cantidad de piezas cortadas
  final int cantidad;

  /// ID del empleado al que se asignó este corte
  final String empleadoId;

  /// Constructor con todos los campos requeridos
  Corte({
    required this.id,
    required this.fecha,
    required this.referencia,
    required this.cantidad,
    required this.empleadoId,
  });

  /// Crea un Corte desde un Map (datos de Firestore)
  /// [map]: Mapa con los datos del documento
  /// [id]: ID del documento Firestore
  /// Las fechas se convierten de Timestamp de Firestore a DateTime de Dart
  factory Corte.fromMap(Map<String, dynamic> map, String id) {
    return Corte(
      id: id,
      fecha: _parseFecha(map['fecha']),
      referencia: map['referencia'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      empleadoId: map['empleadoId'] ?? '',
    );
  }

  static DateTime _parseFecha(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convierte el corte a un Map para guardar en Firestore
  /// El ID no se incluye porque es la clave del documento
  /// La fecha se convierte a Timestamp de Firestore
  Map<String, dynamic> toMap() {
    return {
      'fecha': Timestamp.fromDate(fecha),
      'referencia': referencia,
      'cantidad': cantidad,
      'empleadoId': empleadoId,
    };
  }

  /// Crea una copia del corte con valores modificados
  /// Útil para edición de datos
  Corte copyWith({
    String? id,
    DateTime? fecha,
    String? referencia,
    int? cantidad,
    String? empleadoId,
  }) {
    return Corte(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      referencia: referencia ?? this.referencia,
      cantidad: cantidad ?? this.cantidad,
      empleadoId: empleadoId ?? this.empleadoId,
    );
  }

  /// Representación en string para debug
  @override
  String toString() {
    return 'Corte(id: $id, fecha: $fecha, referencia: $referencia, cantidad: $cantidad, empleadoId: $empleadoId)';
  }
}
