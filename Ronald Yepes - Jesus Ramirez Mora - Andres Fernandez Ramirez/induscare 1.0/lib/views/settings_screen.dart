import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/user_config.dart';
import '../models/workspace.dart';
import '../viewmodels/app_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportJson(BuildContext context, AppViewModel vm) async {
    final l10n = AppLocalizations.of(context);
    if (vm.workspaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noWorkspacesToExport)));
      return;
    }
    final selected = await _selectWorkspaces(context, vm.workspaces);
    if (selected == null || selected.isEmpty) return;
    final json = await vm.exportWorkspaces(selected);
    final bytes = utf8.encode(json);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: l10n.saveBackup,
      fileName: l10n.backupFileName,
      bytes: bytes,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(path != null
              ? l10n.exportedTo(path)
              : l10n.exportCancelled)));
    }
  }

  Future<void> _importJson(BuildContext context, AppViewModel vm) async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.bytes == null) return;
    final content = utf8.decode(file.bytes!);
    final imported = vm.importFromJsonPreview(content);
    if (!context.mounted) return;
    if (imported.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noValidWorkspaces)));
      return;
    }
    final selected = await _selectWorkspaces(context, imported);
    if (selected == null || selected.isEmpty) return;
    vm.importWorkspacesSelected(selected);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importSuccess)));
    }
  }

  Future<List<Workspace>?> _selectWorkspaces(
      BuildContext context, List<Workspace> workspaces) async {
    final selected = List<bool>.filled(workspaces.length, true);
    return showDialog<List<Workspace>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(AppLocalizations.of(ctx).selectWorkspaces),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              workspaces.length,
              (i) => CheckboxListTile(
                title: Text(workspaces[i].name),
                value: selected[i],
                onChanged: (v) => setState(() => selected[i] = v!),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx).cancel)),
            ElevatedButton(
              onPressed: () {
                final result = <Workspace>[];
                for (int i = 0; i < workspaces.length; i++) {
                  if (selected[i]) result.add(workspaces[i]);
                }
                Navigator.pop(ctx, result);
              },
              child: Text(AppLocalizations.of(ctx).confirm),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [
                    Color(0xFF0D0B14),
                    Color(0xFF1A1630),
                  ]
                : const [
                    Color(0xFFECE5F7),
                    Color(0xFFF6F2FC),
                  ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n.themeMode),
                  subtitle: Text(l10n.themeAndLanguage),
                  trailing: SegmentedButton<AppThemePreference>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    segments: [
                      ButtonSegment<AppThemePreference>(
                        value: AppThemePreference.light,
                        label: Text(l10n.themeLight),
                      ),
                      ButtonSegment<AppThemePreference>(
                        value: AppThemePreference.dark,
                        label: Text(l10n.themeDark),
                      ),
                    ],
                    selected: {
                      vm.themePreference == AppThemePreference.system
                          ? (MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark
                              ? AppThemePreference.dark
                              : AppThemePreference.light)
                          : vm.themePreference,
                    },
                    onSelectionChanged: (selection) {
                      final value = selection.first;
                      vm.setThemePreference(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: DropdownButton<AppLanguage>(
                    value: vm.appLanguage,
                    items: [
                      DropdownMenuItem(
                        value: AppLanguage.es,
                        child: Text(l10n.spanish),
                      ),
                      DropdownMenuItem(
                        value: AppLanguage.en,
                        child: Text(l10n.english),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) vm.setLanguage(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.upload),
                  title: Text(l10n.exportJson),
                  onTap: () => _exportJson(context, vm),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.importJson),
                  onTap: () => _importJson(context, vm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
