import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/device.dart';
import '../viewmodels/app_viewmodel.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  DeviceType _type = DeviceType.pc;
  final _formKey = GlobalKey<FormState>();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ownerFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  DateTime _maintenanceDate = DateTime.now();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _ownerController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _phoneController.dispose();
    _ownerFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _maintenanceDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      _ownerFocusNode.requestFocus();
      return;
    }

    final device = Device(
      type: _type,
      ownerName: _ownerController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      maintenanceDate: _maintenanceDate,
    );
    context.read<AppViewModel>().addDevice(device);
    Navigator.pop(context);
  }

  void _validateForm() {
    final valid = _ownerController.text.trim().isNotEmpty;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.addDevice,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            DropdownButtonFormField<DeviceType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.deviceType),
              items: DeviceType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(_deviceTypeLabel(l10n, t)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ownerController,
              focusNode: _ownerFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
              decoration: InputDecoration(labelText: l10n.ownerName),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return l10n.ownerRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              decoration: InputDecoration(labelText: l10n.phoneNumberOptional),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.maintenanceDate),
                child: Text(DateFormat('dd/MM/yyyy').format(_maintenanceDate)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isFormValid
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _save : null,
                      child: Text(l10n.save),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _deviceTypeLabel(AppLocalizations l10n, DeviceType type) {
    switch (type) {
      case DeviceType.phone:
        return l10n.phoneType;
      case DeviceType.pc:
        return l10n.pcType;
      case DeviceType.laptop:
        return l10n.laptopType;
    }
  }
}
