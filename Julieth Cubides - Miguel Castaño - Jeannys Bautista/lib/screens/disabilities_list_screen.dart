import 'package:flutter/material.dart';
import '../data/disabilities_data.dart';
import '../models/disability.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_list_item.dart';
import 'disability_detail_screen.dart';

class DisabilitiesListScreen extends StatelessWidget {
  const DisabilitiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _GradientAppBar(
        title: 'Discapacidades',
        subtitle: 'Tipos y características',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: disabilities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final disability = disabilities[index];
          return AnimatedListItem(
            index: index,
            child: _DisabilityCard(disability: disability),
          );
        },
      ),
    );
  }
}

class _DisabilityCard extends StatelessWidget {
  final Disability disability;

  const _DisabilityCard({required this.disability});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        slideRoute(DisabilityDetailScreen(disability: disability)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(Theme.of(context).brightness == Brightness.dark ? 50 : 13),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppGradients.main,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  disability.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disability.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disability.shortDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// AppBar with lime-green → dark-green gradient background (top-left to bottom-right).
class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  const _GradientAppBar({required this.title, this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.main,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
