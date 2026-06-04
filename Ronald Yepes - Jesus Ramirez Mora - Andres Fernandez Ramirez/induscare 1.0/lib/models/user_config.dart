enum AppLanguage { es, en }

enum AppThemePreference { light, dark, system }

class UserConfig {
  final String userName;
  final AppThemePreference themeMode;
  final AppLanguage language;

  const UserConfig({
    this.userName = '',
    this.themeMode = AppThemePreference.system,
    this.language = AppLanguage.en,
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    return UserConfig(
      userName: (json['userName'] as String?) ?? '',
      themeMode: _themeFromString((json['themeMode'] as String?) ?? 'system'),
      language: _languageFromString((json['language'] as String?) ?? 'en'),
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'themeMode': themeMode.name,
        'language': language.name,
      };

  UserConfig copyWith({
    String? userName,
    AppThemePreference? themeMode,
    AppLanguage? language,
  }) {
    return UserConfig(
      userName: userName ?? this.userName,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  static AppThemePreference _themeFromString(String value) {
    return AppThemePreference.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppThemePreference.system,
    );
  }

  static AppLanguage _languageFromString(String value) {
    return AppLanguage.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppLanguage.en,
    );
  }
}
