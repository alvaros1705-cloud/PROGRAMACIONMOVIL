import 'package:flutter/material.dart';
import '../models/disability.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_list_item.dart';

class DisabilityDetailScreen extends StatelessWidget {
  final Disability disability;
  final int initialTab;

  const DisabilityDetailScreen({
    super.key,
    required this.disability,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppColors.darkBlue,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.only(left: 52, bottom: 56, right: 16),
                title: Text(
                  disability.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppGradients.main,
                  ),
                  child: Center(
                    child: Text(
                      disability.iconEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Información'),
                  Tab(text: 'Estrategias'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _InfoTab(disability: disability),
              _StrategiesTab(disability: disability),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Disability disability;

  const _InfoTab({required this.disability});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(emoji: 'ℹ️', title: '¿Qué es?'),
                const SizedBox(height: 12),
                Text(
                  disability.fullDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.7,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                    emoji: '🔍', title: 'Características principales'),
                const SizedBox(height: 12),
                ...disability.characteristics.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: AppGradients.main,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            c,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategiesTab extends StatelessWidget {
  final Disability disability;

  const _StrategiesTab({required this.disability});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: disability.strategies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final strategy = disability.strategies[index];
        return AnimatedListItem(
          index: index,
          child: _StrategyCard(strategy: strategy, index: index + 1),
        );
      },
    );
  }
}

class _StrategyCard extends StatelessWidget {
  final PedagogicalStrategy strategy;
  final int index;

  const _StrategyCard({required this.strategy, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppGradients.main,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    strategy.iconEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$index',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  strategy.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String emoji;
  final String title;

  const _SectionTitle({required this.emoji, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
