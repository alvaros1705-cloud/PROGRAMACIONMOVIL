import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String referencia;
  final int stockActual;
  final double stockSeguridad;
  final double puntoReorden;
  final double demandaPromedio;
  final DateTime ultimaActualizacion;

  Product({
    required this.id,
    required this.referencia,
    required this.stockActual,
    required this.stockSeguridad,
    required this.puntoReorden,
    required this.demandaPromedio,
    required this.ultimaActualizacion,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      referencia: data['referencia'] ?? '',
      stockActual: (data['stock_actual'] as num?)?.toInt() ?? 0,
      stockSeguridad: (data['stock_seguridad'] ?? 0).toDouble(),
      puntoReorden: (data['punto_reorden'] ?? 0).toDouble(),
      demandaPromedio: (data['demanda_promedio'] ?? 0).toDouble(),
      ultimaActualizacion: (data['ultima_actualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referencia': referencia,
      'stock_actual': stockActual,
      'stock_seguridad': stockSeguridad,
      'punto_reorden': puntoReorden,
      'demanda_promedio': demandaPromedio,
      'ultima_actualizacion': Timestamp.fromDate(ultimaActualizacion),
    };
  }
}
