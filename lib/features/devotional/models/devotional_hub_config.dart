import '../../appshub/bootstrap_models.dart';
import 'devotional_destination.dart';

class DevotionalHubConfig {
  static const engineType = 'devotional_hub';
  static const adPolicyKey = 'inspire.devotional';

  final String engineKey;
  final String slug;
  final String title;
  final String subtitle;
  final String description;
  final String artwork;
  final String icon;
  final String placement;
  final int order;
  final bool visible;
  final bool featured;
  final List<DevotionalDestination> destinations;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  const DevotionalHubConfig({
    required this.engineKey,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artwork,
    required this.icon,
    required this.placement,
    required this.order,
    required this.visible,
    required this.featured,
    required this.destinations,
    required this.notificationSettings,
    required this.settings,
    required this.metadata,
  });

  factory DevotionalHubConfig.fromJson(Map<String, dynamic> json) {
    final children = <DevotionalDestination>[];
    final rawChildren = json['children'] ?? json['destinations'];
    if (rawChildren is List) {
      for (final item in rawChildren.whereType<Map>()) {
        final parsed = DevotionalDestination.tryFromJson(
          Map<String, dynamic>.from(item),
        );
        if (parsed != null) children.add(parsed);
      }
    }
    children.sort((left, right) {
      final order = left.order.compareTo(right.order);
      return order != 0
          ? order
          : left.engineType.index.compareTo(right.engineType.index);
    });

    return DevotionalHubConfig(
      engineKey: _text(json['engine_key'] ?? json['key']),
      slug: _text(json['slug']),
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      description: _text(json['description']),
      artwork: _text(json['artwork'] ?? json['artwork_url']),
      icon: _text(json['icon']),
      placement: _text(
        json['placement'] ?? json['section_placement'] ?? 'devotional',
      ),
      order: _integer(json['order'] ?? json['sort_order'], 20),
      visible: _boolean(
        json['visible'] ?? json['is_visible'] ?? json['enabled'],
        true,
      ),
      featured: _boolean(json['featured'] ?? json['is_featured'], false),
      destinations: List<DevotionalDestination>.unmodifiable(children),
      notificationSettings: Map<String, dynamic>.unmodifiable(
        _map(json['notification_settings']),
      ),
      settings: Map<String, dynamic>.unmodifiable(_map(json['settings'])),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }

  factory DevotionalHubConfig.bundled() {
    return DevotionalHubConfig.fromJson(<String, dynamic>{
      'engine_type': engineType,
      'engine_key': 'daily_devotional',
      'slug': 'rhema-for-living',
      'title': 'Rhema For Living',
      'subtitle': 'Daily devotional and spiritual growth',
      'placement': 'devotional',
      'order': 20,
      'visible': true,
      'children': <Map<String, dynamic>>[
        <String, dynamic>{
          'engine_type': 'devotional_read',
          'engine_key': 'daily_devotional_read',
          'title': 'Read Rhema For Living',
          'subtitle': 'Read the available daily devotional',
          'route': '/devotionals/rhema-for-living/read',
          'order': 10,
          'visible': true,
        },
        <String, dynamic>{
          'engine_type': 'devotional_watch',
          'engine_key': 'daily_devotional_watch',
          'title': 'Watch Rhema For Living',
          'subtitle': 'Open the available video or playlist',
          'route': '/devotionals/rhema-for-living/watch',
          'order': 20,
          'visible': true,
        },
        <String, dynamic>{
          'engine_type': 'devotional_quotes',
          'engine_key': 'daily_devotional_quotes',
          'title': 'Rhema For Living Quotes',
          'subtitle': 'Designed devotional quotes will appear here',
          'route': '/devotionals/rhema-for-living/quotes',
          'order': 30,
          'visible': true,
        },
        <String, dynamic>{
          'engine_type': 'devotional_quiz',
          'engine_key': 'daily_devotional_quiz',
          'title': 'Rhema For Living Quiz',
          'subtitle': 'Quiz availability is controlled by AppsHub',
          'route': '/devotionals/rhema-for-living/quiz',
          'order': 40,
          'visible': true,
        },
      ],
    });
  }

  static DevotionalHubConfig resolve(CelebrationBootstrap bootstrap) {
    final candidate = _findHub(bootstrap.raw) ??
        _findHub(bootstrap.unknownFields) ??
        _findHub(<String, dynamic>{
          'sections': bootstrap.sections.map((item) => item.raw).toList(),
        });
    if (candidate == null) return DevotionalHubConfig.bundled();
    final parsed = DevotionalHubConfig.fromJson(candidate);
    return parsed.slug.isEmpty ? DevotionalHubConfig.bundled() : parsed;
  }

  DevotionalDestination? destination(DevotionalEngineType type) {
    for (final item in destinations) {
      if (item.engineType == type) return item;
    }
    return null;
  }

  bool quizCapabilityEnabled(CelebrationBootstrap bootstrap) {
    final destination = this.destination(DevotionalEngineType.quiz);
    if (destination == null || !destination.visible) return false;
    final explicit = destination.settings['available'] ??
        destination.settings['enabled'] ??
        bootstrap.capabilities['devotional_quiz'] ??
        bootstrap.capabilities['quiz_engine'] ??
        bootstrap.capabilities['quiz'] ??
        bootstrap.featureFlags['devotional_quiz'];
    return _boolean(explicit, false);
  }
}

Map<String, dynamic>? _findHub(dynamic value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    if (_text(map['engine_type']).toLowerCase() ==
        DevotionalHubConfig.engineType) {
      return map;
    }
    for (final key in const <String>[
      'devotional_hub',
      'devotionals',
      'sections',
      'inspire',
      'hub',
      'data',
    ]) {
      if (!map.containsKey(key)) continue;
      final found = _findHub(map[key]);
      if (found != null) return found;
    }
  }
  if (value is List) {
    for (final item in value) {
      final found = _findHub(item);
      if (found != null) return found;
    }
  }
  return null;
}

String _text(dynamic value) => value?.toString().trim() ?? '';
Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
int _integer(dynamic value, int fallback) =>
    value is int ? value : int.tryParse(_text(value)) ?? fallback;
bool _boolean(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = _text(value).toLowerCase();
  if (<String>{'true', '1', 'yes', 'enabled'}.contains(normalized)) return true;
  if (<String>{'false', '0', 'no', 'disabled'}.contains(normalized)) {
    return false;
  }
  return fallback;
}
