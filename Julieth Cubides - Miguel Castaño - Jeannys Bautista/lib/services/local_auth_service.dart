import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A local auth service backed by SharedPreferences.
///
/// Used for email/password registration and login so that users can create
/// accounts and stay signed in without requiring Firebase email/password
/// sign-in to be enabled in the Firebase Console.
class LocalAuthService {
  static const _kUsers = 'local_auth_users';
  static const _kSession = 'local_auth_session';

  /// Returns an encoded representation of the credentials.
  ///
  /// NOTE: This is base64 encoding of the credential string, NOT a
  /// cryptographic hash. It is intentionally simple for this prototype/
  /// educational app. For production, replace with bcrypt, argon2 or PBKDF2.
  static String _encodePassword(String email, String password) {
    final combined = '${email.toLowerCase()}|$password|incluyeme_local_2025';
    return base64Url.encode(utf8.encode(combined));
  }

  static Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v as String));
  }

  static Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users));
  }

  /// Registers a new user locally. Returns an error message on failure,
  /// or [null] on success.
  static Future<String?> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _loadUsers();
    if (users.containsKey(normalizedEmail)) {
      return 'Este correo ya está registrado.';
    }
    users[normalizedEmail] = _encodePassword(normalizedEmail, password);
    await _saveUsers(users);
    await setSession(normalizedEmail);
    return null;
  }

  /// Constant-time string comparison to mitigate timing attacks.
  static bool _safeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Logs in an existing local user. Returns an error message on failure,
  /// or [null] on success.
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _loadUsers();
    if (!users.containsKey(normalizedEmail)) {
      return 'No encontramos una cuenta con ese correo.';
    }
    if (!_safeEquals(users[normalizedEmail]!, _encodePassword(normalizedEmail, password))) {
      return 'Contraseña incorrecta. Inténtalo de nuevo.';
    }
    await setSession(normalizedEmail);
    return null;
  }

  /// Persists a session for [email] across app restarts.
  static Future<void> setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSession, email.trim().toLowerCase());
  }

  /// Clears the local session (used on logout).
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSession);
  }

  /// Returns the email of the locally signed-in user, or [null] if no
  /// local session exists.
  static Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSession);
  }

  /// Returns [true] if a local session is currently active.
  static Future<bool> hasActiveSession() async {
    final email = await getCurrentEmail();
    return email != null;
  }
}
