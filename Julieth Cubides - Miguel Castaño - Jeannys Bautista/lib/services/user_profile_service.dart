import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  const UserProfile({
    required this.email,
    this.selectedEmoji,
    this.avatarBgColor,
    this.profilePhoto,
    this.phoneNumber,
    this.country,
  });

  final String email;
  final String? selectedEmoji;
  final int? avatarBgColor;
  final Uint8List? profilePhoto;
  final String? phoneNumber;
  final String? country;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'selectedEmoji': selectedEmoji,
      'avatarBgColor': avatarBgColor,
      'profilePhoto': profilePhoto == null ? null : base64Encode(profilePhoto!),
      'phoneNumber': phoneNumber,
      'country': country,
    };
  }

  static UserProfile fromJson(Map<String, dynamic> json, {required String fallbackEmail}) {
    final rawEmail = json['email'];
    final resolvedEmail = rawEmail is String && rawEmail.trim().isNotEmpty
        ? rawEmail.trim().toLowerCase()
        : fallbackEmail;
    return UserProfile(
      email: resolvedEmail,
      selectedEmoji: json['selectedEmoji'] as String?,
      avatarBgColor: json['avatarBgColor'] is int ? json['avatarBgColor'] as int : null,
      profilePhoto: _decodePhoto(json['profilePhoto']),
      phoneNumber: json['phoneNumber'] as String?,
      country: json['country'] as String?,
    );
  }

  static Uint8List? _decodePhoto(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }
}

class UserProfileService {
  static const _kProfilePrefix = 'user_profile_';

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static String _profileKey(String email) => '$_kProfilePrefix${_normalizeEmail(email)}';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final normalizedEmail = _normalizeEmail(profile.email);
    final payload = UserProfile(
      email: normalizedEmail,
      selectedEmoji: profile.selectedEmoji,
      avatarBgColor: profile.avatarBgColor,
      profilePhoto: profile.profilePhoto,
      phoneNumber: profile.phoneNumber,
      country: profile.country,
    );
    await prefs.setString(_profileKey(normalizedEmail), jsonEncode(payload.toJson()));
  }

  static Future<UserProfile?> loadProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey(email));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final normalizedEmail = _normalizeEmail(email);
      return UserProfile.fromJson(decoded, fallbackEmail: normalizedEmail);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey(email));
  }
}
