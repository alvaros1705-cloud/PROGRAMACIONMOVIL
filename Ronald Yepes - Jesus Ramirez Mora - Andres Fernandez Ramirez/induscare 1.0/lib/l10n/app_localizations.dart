import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appName': 'IndusCare',
      'deviceMaintenanceManager': 'Device Maintenance Manager',
      'welcomeToInduscare': 'Welcome to IndusCare',
      'setupQuestion': 'Let\'s get you set up. What\'s your name?',
      'yourName': 'Your name',
      'next': 'Next',
      'createFirstWorkspace': 'Create your first workspace',
      'workspaceHint': 'A workspace groups your devices together.',
      'workspaceName': 'Workspace name',
      'getStarted': 'Get Started',
      'settings': 'Settings',
      'workspaces': 'Workspaces',
      'newWorkspace': 'New Workspace',
      'create': 'Create',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'deleteWorkspace': 'Delete Workspace',
      'darkMode': 'Dark Mode',
      'themeMode': 'Theme mode',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'language': 'Language',
      'spanish': 'Spanish',
      'english': 'English',
      'exportJson': 'Export JSON',
      'importJson': 'Import JSON',
      'saveBackup': 'Save IndusCare backup',
      'backupFileName': 'induscare_backup.json',
      'noWorkspacesToExport': 'No workspaces to export.',
      'exportCancelled': 'Export cancelled',
      'exportedTo': 'Exported to {path}',
      'noValidWorkspaces': 'No valid workspaces found in file.',
      'importSuccess': 'Import successful!',
      'selectWorkspaces': 'Select Workspaces',
      'addDevice': 'Add Device',
      'deviceType': 'Device Type',
      'ownerName': 'Owner Name (optional)',
      'ownerRequired': 'Owner name is required.',
      'phoneNumberOptional': 'Phone Number (optional)',
      'maintenanceDate': 'Maintenance Date',
      'save': 'Save',
      'requiredField': 'This field is required.',
      'noWorkspaceSelected': 'No workspace selected.\nCreate one in the sidebar.',
      'noDevicesYet': 'No devices added yet.',
      'phones': 'Phones',
      'pcs': 'PCs',
      'laptops': 'Laptops',
      'phoneType': 'Phone',
      'pcType': 'PC',
      'laptopType': 'Laptop',
      'type': 'Type',
      'phone': 'Phone',
      'owner': 'Owner',
      'lastMaintenance': 'Last Maintenance',
      'resetToday': 'Reset to Today',
      'close': 'Close',
      'deleteWorkspaceConfirm': 'Delete "{name}"? This cannot be undone.',
      'themeAndLanguage': 'Theme & Language',
    },
    'es': {
      'appName': 'IndusCare',
      'deviceMaintenanceManager': 'Gestor de mantenimiento de dispositivos',
      'welcomeToInduscare': 'Bienvenido a IndusCare',
      'setupQuestion': 'Vamos a configurarte. Como te llamas?',
      'yourName': 'Tu nombre',
      'next': 'Siguiente',
      'createFirstWorkspace': 'Crea tu primer espacio de trabajo',
      'workspaceHint': 'Un espacio agrupa tus dispositivos.',
      'workspaceName': 'Nombre del espacio',
      'getStarted': 'Comenzar',
      'settings': 'Configuracion',
      'workspaces': 'Espacios de trabajo',
      'newWorkspace': 'Nuevo espacio de trabajo',
      'create': 'Crear',
      'cancel': 'Cancelar',
      'confirm': 'Confirmar',
      'delete': 'Eliminar',
      'deleteWorkspace': 'Eliminar espacio',
      'darkMode': 'Modo oscuro',
      'themeMode': 'Tema',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeSystem': 'Sistema',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'Ingles',
      'exportJson': 'Exportar JSON',
      'importJson': 'Importar JSON',
      'saveBackup': 'Guardar respaldo de IndusCare',
      'backupFileName': 'respaldo_induscare.json',
      'noWorkspacesToExport': 'No hay espacios para exportar.',
      'exportCancelled': 'Exportacion cancelada',
      'exportedTo': 'Exportado en {path}',
      'noValidWorkspaces': 'No se encontraron espacios validos en el archivo.',
      'importSuccess': 'Importacion completada',
      'selectWorkspaces': 'Selecciona espacios',
      'addDevice': 'Agregar dispositivo',
      'deviceType': 'Tipo de dispositivo',
      'ownerName': 'Nombre del responsable',
      'ownerRequired': 'El nombre del responsable es obligatorio.',
      'phoneNumberOptional': 'Telefono (opcional)',
      'maintenanceDate': 'Fecha de mantenimiento',
      'save': 'Guardar',
      'requiredField': 'Este campo es obligatorio.',
      'noWorkspaceSelected': 'No hay un espacio de trabajo seleccionado.\nCrea uno en el menu lateral.',
      'noDevicesYet': 'Aun no hay dispositivos.',
      'phones': 'Telefonos',
      'pcs': 'PCs',
      'laptops': 'Laptops',
      'phoneType': 'Telefono',
      'pcType': 'PC',
      'laptopType': 'Laptop',
      'type': 'Tipo',
      'phone': 'Telefono',
      'owner': 'Responsable',
      'lastMaintenance': 'Ultimo mantenimiento',
      'resetToday': 'Reiniciar Fecha',
      'close': 'Cerrar',
      'deleteWorkspaceConfirm': 'Eliminar "{name}"? Esta accion no se puede deshacer.',
      'themeAndLanguage': 'Tema e idioma',
    },
  };

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    return localizations!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _text(String key) {
    final lang = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return lang[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get appName => _text('appName');
  String get deviceMaintenanceManager => _text('deviceMaintenanceManager');
  String get welcomeToInduscare => _text('welcomeToInduscare');
  String get setupQuestion => _text('setupQuestion');
  String get yourName => _text('yourName');
  String get next => _text('next');
  String get createFirstWorkspace => _text('createFirstWorkspace');
  String get workspaceHint => _text('workspaceHint');
  String get workspaceName => _text('workspaceName');
  String get getStarted => _text('getStarted');
  String get settings => _text('settings');
  String get workspaces => _text('workspaces');
  String get newWorkspace => _text('newWorkspace');
  String get create => _text('create');
  String get cancel => _text('cancel');
  String get confirm => _text('confirm');
  String get delete => _text('delete');
  String get deleteWorkspace => _text('deleteWorkspace');
  String get darkMode => _text('darkMode');
  String get themeMode => _text('themeMode');
  String get themeLight => _text('themeLight');
  String get themeDark => _text('themeDark');
  String get themeSystem => _text('themeSystem');
  String get language => _text('language');
  String get spanish => _text('spanish');
  String get english => _text('english');
  String get exportJson => _text('exportJson');
  String get importJson => _text('importJson');
  String get saveBackup => _text('saveBackup');
  String get backupFileName => _text('backupFileName');
  String get noWorkspacesToExport => _text('noWorkspacesToExport');
  String get exportCancelled => _text('exportCancelled');
  String exportedTo(String path) => _text('exportedTo').replaceAll('{path}', path);
  String get noValidWorkspaces => _text('noValidWorkspaces');
  String get importSuccess => _text('importSuccess');
  String get selectWorkspaces => _text('selectWorkspaces');
  String get addDevice => _text('addDevice');
  String get deviceType => _text('deviceType');
  String get ownerName => _text('ownerName');
  String get ownerRequired => _text('ownerRequired');
  String get phoneNumberOptional => _text('phoneNumberOptional');
  String get maintenanceDate => _text('maintenanceDate');
  String get save => _text('save');
  String get requiredField => _text('requiredField');
  String get noWorkspaceSelected => _text('noWorkspaceSelected');
  String get noDevicesYet => _text('noDevicesYet');
  String get phones => _text('phones');
  String get pcs => _text('pcs');
  String get laptops => _text('laptops');
  String get phoneType => _text('phoneType');
  String get pcType => _text('pcType');
  String get laptopType => _text('laptopType');
  String get type => _text('type');
  String get phone => _text('phone');
  String get owner => _text('owner');
  String get lastMaintenance => _text('lastMaintenance');
  String get resetToday => _text('resetToday');
  String get close => _text('close');
  String deleteWorkspaceConfirm(String name) =>
      _text('deleteWorkspaceConfirm').replaceAll('{name}', name);
  String get themeAndLanguage => _text('themeAndLanguage');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((element) => element.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
