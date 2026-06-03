// lib/services/firestore_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Servicio centralizado de Firestore
// Guarda el usuario al registrarse y lo lee en el dashboard
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Colección de usuarios
  CollectionReference get _users => _db.collection('users');

  // ─────────────────────────────────────────────────────────────────────────
  // GUARDAR USUARIO (al registrarse por primera vez)
  // Solo guarda si NO existe ya en Firestore (no sobreescribe)
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> saveUserIfNew({
    required User firebaseUser,
    String? displayName,
    String? profile,
    String provider = 'email',
  }) async {
    final docRef = _users.doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Es usuario nuevo → crear documento
      final user = UserModel(
        uid: firebaseUser.uid,
        name: displayName ??
            firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'Usuario',
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        profile: profile,
        provider: provider,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        streakDays: 0,
        dailyLimitHours: 4.0,
      );
      await docRef.set(user.toMap());
    } else {
      // Ya existe → solo actualiza lastSeen
      await docRef.update({'lastSeen': DateTime.now().toIso8601String()});
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OBTENER USUARIO por UID (una sola vez)
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STREAM del usuario (escucha cambios en tiempo real)
  // Úsalo en el dashboard para reactividad
  // ─────────────────────────────────────────────────────────────────────────
  Stream<UserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTUALIZAR PERFIL del usuario
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update({
      ...fields,
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }
}