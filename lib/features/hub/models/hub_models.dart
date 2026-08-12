import '../../../config/celebration_config.dart';

enum HubEngineType {
  heroCarousel('hero_carousel'),
  shortcutGrid('shortcut_grid'),
  articleChannel('article_channel'),
  devotional('devotional'),
  quoteChannel('quote_channel'),
  shortVideoChannel('short_video_channel'),
  videoChannel('video_channel'),
  liveChannel('live_channel'),
  externalTvChannel('external_tv_channel'),
  bookLibrary('book_library'),
  tool('tool'),
  quiz('quiz'),
  game('game'),
  notificationList('notification_list'),
  account('account'),
  informationPage('information_page'),
  genericSection('generic_section'),
  unknown('unknown');

  final String wireKey;
  const HubEngineType(this.wireKey);

  static HubEngineType parse(dynamic value) {
    final key = _text(value).toLowerCase();
    return values.firstWhere(
      (item) => item.wireKey == key,
      orElse: () => HubEngineType.unknown,
    );
  }
}

class HubAction {
  final String type;
  final String route;
  final String url;
  final Map<String, dynamic> metadata;

  const HubAction({
    required this.type,
    required this.route,
    required this.url,
    required this.metadata,
  });

  factory HubAction.fromJson(dynamic value, {String fallbackRoute = ''}) {
    final json = _map(value);
    return HubAction(
      type: _text(json['type'] ?? json['action_type']),
      route: _safeRoute(_text(json['route'] ?? fallbackRoute)),
      url: _text(json['url']),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class HubArtwork {
  final String url;
  final String thumbnailUrl;
  final String alt;
  final Map<String, dynamic> metadata;

  const HubArtwork({
    required this.url,
    required this.thumbnailUrl,
    required this.alt,
    required this.metadata,
  });

  factory HubArtwork.fromJson(Map<String, dynamic> owner) {
    final nested = _map(owner['artwork'] ?? owner['media']);
    return HubArtwork(
      url: _text(
        nested['url'] ??
            nested['image_url'] ??
            owner['artwork_url'] ??
            owner['image_url'],
      ),
      thumbnailUrl: _text(
        nested['thumbnail_url'] ?? owner['thumbnail_url'],
      ),
      alt: _text(nested['alt'] ?? owner['artwork_alt']),
      metadata: Map<String, dynamic>.unmodifiable(nested),
    );
  }
}

class HubItem {
  final String id;
  final String key;
  final String engineKey;
  final HubEngineType engineType;
  final String slug;
  final String title;
  final String subtitle;
  final String description;
  final HubArtwork artwork;
  final String icon;
  final String badge;
  final int order;
  final bool visible;
  final bool featured;
  final HubAction action;
  final String contentId;
  final String channelId;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> notificationMetadata;
  final Map<String, dynamic> metadata;

  const HubItem({
    required this.id,
    required this.key,
    required this.engineKey,
    required this.engineType,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artwork,
    required this.icon,
    required this.badge,
    required this.order,
    required this.visible,
    required this.featured,
    required this.action,
    required this.contentId,
    required this.channelId,
    required this.filters,
    required this.settings,
    required this.notificationMetadata,
    required this.metadata,
  });

  factory HubItem.fromJson(Map<String, dynamic> json) => HubItem(
        id: _text(json['id']),
        key: _text(json['key']),
        engineKey: _text(json['engine_key']),
        engineType: HubEngineType.parse(json['engine_type'] ?? json['type']),
        slug: _text(json['slug']),
        title: _text(json['title']),
        subtitle: _text(json['subtitle']),
        description: _text(json['description']),
        artwork: HubArtwork.fromJson(json),
        icon: _text(json['icon']),
        badge: _text(json['badge']),
        order: _integer(json['order'] ?? json['sort_order'], 0),
        visible: _boolean(
          json['visible'] ?? json['enabled'] ?? json['is_visible'],
          true,
        ),
        featured: _boolean(json['featured'] ?? json['is_featured'], false),
        action: HubAction.fromJson(json['action'],
            fallbackRoute: _text(json['route'])),
        contentId: _text(json['content_id']),
        channelId: _text(json['channel_id'] ?? json['content_channel']),
        filters: Map<String, dynamic>.unmodifiable(_map(json['filters'])),
        settings: Map<String, dynamic>.unmodifiable(_map(json['settings'])),
        notificationMetadata: Map<String, dynamic>.unmodifiable(
          _map(json['notification_metadata'] ?? json['notification_settings']),
        ),
        metadata: Map<String, dynamic>.unmodifiable(json),
      );
}

class HubSection {
  final String id;
  final String key;
  final String engineKey;
  final HubEngineType engineType;
  final String slug;
  final String title;
  final String subtitle;
  final String description;
  final HubArtwork artwork;
  final String icon;
  final String badge;
  final String layoutType;
  final String placement;
  final int order;
  final bool visible;
  final bool featured;
  final HubAction action;
  final List<String> capabilityRequirements;
  final List<HubItem> items;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> advertising;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> notificationMetadata;
  final Map<String, dynamic> metadata;

  const HubSection({
    required this.id,
    required this.key,
    required this.engineKey,
    required this.engineType,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artwork,
    required this.icon,
    required this.badge,
    required this.layoutType,
    required this.placement,
    required this.order,
    required this.visible,
    required this.featured,
    required this.action,
    required this.capabilityRequirements,
    required this.items,
    required this.pagination,
    required this.advertising,
    required this.filters,
    required this.settings,
    required this.notificationMetadata,
    required this.metadata,
  });

  factory HubSection.fromJson(Map<String, dynamic> json) {
    final items = _mapList(json['items'] ?? json['content'])
        .map(HubItem.fromJson)
        .where((item) => item.visible)
        .toList(growable: false)
      ..sort(_byItemOrder);
    return HubSection(
      id: _text(json['id']),
      key: _text(json['key'] ?? json['section_key']),
      engineKey: _text(json['engine_key']),
      engineType: HubEngineType.parse(json['engine_type'] ?? json['type']),
      slug: _text(json['slug']),
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      description: _text(json['description']),
      artwork: HubArtwork.fromJson(json),
      icon: _text(json['icon']),
      badge: _text(json['badge']),
      layoutType:
          _text(json['layout_type'] ?? json['layout'] ?? json['template']),
      placement: _text(json['placement'] ?? json['section_placement']),
      order: _integer(json['order'] ?? json['sort_order'], 0),
      visible: _boolean(
        json['visible'] ?? json['enabled'] ?? json['is_visible'],
        true,
      ),
      featured: _boolean(json['featured'] ?? json['is_featured'], false),
      action: HubAction.fromJson(json['action'],
          fallbackRoute: _text(json['route'])),
      capabilityRequirements: _strings(
        json['capability_requirements'] ?? json['requires'],
      ),
      items: List<HubItem>.unmodifiable(items),
      pagination: Map<String, dynamic>.unmodifiable(_map(json['pagination'])),
      advertising: Map<String, dynamic>.unmodifiable(
        _map(json['advertising'] ?? json['ads']),
      ),
      filters: Map<String, dynamic>.unmodifiable(_map(json['filters'])),
      settings: Map<String, dynamic>.unmodifiable(_map(json['settings'])),
      notificationMetadata: Map<String, dynamic>.unmodifiable(
        _map(json['notification_metadata'] ?? json['notification_settings']),
      ),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class HubPayload {
  final String tab;
  final String appSlug;
  final String packageId;
  final List<HubSection> sections;
  final Map<String, dynamic> advertising;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> metadata;

  const HubPayload({
    required this.tab,
    required this.appSlug,
    required this.packageId,
    required this.sections,
    required this.advertising,
    required this.pagination,
    required this.metadata,
  });

  factory HubPayload.bundled(String tab) => HubPayload.parse(<String, dynamic>{
        'app': <String, dynamic>{
          'slug': CelebrationConfig.appSlug,
          'package_id': CelebrationConfig.androidPackageId,
        },
        'tab': tab,
        'sections': <dynamic>[],
      }, expectedTab: tab);

  factory HubPayload.parse(
    Map<String, dynamic> input, {
    required String expectedTab,
  }) {
    final wrapped = input['data'];
    final payload = wrapped is Map ? Map<String, dynamic>.from(wrapped) : input;
    final app = _map(payload['app'] ?? payload['application']);
    final slug = _text(app['slug'] ?? payload['app_slug'] ?? payload['slug']);
    final packageId = _text(
      app['package_id'] ?? payload['package_id'] ?? payload['application_id'],
    );
    final tab = _text(payload['tab'] ?? payload['tab_key'] ?? expectedTab)
        .toLowerCase();
    if (slug != CelebrationConfig.appSlug ||
        (packageId.isNotEmpty &&
            packageId != CelebrationConfig.androidPackageId)) {
      throw const FormatException(
          'The Hub payload belongs to another application.');
    }
    if (tab != expectedTab.toLowerCase()) {
      throw const FormatException('The Hub payload belongs to another tab.');
    }
    final sections = _mapList(payload['sections'])
        .map(HubSection.fromJson)
        .where((section) => section.visible)
        .toList(growable: false)
      ..sort(_bySectionOrder);
    return HubPayload(
      tab: tab,
      appSlug: slug,
      packageId: packageId,
      sections: List<HubSection>.unmodifiable(sections),
      advertising: Map<String, dynamic>.unmodifiable(
        _map(payload['advertising'] ?? payload['ads']),
      ),
      pagination:
          Map<String, dynamic>.unmodifiable(_map(payload['pagination'])),
      metadata: Map<String, dynamic>.unmodifiable(payload),
    );
  }

  Map<String, dynamic> toJson() => metadata;
}

int _byItemOrder(HubItem left, HubItem right) =>
    left.order.compareTo(right.order);
int _bySectionOrder(HubSection left, HubSection right) =>
    left.order.compareTo(right.order);
String _text(dynamic value) => value?.toString().trim() ?? '';
int _integer(dynamic value, int fallback) =>
    value is int ? value : int.tryParse(_text(value)) ?? fallback;
bool _boolean(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = _text(value).toLowerCase();
  if (<String>{'true', '1', 'yes', 'enabled'}.contains(normalized)) return true;
  if (<String>{'false', '0', 'no', 'disabled'}.contains(normalized))
    return false;
  return fallback;
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<Map<String, dynamic>> _mapList(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList()
    : <Map<String, dynamic>>[];
List<String> _strings(dynamic value) => value is List
    ? value.map(_text).where((item) => item.isNotEmpty).toList()
    : (_text(value).isEmpty ? <String>[] : <String>[_text(value)]);
String _safeRoute(String route) {
  final normalized = route.trim();
  return normalized.startsWith('/') &&
          !normalized.toLowerCase().contains('/sod')
      ? normalized
      : '';
}
