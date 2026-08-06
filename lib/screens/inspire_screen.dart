import 'package:flutter/material.dart';

import '../config/celebration_config.dart';
import '../features/appshub/bootstrap_store.dart';
import '../features/devotional/models/devotional_hub_config.dart';

class InspireScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const InspireScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final quotes = <String>[
      "Be still and know that I am God.",
      "The Word is working in me.",
      "I am favored and loved by God.",
    ];
    final bootstrap = CelebrationBootstrapScope.of(context).bootstrap;
    final devotional = DevotionalHubConfig.resolve(bootstrap);
    final sections = <_InspireSection>[
      if (devotional.visible)
        _InspireSection(
          order: devotional.order,
          child: _DevotionalHubEntry(
            config: devotional,
            onTap: () => onNavigate('/devotionals/${devotional.slug}'),
          ),
        ),
      _InspireSection(
        order: 100,
        child: _ExistingInspireQuotes(quotes: quotes),
      ),
    ]..sort((left, right) => left.order.compareTo(right.order));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 28),
      children: <Widget>[
        for (final section in sections) ...<Widget>[
          section.child,
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _InspireSection {
  final int order;
  final Widget child;

  const _InspireSection({required this.order, required this.child});
}

class _DevotionalHubEntry extends StatelessWidget {
  final DevotionalHubConfig config;
  final VoidCallback onTap;

  const _DevotionalHubEntry({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: <Color>[
              CelebrationConfig.primaryRoyalBlue,
              Color(0xFF07162F),
            ],
          ),
          border: Border.all(
            color: CelebrationConfig.secondaryGold.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              config.artwork.isEmpty
                  ? Image.asset(
                      CelebrationConfig.logoAssetPath,
                      width: 64,
                      height: 64,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        config.artwork,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          CelebrationConfig.logoAssetPath,
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      config.title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (config.subtitle.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        config.subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: CelebrationConfig.secondaryGold,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExistingInspireQuotes extends StatelessWidget {
  final List<String> quotes;

  const _ExistingInspireQuotes({required this.quotes});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0B172B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < quotes.length; index++) ...<Widget>[
            ListTile(
              leading: const Icon(
                Icons.bolt,
                color: CelebrationConfig.secondaryGold,
              ),
              title: Text(quotes[index]),
            ),
            if (index < quotes.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
