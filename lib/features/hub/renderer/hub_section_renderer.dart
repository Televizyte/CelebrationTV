import 'package:flutter/material.dart';

import '../../../config/celebration_config.dart';
import '../models/hub_models.dart';
import 'hub_renderer_registry.dart';

class HubSectionRenderer extends StatelessWidget {
  final HubSection section;
  final ValueChanged<String> onNavigate;

  const HubSectionRenderer({
    super.key,
    required this.section,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final kind = HubRendererRegistry.resolve(section);
    if (kind == HubRendererKind.unavailable) {
      return _UnavailableSection(title: section.title);
    }
    if (section.items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (section.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Text(
              section.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        if (section.subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              section.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
          ),
        _content(kind),
      ],
    );
  }

  Widget _content(HubRendererKind kind) {
    switch (kind) {
      case HubRendererKind.heroCarousel:
        return SizedBox(
          height: 220,
          child: PageView.builder(
            padEnds: false,
            controller: PageController(viewportFraction: 0.9),
            itemCount: section.items.length,
            itemBuilder: (_, index) => Padding(
              padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 4),
              child: _HubCard(
                item: section.items[index],
                large: true,
                onNavigate: onNavigate,
              ),
            ),
          ),
        );
      case HubRendererKind.shortcutGrid:
        return LayoutBuilder(builder: (_, constraints) {
          final columns = constraints.maxWidth >= 700 ? 4 : 2;
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 1.55,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (_, index) => _HubCard(
              item: section.items[index],
              onNavigate: onNavigate,
            ),
          );
        });
      case HubRendererKind.editorial:
        return Column(
          children: section.items
              .map((item) => _EditorialTile(item: item, onNavigate: onNavigate))
              .toList(growable: false),
        );
      case HubRendererKind.liveCard:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _HubCard(
            item: section.items.first,
            large: true,
            onNavigate: onNavigate,
          ),
        );
      case HubRendererKind.horizontalCards:
      case HubRendererKind.videoRow:
      case HubRendererKind.quoteCard:
      case HubRendererKind.shortVideoCarousel:
        return SizedBox(
          height: 174,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: section.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => SizedBox(
              width: 220,
              child: _HubCard(
                item: section.items[index],
                onNavigate: onNavigate,
              ),
            ),
          ),
        );
      case HubRendererKind.unavailable:
        return _UnavailableSection(title: section.title);
    }
  }
}

class _HubCard extends StatelessWidget {
  final HubItem item;
  final bool large;
  final ValueChanged<String> onNavigate;

  const _HubCard(
      {required this.item, required this.onNavigate, this.large = false});

  @override
  Widget build(BuildContext context) {
    final route = item.action.route;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: route.isEmpty ? null : () => onNavigate(route),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF10213D),
          border: Border.all(
            color: CelebrationConfig.secondaryGold.withValues(alpha: 0.22),
          ),
          image: item.artwork.url.isEmpty
              ? null
              : DecorationImage(
                  image: NetworkImage(item.artwork.url),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.transparent,
                const Color(0xFF050C19).withValues(alpha: 0.94),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (item.badge.isNotEmpty)
                Text(
                  item.badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CelebrationConfig.secondaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                item.title,
                maxLines: large ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: large ? 20 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (item.subtitle.isNotEmpty)
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorialTile extends StatelessWidget {
  final HubItem item;
  final ValueChanged<String> onNavigate;
  const _EditorialTile({required this.item, required this.onNavigate});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: item.action.route.isEmpty
            ? null
            : () => onNavigate(item.action.route),
        leading: const Icon(Icons.article_outlined),
        title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: item.subtitle.isEmpty
            ? null
            : Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      );
}

class _UnavailableSection extends StatelessWidget {
  final String title;
  const _UnavailableSection({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title.isEmpty
              ? 'This section is not available yet.'
              : '$title is not available yet.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
