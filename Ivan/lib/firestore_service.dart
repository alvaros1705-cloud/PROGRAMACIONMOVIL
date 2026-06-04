import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Guardar una reserva
  Future<void> saveReservation({
    required String courtName,
    required String hour,
    required String price,
    required String category,
    required String userName,
    required String userCedula,
    required String userPhone,
  }) async {
    if (_uid == null) return;

    await _db.collection('reservations').add({
      'uid': _uid,
      'courtName': courtName,
      'hour': hour,
      'price': price,
      'category': category,
      'userName': userName,
      'userCedula': userCedula,
      'userPhone': userPhone,
      'status': 'Pendiente',
      'date': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener horas ocupadas de una cancha hoy
  Future<Set<String>> getOccupiedHours(String courtName) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _db
        .collection('reservations')
        .where('courtName', isEqualTo: courtName)
        .where('status', whereIn: ['Pendiente', 'Confirmada'])
        .get();

    final occupiedHours = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = data['date'] as String? ?? '';
      try {
        final date = DateTime.parse(dateStr);
        if (date.isAfter(todayStart) && date.isBefore(todayEnd)) {
          occupiedHours.add(data['hour'] as String? ?? '');
        }
      } catch (_) {}
    }
    return occupiedHours;
  }

  // Obtener reservas del usuario actual
  Stream<QuerySnapshot> getUserReservations() {
    if (_uid == null) {
      return const Stream.empty();
    }
    return _db
        .collection('reservations')
        .where('uid', isEqualTo: _uid)
        .snapshots();
  }

  // Cancelar una reserva
  Future<void> cancelReservation(String reservationId) async {
    await _db.collection('reservations').doc(reservationId).update({
      'status': 'Cancelada',
    });
  }

  // Contar reservas del usuario
  Future<int> getUserReservationCount() async {
    if (_uid == null) return 0;
    final snapshot = await _db
        .collection('reservations')
        .where('uid', isEqualTo: _uid)
        .get();
    return snapshot.docs.length;
  }

  // Contar canchas únicas visitadas
  Future<int> getUniqueCourtsCount() async {
    if (_uid == null) return 0;
    final snapshot = await _db
        .collection('reservations')
        .where('uid', isEqualTo: _uid)
        .get();
    final courts = snapshot.docs.map((d) => d['courtName']).toSet();
    return courts.length;
  }

  // Contar deportes únicos
  Future<int> getUniqueSportsCount() async {
    if (_uid == null) return 0;
    final snapshot = await _db
        .collection('reservations')
        .where('uid', isEqualTo: _uid)
        .get();
    final sports = snapshot.docs.map((d) => d['category']).toSet();
    return sports.length;
  }
}