import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/app_viewmodel.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _workspaceController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _workspaceFocusNode = FocusNode();
  bool _step2 = false;

  @override
  void dispose() {
    _nameController.dispose();
    _workspaceController.dispose();
    _nameFocusNode.dispose();
    _workspaceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _step2
                ? _buildStep2(context, vm, l10n)
                : _buildStep1(context, vm, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1(
      BuildContext context, AppViewModel vm, AppLocalizations l10n) {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.welcomeToInduscare,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(l10n.setupQuestion),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_nameController.text.trim().isNotEmpty) {
              setState(() => _step2 = true);
            }
          },
          decoration: InputDecoration(labelText: l10n.yourName),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                setState(() => _step2 = true);
                _workspaceFocusNode.requestFocus();
              }
            },
            child: Text(l10n.next),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(
      BuildContext context, AppViewModel vm, AppLocalizations l10n) {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.createFirstWorkspace,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(l10n.workspaceHint),
        const SizedBox(height: 24),
        TextField(
          controller: _workspaceController,
          focusNode: _workspaceFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_workspaceController.text.trim().isNotEmpty) {
              vm.setUser(_nameController.text.trim());
              vm.createWorkspace(_workspaceController.text.trim());
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          decoration: InputDecoration(labelText: l10n.workspaceName),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_workspaceController.text.trim().isNotEmpty) {
                vm.setUser(_nameController.text.trim());
                vm.createWorkspace(_workspaceController.text.trim());
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: Text(l10n.getStarted),
          ),
        ),
      ],
    );
  }
}
