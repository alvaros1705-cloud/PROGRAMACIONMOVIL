import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_config.dart';
import '../models/user.dart';
import '../models/workspace.dart';

class StorageService {
  static const _workspaceStorageKey = 'induscare_data';
  static const _configStorageKey = 'induscare_user_config';

  final Map<String, String> _memoryFallback = <String, String>{};

  Future<Map<String, dynamic>?> loadData() async {
    try {
      final content = await _readJsonString(_workspaceStorageKey);
      if (content == null || content.isEmpty) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> saveData(User? user, List<Workspace> workspaces) async {
    try {
      final data = {
        'user': user?.toJson(),
        'workspaces': workspaces.map((w) => w.toJson()).toList(),
      };
      await _writeJsonString(_workspaceStorageKey, jsonEncode(data));
    } on TypeError {
      // Invalid data was provided - skip persistence for this cycle
    }
  }

  Future<UserConfig?> loadUserConfig() async {
    try {
      final content = await _readJsonString(_configStorageKey);
      if (content == null || content.isEmpty) {
        return null;
      }
      return UserConfig.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> saveUserConfig(UserConfig config) async {
    try {
      await _writeJsonString(_configStorageKey, jsonEncode(config.toJson()));
    } on TypeError {
      // Invalid data was provided - skip persistence for this cycle
    }
  }

  Future<String> exportToJson(List<Workspace> workspaces) async {
    return jsonEncode({
      'workspaces': workspaces.map((w) => w.toJson()).toList(),
    });
  }

  List<Workspace> importFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final list = data['workspaces'] as List<dynamic>;
      return list.map((w) => Workspace.fromJson(w)).toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<String?> _readJsonString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key) ?? _memoryFallback[key];
    } catch (_) {
      // Browser/unsupported environments can fail to initialize persistent store.
      return _memoryFallback[key];
    }
  }

  Future<void> _writeJsonString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {
      _memoryFallback[key] = value;
    }
  }
}
