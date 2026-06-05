import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa un pago realizado a un empleado.
/// Los pagos se calculan según la cantidad de piezas pagadas y el valor unitario acordado.
class Pago {
  /// ID del documento en Firestore
  final String id;

  /// ID del empleado que recibe el pago
  final String empleadoId;

  /// Fecha en que se realiza el pago
  final DateTime fecha;

  /// Cantidad de piezas que se están pagando en este registro
  final int piezasPagadas;

  /// Valor acordado por cada pieza trabajada
  final double valorUnidad;

  /// Total a pagar (calculado: piezasPagadas * valorUnidad)
  final double total;

  /// Nota opcional sobre el pago (ej: 'pago semana 1', 'adelanto', etc.)
  final String? nota;

  /// Constructor con todos los campos requeridos
  /// El campo [total] debe calcularse antes de crear el objeto
  Pago({
    required this.id,
    required this.empleadoId,
    required this.fecha,
    required this.piezasPagadas,
    required this.valorUnidad,
    required this.total,
    this.nota,
  });

  /// Crea un Pago desde un Map (datos de Firestore)
  /// [map]: Mapa con los datos del documento
  /// [id]: ID del documento Firestore
  /// Las fechas se convierten de Timestamp de Firestore a DateTime de Dart
  factory Pago.fromMap(Map<String, dynamic> map, String id) {
    return Pago(
      id: id,
      empleadoId: map['empleadoId'] ?? '',
      fecha: _parseFecha(map['fecha']),
      piezasPagadas: map['piezasPagadas'] ?? 0,
      valorUnidad: (map['valorUnidad'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      nota: map['nota'],
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

  /// Convierte el pago a un Map para guardar en Firestore
  /// El ID no se incluye porque es la clave del documento
  /// La fecha se convierte a Timestamp de Firestore
  Map<String, dynamic> toMap() {
    return {
      'empleadoId': empleadoId,
      'fecha': Timestamp.fromDate(fecha),
      'piezasPagadas': piezasPagadas,
      'valorUnidad': valorUnidad,
      'total': total,
      'nota': nota,
    };
  }

  /// Crea una copia del pago con valores modificados
  /// Útil para edición de datos
  Pago copyWith({
    String? id,
    String? empleadoId,
    DateTime? fecha,
    int? piezasPagadas,
    double? valorUnidad,
    double? total,
    String? nota,
  }) {
    return Pago(
      id: id ?? this.id,
      empleadoId: empleadoId ?? this.empleadoId,
      fecha: fecha ?? this.fecha,
      piezasPagadas: piezasPagadas ?? this.piezasPagadas,
      valorUnidad: valorUnidad ?? this.valorUnidad,
      total: total ?? this.total,
      nota: nota ?? this.nota,
    );
  }

  /// Representación en string para debug
  @override
  String toString() {
    return 'Pago(id: $id, empleadoId: $empleadoId, fecha: $fecha, piezasPagadas: $piezasPagadas, valorUnidad: $valorUnidad, total: $total, nota: $nota)';
  }
}
