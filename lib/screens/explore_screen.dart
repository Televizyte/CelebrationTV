import 'package:flutter/material.dart';

import '../features/appshub/bootstrap_store.dart';
import '../features/hub/renderer/hub_section_renderer.dart';

class ExploreScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const ExploreScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final store = CelebrationBootstrapScope.of(context);
    final sections = store.hub('explore').sections;
    final refreshing = store.hubRefreshing('explore');
    final error = store.hubError('explore');

    if (sections.isEmpty) {
      return SafeArea(
        child: RefreshIndicator(
          onRefresh: () => store.refreshHub('explore'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(28),
            children: <Widget>[
              const SizedBox(height: 120),
              Icon(
                Icons.explore_outlined,
                size: 52,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
              const SizedBox(height: 18),
              Text(
                refreshing
                    ? 'Refreshing Celebration TV Explore...'
                    : error != null && error.isNotEmpty
                        ? error
                        : 'Explore content is not available offline yet.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Pull down to refresh.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => store.refreshHub('explore'),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 14,
            bottom: 28,
          ),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 22),
          itemBuilder: (_, index) => HubSectionRenderer(
            section: sections[index],
            onNavigate: onNavigate,
          ),
        ),
      ),
    );
  }
}
