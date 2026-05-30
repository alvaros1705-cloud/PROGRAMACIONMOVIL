import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/app_viewmodel.dart';
import '../models/workspace.dart';

class WorkspaceDrawer extends StatefulWidget {
  final VoidCallback onSettings;

  const WorkspaceDrawer({super.key, required this.onSettings});

  @override
  State<WorkspaceDrawer> createState() => _WorkspaceDrawerState();
}

class _WorkspaceDrawerState extends State<WorkspaceDrawer> {
  bool _expanded = true;

  void _createWorkspace(BuildContext context, AppViewModel vm) {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.newWorkspace),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.workspaceName),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              vm.createWorkspace(controller.text.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.createWorkspace(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppViewModel vm, Workspace ws) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteWorkspace),
        content: Text(
          l10n.deleteWorkspaceConfirm(ws.name),
          style: Theme.of(context)
              .dialogTheme
              .contentTextStyle
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.82),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: const Color(0xFFFFF7F7),
              elevation: 0,
            ),
            onPressed: () {
              vm.deleteWorkspace(ws);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final l10n = AppLocalizations.of(context);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
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
          border: Border(
            right: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.38),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.06),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08),
              ),
              ListTile(
                leading: const Icon(Icons.workspaces),
                title: Text(l10n.workspaces),
                trailing:
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => _expanded = !_expanded),
              ),
              if (_expanded) ...[
                ...vm.workspaces.map((ws) => ListTile(
                      contentPadding:
                          const EdgeInsets.only(left: 32, right: 8),
                      title: Text(ws.name),
                      selected: vm.selectedWorkspace?.id == ws.id,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withValues(alpha: 0.18),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => _confirmDelete(context, vm, ws),
                      ),
                      onTap: () {
                        vm.selectWorkspace(ws);
                        Navigator.pop(context);
                      },
                    )),
                if (vm.workspaces.length < AppViewModel.maxWorkspaces)
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 32),
                    leading: const Icon(Icons.add),
                    title: Text(l10n.newWorkspace),
                    onTap: () => _createWorkspace(context, vm),
                  ),
              ],
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(l10n.settings),
                onTap: () {
                  Navigator.pop(context);
                  widget.onSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
