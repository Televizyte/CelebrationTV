class ArticleChannel {
  final String slug;
  final String title;
  final String description;
  final String routeKey;
  final String tabPlacement;
  final String sectionPlacement;
  final String icon;
  final String artwork;
  final String layoutType;
  final int order;
  final bool visible;
  final bool featured;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> contentFilters;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> unknownFields;

  const ArticleChannel({
    required this.slug,
    required this.title,
    required this.description,
    required this.routeKey,
    required this.tabPlacement,
    required this.sectionPlacement,
    required this.icon,
    required this.artwork,
    required this.layoutType,
    required this.order,
    required this.visible,
    required this.featured,
    required this.notificationSettings,
    required this.contentFilters,
    required this.settings,
    required this.unknownFields,
  });

  factory ArticleChannel.fromJson(Map<String, dynamic> json) {
    const known = <String>{
      'slug',
      'title',
      'description',
      'route_key',
      'tab_placement',
      'section_placement',
      'icon',
      'artwork',
      'artwork_url',
      'layout_type',
      'layout',
      'order',
      'sort_order',
      'visible',
      'is_visible',
      'featured',
      'is_featured',
      'notification_settings',
      'content_filters',
      'settings',
    };
    return ArticleChannel(
      slug: _text(json['slug']),
      title: _text(json['title']),
      description: _text(json['description']),
      routeKey: _text(json['route_key']),
      tabPlacement: _text(json['tab_placement']),
      sectionPlacement: _text(json['section_placement']),
      icon: _text(json['icon']),
      artwork: _text(json['artwork'] ?? json['artwork_url']),
      layoutType: _text(json['layout_type'] ?? json['layout']),
      order: _integer(json['order'] ?? json['sort_order']),
      visible: _boolean(json['visible'] ?? json['is_visible'], true),
      featured: _boolean(json['featured'] ?? json['is_featured'], false),
      notificationSettings: _map(json['notification_settings']),
      contentFilters: _map(json['content_filters']),
      settings: _map(json['settings']),
      unknownFields: <String, dynamic>{
        for (final entry in json.entries)
          if (!known.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  static List<ArticleChannel> listFromPayload(dynamic value) {
    dynamic records = value;
    if (value is Map) {
      records = value['channels'] ?? value['article_channels'] ?? value['data'];
    }
    if (records is! List) return const <ArticleChannel>[];
    final channels = records
        .whereType<Map>()
        .map((record) => ArticleChannel.fromJson(
              Map<String, dynamic>.from(record),
            ))
        .where((channel) => channel.slug.isNotEmpty && channel.title.isNotEmpty)
        .toList(growable: false);
    channels.sort((left, right) => left.order.compareTo(right.order));
    return List<ArticleChannel>.unmodifiable(channels);
  }
}

String _text(dynamic value) => value?.toString().trim() ?? '';
int _integer(dynamic value) =>
    value is int ? value : int.tryParse(_text(value)) ?? 0;
bool _boolean(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = _text(value).toLowerCase();
  if (<String>{'true', '1', 'yes'}.contains(text)) return true;
  if (<String>{'false', '0', 'no'}.contains(text)) return false;
  return fallback;
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};
