import 'package:flutter/material.dart';

import '../../../config/celebration_config.dart';
import '../models/devotional_destination.dart';
import '../models/devotional_hub_config.dart';
import '../widgets/devotional_destination_card.dart';

class DevotionalHubScreen extends StatelessWidget {
  final DevotionalHubConfig config;
  final ValueChanged<String> onNavigate;
  final VoidCallback onBack;

  const DevotionalHubScreen({
    super.key,
    required this.config,
    required this.onNavigate,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = config.destinations
        .where((destination) => destination.visible)
        .toList(growable: false);
    return Scaffold(
      backgroundColor: const Color(0xFF050C19),
      appBar: AppBar(
        backgroundColor: CelebrationConfig.primaryRoyalBlue,
        leading: BackButton(onPressed: onBack),
        title: Text(config.title),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(child: _HubHeader(config: config)),
          if (destinations.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _DevotionalEmptyState(
                message:
                    'Devotional destinations will appear when they are enabled.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              sliver: SliverGrid.builder(
                itemCount: destinations.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 360,
                  mainAxisExtent: 210,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return DevotionalDestinationCard(
                    destination: destination,
                    onTap: () => onNavigate(
                      _routeFor(destination, config.slug),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

String _routeFor(DevotionalDestination destination, String slug) {
  if (destination.route.trim().isNotEmpty) return destination.route;
  final suffix = switch (destination.engineType) {
    DevotionalEngineType.read => 'read',
    DevotionalEngineType.watch => 'watch',
    DevotionalEngineType.quotes => 'quotes',
    DevotionalEngineType.quiz => 'quiz',
  };
  return '/devotionals/${Uri.encodeComponent(slug)}/$suffix';
}

class _HubHeader extends StatelessWidget {
  final DevotionalHubConfig config;

  const _HubHeader({required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: <Color>[
              CelebrationConfig.primaryRoyalBlue,
              Color(0xFF07162F),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: <Widget>[
              config.artwork.isEmpty
                  ? Image.asset(
                      CelebrationConfig.logoAssetPath,
                      width: 78,
                      height: 78,
                      fit: BoxFit.contain,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        config.artwork,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          CelebrationConfig.logoAssetPath,
                          width: 78,
                          height: 78,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      config.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (config.subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 7),
                      Text(
                        config.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevotionalEmptyState extends StatelessWidget {
  final String message;

  const _DevotionalEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        ),
      ),
    );
  }
}
