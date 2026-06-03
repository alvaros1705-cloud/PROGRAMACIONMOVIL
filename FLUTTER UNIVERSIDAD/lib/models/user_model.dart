// lib/models/user_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// Modelo del usuario guardado en Firestore
// ─────────────────────────────────────────────────────────────────────────────

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? profile;       // Estudiante, Profesional, Familia, Bienestar
  final String provider;       // 'email' | 'google'
  final DateTime createdAt;
  final DateTime lastSeen;
  final int streakDays;
  final double dailyLimitHours;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.profile,
    required this.provider,
    required this.createdAt,
    required this.lastSeen,
    this.streakDays = 0,
    this.dailyLimitHours = 4.0,
  });

  // ── Desde Firestore ────────────────────────────────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      profile: map['profile'],
      provider: map['provider'] ?? 'email',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      lastSeen: DateTime.tryParse(map['lastSeen'] ?? '') ?? DateTime.now(),
      streakDays: map['streakDays'] ?? 0,
      dailyLimitHours: (map['dailyLimitHours'] ?? 4.0).toDouble(),
    );
  }

  // ── Hacia Firestore ────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'profile': profile,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
      'streakDays': streakDays,
      'dailyLimitHours': dailyLimitHours,
    };
  }

  // ── Copia con cambios ──────────────────────────────────────────────────────
  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? profile,
    DateTime? lastSeen,
    int? streakDays,
    double? dailyLimitHours,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      profile: profile ?? this.profile,
      provider: provider,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      streakDays: streakDays ?? this.streakDays,
      dailyLimitHours: dailyLimitHours ?? this.dailyLimitHours,
    );
  }

  // ── Getter: iniciales del nombre para el avatar ────────────────────────────
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ── Getter: primer nombre ──────────────────────────────────────────────────
  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isNotEmpty ? parts[0] : name;
  }
}