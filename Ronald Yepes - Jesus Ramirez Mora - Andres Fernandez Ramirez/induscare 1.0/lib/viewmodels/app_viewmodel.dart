import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/device.dart';
import '../models/user_config.dart';
import '../models/user.dart';
import '../models/workspace.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class AppViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();

  User? user;
  List<Workspace> workspaces = [];
  Workspace? selectedWorkspace;
  bool isLoading = true;
  bool isFirstLaunch = false;
  UserConfig _userConfig = const UserConfig();

  ThemeMode get themeMode {
    switch (_userConfig.themeMode) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  Locale get locale => Locale(_userConfig.language.name);

  AppThemePreference get themePreference => _userConfig.themeMode;
  AppLanguage get appLanguage => _userConfig.language;

  static const int maxWorkspaces = AppConstants.maxWorkspaces;

  Future<void> bootstrap() async {
    isLoading = true;

    final loadedConfig = await _storage.loadUserConfig();
    _userConfig = loadedConfig ?? _defaultConfigFromSystem();

    final data = await _storage.loadData();
    if (data != null) {
      user = data['user'] != null ? User.fromJson(data['user']) : null;
      final rawWorkspaces = data['workspaces'];
      if (rawWorkspaces is List<dynamic>) {
        workspaces = rawWorkspaces
            .map((w) => Workspace.fromJson(w as Map<String, dynamic>))
            .toList();
        _sortAllWorkspaceDevices();
      }
      if (workspaces.isNotEmpty) {
        selectedWorkspace = workspaces.first;
      }
    }

    isFirstLaunch = user == null;

    if (loadedConfig == null) {
      await _storage.saveUserConfig(_userConfig);
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> init() async {
    await bootstrap();
  }

  void setUser(String name) {
    user = User(name: name);
    _userConfig = _userConfig.copyWith(userName: name);
    notifyListeners();
    _save();
  }

  void createWorkspace(String name) {
    if (workspaces.length >= AppConstants.maxWorkspaces) return;
    final ws = Workspace(id: const Uuid().v4(), name: name);
    workspaces.add(ws);
    if (selectedWorkspace == null || workspaces.length == 1) {
      selectedWorkspace = ws;
    }
    notifyListeners();
    _save();
  }

  void selectWorkspace(Workspace ws) {
    selectedWorkspace = ws;
    notifyListeners();
  }

  void deleteWorkspace(Workspace ws) {
    workspaces.remove(ws);
    if (selectedWorkspace == ws) {
      selectedWorkspace = workspaces.isNotEmpty ? workspaces.first : null;
    }
    notifyListeners();
    _save();
  }

  void addDevice(Device device) {
    selectedWorkspace?.devices.add(device);
    selectedWorkspace?.devices.sort(Device.sortByType);
    notifyListeners();
    _save();
  }

  void resetMaintenanceDate(Device device) {
    device.resetMaintenance();
    notifyListeners();
    _save();
  }

  void deleteDevice(Device device) {
    selectedWorkspace?.devices.remove(device);
    notifyListeners();
    _save();
  }

  void setThemePreference(AppThemePreference preference) {
    _userConfig = _userConfig.copyWith(themeMode: preference);
    notifyListeners();
    _saveConfig();
  }

  void setLanguage(AppLanguage language) {
    _userConfig = _userConfig.copyWith(language: language);
    notifyListeners();
    _saveConfig();
  }

  Future<String> exportWorkspaces(List<Workspace> toExport) async {
    return await _storage.exportToJson(toExport);
  }

  List<Workspace> importFromJsonPreview(String jsonString) {
    return _storage.importFromJson(jsonString);
  }

  void importWorkspacesSelected(List<Workspace> selected) {
    for (final ws in selected) {
      if (workspaces.length < AppConstants.maxWorkspaces) {
        ws.devices.sort(Device.sortByType);
        workspaces.add(ws);
      }
    }
    _sortAllWorkspaceDevices();
    selectedWorkspace ??= workspaces.isNotEmpty ? workspaces.first : null;
    notifyListeners();
    _save();
  }

  void _save() {
    _storage.saveData(user, workspaces);
    _saveConfig();
  }

  void _saveConfig() {
    _storage.saveUserConfig(_userConfig);
  }

  UserConfig _defaultConfigFromSystem() {
    final dispatcher = WidgetsBinding.instance.platformDispatcher;
    final languageCode = dispatcher.locale.languageCode.toLowerCase();
    final language = languageCode.startsWith('es')
        ? AppLanguage.es
        : AppLanguage.en;
    return UserConfig(
      userName: user?.name ?? '',
      themeMode: AppThemePreference.system,
      language: language,
    );
  }

  void _sortAllWorkspaceDevices() {
    for (final workspace in workspaces) {
      workspace.devices.sort(Device.sortByType);
    }
  }
}
