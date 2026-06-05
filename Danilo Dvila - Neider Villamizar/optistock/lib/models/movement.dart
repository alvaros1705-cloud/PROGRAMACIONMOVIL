import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryMovement {
  final String id;
  final String referencia;
  final int cantidad;
  final String tipo; // 'compra', 'venta', 'ajuste'
  final DateTime fecha;

  InventoryMovement({
    required this.id,
    required this.referencia,
    required this.cantidad,
    required this.tipo,
    required this.fecha,
  });

  factory InventoryMovement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InventoryMovement(
      id: doc.id,
      referencia: data['referencia'] ?? '',
      cantidad: data['cantidad'] ?? 0,
      tipo: data['tipo'] ?? 'venta',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referencia': referencia,
      'cantidad': cantidad,
      'tipo': tipo,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
