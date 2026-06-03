// lib/services/auth_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Servicio centralizado de Firebase Authentication
// Ahora guarda el usuario en Firestore al registrarse o entrar con Google
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // ── Stream del usuario actual ──────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Usuario actual ─────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN CON EMAIL Y CONTRASEÑA
  // Solo actualiza lastSeen, no crea de nuevo
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Actualiza lastSeen en Firestore
    await _firestoreService.saveUserIfNew(
      firebaseUser: credential.user!,
      provider: 'email',
    );
    return credential;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGISTRO CON EMAIL Y CONTRASEÑA
  // Crea el usuario en Firebase Auth Y en Firestore
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
    String? profile,           // ← perfil elegido en el registro
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Guarda el displayName en Firebase Auth
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }

    // Guarda el usuario completo en Firestore ← NUEVO
    await _firestoreService.saveUserIfNew(
      firebaseUser: credential.user!,
      displayName: displayName,
      profile: profile,
      provider: 'email',
    );

    return credential;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN-IN
  // También guarda en Firestore si es la primera vez
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential? result;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        result = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        result = await _auth.signInWithCredential(credential);
      }

      // Guarda en Firestore si es usuario nuevo ← NUEVO
      if (result != null) {
        await _firestoreService.saveUserIfNew(
          firebaseUser: result.user!,
          provider: 'google',
        );
      }

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESET DE CONTRASEÑA
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CERRAR SESIÓN
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRADUCIR ERRORES DE FIREBASE AL ESPAÑOL
  // ─────────────────────────────────────────────────────────────────────────
  static String translateError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Intenta de nuevo.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'operation-not-allowed':
        return 'Inicio de sesión no habilitado. Contacta soporte.';
      case 'weak-password':
        return 'La contraseña es muy débil. Usa al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisa tu red.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método.';
      default:
        return 'Ocurrió un error. Intenta de nuevo.';
    }
  }
}