import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isPressed = false;

  IconData _iconForType(DeviceType type) {
    switch (type) {
      case DeviceType.pc:
        return Icons.desktop_windows_outlined;
      case DeviceType.laptop:
        return Icons.laptop_mac_rounded;
      case DeviceType.phone:
        return Icons.phone_android;
    }
  }

  Color _statusColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF6CAF8A);
      case 1:
        return const Color(0xFFCDB166);
      default:
        return const Color(0xFFD98A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(widget.device.statusLevel);
    final theme = Theme.of(context);
    final cardGradient = theme.brightness == Brightness.dark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHigh,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.38),
            ],
          );
    final iconGradient = theme.brightness == Brightness.dark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.78),
              theme.colorScheme.primary.withValues(alpha: 0.42),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
              theme.colorScheme.primary.withValues(alpha: 0.12),
            ],
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          elevation: 2,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.07),
              width: 1,
            ),
          ),
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final iconSize = (constraints.maxWidth * 0.5).clamp(65.0, 90.0);
                  final iconContainer = (constraints.maxWidth * 0.65).clamp(80.0, 110.0);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Center(
                                  child: Container(
                                    width: iconContainer,
                                    height: iconContainer,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: iconGradient,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.08),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: theme.brightness == Brightness.dark ? 0.015 : 0.03),
                                          blurRadius: 5,
                                          offset: const Offset(-1, -1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _iconForType(widget.device.type),
                                      size: iconSize,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.device.ownerName,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
