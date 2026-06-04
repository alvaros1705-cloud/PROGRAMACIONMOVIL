import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'local_auth_service.dart';

class NativeSignInAttempt {
  const NativeSignInAttempt._({
    this.email,
    required this.wasCancelled,
    this.error,
  });

  const NativeSignInAttempt.success(String email)
      : this._(email: email, wasCancelled: false);

  const NativeSignInAttempt.cancelled()
      : this._(wasCancelled: true);

  const NativeSignInAttempt.failed(String error)
      : this._(wasCancelled: false, error: error);

  final String? email;
  final bool wasCancelled;
  final String? error;
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<String?> register({
    required String email,
    required String password,
  }) async {
    final res = await LocalAuthService.register(email: email, password: password);
    if (res != null) return res;

    // Verify session persisted locally
    final session = await LocalAuthService.getCurrentEmail();
    if (session == null) return 'No se pudo guardar la sesión local tras el registro.';
    return null;
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final res = await LocalAuthService.login(email: email, password: password);
    if (res != null) return res;

    final session = await LocalAuthService.getCurrentEmail();
    if (session == null) return 'No se pudo guardar la sesión local tras iniciar sesión.';
    return null;
  }

  static Future<String?> signInWithProvider({
    required String provider,
    required String email,
  }) async {
    // Ya se completó la autenticación en tryNativeGoogleSignIn.
    return null;
  }

  static Future<String?> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Firebase requiere enviar un correo electrónico para restablecer la contraseña
      // de forma segura en lugar de actualizarla directamente desde el cliente sin sesión previa.
      await _auth.sendPasswordResetEmail(email: email);
      return null; // El frontend dirá que el correo fue enviado en lugar de actualizada
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseError(e);
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
    await LocalAuthService.clearSession();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google Sign-In errors — the user may not have signed in with Google.
    }
  }

  static Future<bool> hasActiveSession() async {
    if (_auth.currentUser != null) return true;
    return LocalAuthService.hasActiveSession();
  }

  /// Returns the email of the currently signed-in user, checking Firebase
  /// first and then the local session (for email/password users).
  static Future<String?> getCurrentUserEmail() async {
    final firebaseEmail = _auth.currentUser?.email;
    if (firebaseEmail != null) return firebaseEmail;
    return LocalAuthService.getCurrentEmail();
  }

  static Future<NativeSignInAttempt> tryNativeGoogleSignIn() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        final result = await _auth.signInWithPopup(provider);
        final email = result.user?.email;

        if (email == null || email.isEmpty) {
          return const NativeSignInAttempt.failed(
            'Google no devolvio correo. Verifica la configuracion OAuth web.',
          );
        }

        return NativeSignInAttempt.success(email);
      }

      // Intentar forzar la cuenta en dispositivos que puedan tener varias
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const NativeSignInAttempt.cancelled();
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      return NativeSignInAttempt.success(googleUser.email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        return const NativeSignInAttempt.cancelled();
      }
      return NativeSignInAttempt.failed(_handleFirebaseError(e));
    } catch (error) {
      return NativeSignInAttempt.failed('Google error no esperado: $error');
    }
  }


  static String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No encontramos una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Inténtalo de nuevo.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese correo usando otro método.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'invalid-credential':
        return 'Credencial de Google invalida. Revisa SHA-1/SHA-256 y el package name en Firebase.';
      case 'app-not-authorized':
        return 'La app no esta autorizada para Google Sign-In. Revisa OAuth, SHA y package name.';
      case 'operation-not-allowed':
        return 'Este método de inicio de sesión no está habilitado en Firebase Authentication.';
      default:
        return 'Error: ${e.message}';
    }
  }
}
