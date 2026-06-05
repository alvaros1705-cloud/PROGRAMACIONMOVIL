import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optistock/models/product.dart';
import 'package:optistock/models/movement.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of products for real-time updates in the dashboard
  Stream<List<Product>> getProducts() {
    return _db.collection('productos').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Stream of critical products (stock < reorder_point)
  Stream<List<Product>> getCriticalProducts() {
    return _db
        .collection('productos')
        .where('stock_actual', isLessThanOrEqualTo: 'punto_reorden') // Note: Simple query, might need client-side filtering if complex
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Add a new movement
  Future<void> addMovement(InventoryMovement movement) async {
    await _db.collection('movimientos').add(movement.toMap());
    
    // Update stock in the product document
    final productRef = _db.collection('productos').doc(movement.referencia);
    
    _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        // If product doesn't exist, create it (simplified)
        transaction.set(productRef, {
          'referencia': movement.referencia,
          'stock_actual': movement.cantidad,
          'ultima_actualizacion': FieldValue.serverTimestamp(),
        });
      } else {
        int currentStock = snapshot.get('stock_actual') ?? 0;
        int newStock = movement.tipo == 'venta' 
            ? currentStock - movement.cantidad 
            : currentStock + movement.cantidad;
            
        transaction.update(productRef, {
          'stock_actual': newStock,
          'ultima_actualizacion': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
