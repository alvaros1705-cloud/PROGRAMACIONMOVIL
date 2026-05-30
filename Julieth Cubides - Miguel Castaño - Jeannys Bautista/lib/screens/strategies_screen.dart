import 'package:flutter/material.dart';
import '../data/disabilities_data.dart';
import '../models/disability.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_list_item.dart';
import 'disability_detail_screen.dart';

class StrategiesScreen extends StatelessWidget {
  const StrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _GradientAppBar(
        title: 'Estrategias',
        subtitle: 'Recomendaciones pedagógicas',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: disabilities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final disability = disabilities[index];
          return AnimatedListItem(
            index: index,
            child: _StrategyGroupCard(disability: disability),
          );
        },
      ),
    );
  }
}

class _StrategyGroupCard extends StatelessWidget {
  final Disability disability;

  const _StrategyGroupCard({required this.disability});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        slideRoute(
            DisabilityDetailScreen(disability: disability, initialTab: 1)),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppGradients.main,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      disability.iconEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    disability.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppGradients.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${disability.strategies.length} estrategias',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: disability.strategies
                  .take(3)
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha(15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.blue.withAlpha(80), width: 1),
                      ),
                      child: Text(
                        '${s.iconEmoji} ${s.title}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (disability.strategies.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                'Ver ${disability.strategies.length - 3} más →',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
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
