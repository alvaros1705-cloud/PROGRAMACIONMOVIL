import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/device.dart';
import '../viewmodels/app_viewmodel.dart';
import '../widgets/device_card.dart';
import '../widgets/device_details_dialog.dart';
import '../widgets/workspace_drawer.dart';
import 'add_device_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final l10n = AppLocalizations.of(context);
    final workspace = vm.selectedWorkspace;
    final grouped = <DeviceType, List<Device>>{
      DeviceType.pc: [],
      DeviceType.laptop: [],
      DeviceType.phone: [],
    };
    if (workspace != null) {
      for (final device in workspace.devices) {
        grouped[device.type]!.add(device);
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(workspace?.name ?? l10n.appName),
        centerTitle: true,
      ),
      drawer: WorkspaceDrawer(
        onSettings: () => Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 280),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (_, animation, __) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: const SettingsScreen(),
            ),
          ),
        ),
      ),
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
          child: workspace == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspaces_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(l10n.noWorkspaceSelected,
                          textAlign: TextAlign.center),
                    ],
                  ),
                )
              : workspace.devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices_other,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(l10n.noDevicesYet,
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      children: [
                        _buildGroupSection(
                          context,
                          title: l10n.pcs,
                          devices: grouped[DeviceType.pc]!,
                        ),
                        _buildGroupSection(
                          context,
                          title: l10n.laptops,
                          devices: grouped[DeviceType.laptop]!,
                        ),
                        _buildGroupSection(
                          context,
                          title: l10n.phones,
                          devices: grouped[DeviceType.phone]!,
                        ),
                      ],
                    ),
        ),
      ),
      floatingActionButton: workspace != null
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.88),
                        ]
                      : [
                          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.95),
                          Theme.of(context).colorScheme.primary,
                        ],
                ),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                elevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  sheetAnimationStyle: const AnimationStyle(
                    duration: Duration(milliseconds: 280),
                    reverseDuration: Duration(milliseconds: 220),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const AddDeviceScreen(),
                ),
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }

  Widget _buildGroupSection(
    BuildContext context, {
    required String title,
    required List<Device> devices,
  }) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            itemCount: devices.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(
                device: device,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => DeviceDetailsDialog(device: device),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
