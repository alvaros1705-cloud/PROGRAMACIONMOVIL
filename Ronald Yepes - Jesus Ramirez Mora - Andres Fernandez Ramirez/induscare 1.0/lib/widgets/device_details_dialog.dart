import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/device.dart';
import '../viewmodels/app_viewmodel.dart';

class DeviceDetailsDialog extends StatelessWidget {
  final Device device;

  const DeviceDetailsDialog({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final l10n = AppLocalizations.of(context);
    final dateStr = DateFormat('dd/MM/yyyy').format(device.maintenanceDate);
    final typeLabel = _typeLabel(l10n, device.type);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(typeLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(l10n.type, typeLabel),
          _row(l10n.owner, device.ownerName),
          if (device.phoneNumber != null && device.phoneNumber!.isNotEmpty)
            _row(l10n.phone, device.phoneNumber!),
          _row(l10n.lastMaintenance, dateStr),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            vm.resetMaintenanceDate(device);
            Navigator.pop(context);
          },
          child: Text(l10n.resetToday),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  String _typeLabel(AppLocalizations l10n, DeviceType type) {
    switch (type) {
      case DeviceType.phone:
        return l10n.phoneType;
      case DeviceType.pc:
        return l10n.pcType;
      case DeviceType.laptop:
        return l10n.laptopType;
    }
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
