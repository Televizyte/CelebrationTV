import '../../config/celebration_config.dart';

class BootstrapFormatException implements Exception {
  final String message;
  const BootstrapFormatException(this.message);

  @override
  String toString() => 'BootstrapFormatException: $message';
}

class AppIdentity {
  final String name;
  final String shortName;
  final String slug;
  final String packageId;

  const AppIdentity({
    required this.name,
    required this.shortName,
    required this.slug,
    required this.packageId,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'short_name': shortName,
        'slug': slug,
        'package_id': packageId,
      };
}

class BasicSectionMetadata {
  final String key;
  final String title;
  final String tabKey;
  final String template;
  final Map<String, dynamic> raw;

  const BasicSectionMetadata({
    required this.key,
    required this.title,
    required this.tabKey,
    required this.template,
    required this.raw,
  });

  factory BasicSectionMetadata.fromJson(Map<String, dynamic> json) {
    return BasicSectionMetadata(
      key: _string(json['key'] ?? json['section_key']),
      title: _string(json['title']),
      tabKey: _string(json['tab_key'] ?? json['tab']),
      template: _string(json['template'] ?? json['layout']),
      raw: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class CelebrationBootstrap {
  final AppIdentity identity;
  final Map<String, dynamic> branding;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> featureFlags;
  final List<Map<String, dynamic>> tabs;
  final List<Map<String, dynamic>> routes;
  final List<BasicSectionMetadata> sections;
  final Map<String, dynamic> advertising;
  final Map<String, dynamic> unknownFields;
  final Map<String, dynamic> raw;

  const CelebrationBootstrap({
    required this.identity,
    required this.branding,
    required this.capabilities,
    required this.featureFlags,
    required this.tabs,
    required this.routes,
    required this.sections,
    required this.advertising,
    required this.unknownFields,
    required this.raw,
  });

  factory CelebrationBootstrap.bundled() =>
      CelebrationBootstrap.parse(CelebrationConfig.bundledIdentity);

  factory CelebrationBootstrap.parse(Map<String, dynamic> input) {
    final wrapped = input['data'];
    final payload = wrapped is Map
        ? Map<String, dynamic>.from(wrapped)
        : Map<String, dynamic>.from(input);

    _validateStructuredIdentity(input);
    if (wrapped is Map) _validateStructuredIdentity(payload);
    _validateRoutes(payload['routes']);

    final app = _map(payload['app'] ?? payload['application']);
    final slug = _string(app['slug'] ?? payload['app_slug'] ?? payload['slug']);
    if (slug.isEmpty) {
      throw const BootstrapFormatException('The application slug is missing.');
    }
    if (slug != CelebrationConfig.appSlug) {
      throw const BootstrapFormatException(
        'The payload belongs to a different application.',
      );
    }
    final packageId = _string(
      app['package_id'] ??
          app['android_package_id'] ??
          app['application_id'] ??
          payload['package_id'] ??
          payload['android_package_id'] ??
          payload['application_id'],
    );
    if (packageId.isNotEmpty &&
        packageId != CelebrationConfig.androidPackageId) {
      throw const BootstrapFormatException(
        'The payload contains a different Android package identity.',
      );
    }

    final knownKeys = <String>{
      'app',
      'application',
      'app_slug',
      'slug',
      'app_name',
      'branding',
      'capabilities',
      'feature_flags',
      'tabs',
      'routes',
      'sections',
      'ads',
      'advertising',
    };
    final unknown = <String, dynamic>{
      for (final entry in payload.entries)
        if (!knownKeys.contains(entry.key)) entry.key: entry.value,
    };

    return CelebrationBootstrap(
      identity: AppIdentity(
        name: _fallback(
          _string(app['name'] ?? payload['app_name']),
          CelebrationConfig.appName,
        ),
        shortName: _fallback(
          _string(app['short_name']),
          CelebrationConfig.shortName,
        ),
        slug: slug,
        packageId: _fallback(packageId, CelebrationConfig.androidPackageId),
      ),
      branding: _map(payload['branding']),
      capabilities: _map(payload['capabilities']),
      featureFlags: _map(payload['feature_flags']),
      tabs: _mapList(payload['tabs']),
      routes: _mapList(payload['routes']),
      sections: _mapList(payload['sections'])
          .map(BasicSectionMetadata.fromJson)
          .toList(growable: false),
      advertising: _map(payload['ads'] ?? payload['advertising']),
      unknownFields: Map<String, dynamic>.unmodifiable(unknown),
      raw: Map<String, dynamic>.unmodifiable(payload),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        ...raw,
        'app': identity.toJson(),
        'branding': branding,
        'capabilities': capabilities,
        'feature_flags': featureFlags,
        'tabs': tabs,
        'routes': routes,
        'sections': sections.map((section) => section.raw).toList(),
        'ads': advertising,
      };
}

String _string(dynamic value) => value?.toString().trim() ?? '';
String _fallback(String value, String fallback) =>
    value.isEmpty ? fallback : value;

Map<String, dynamic> _map(dynamic value) => value is Map
    ? Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(value))
    : const <String, dynamic>{};

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.unmodifiable(
            Map<String, dynamic>.from(item),
          ))
      .toList(growable: false);
}

void _validateStructuredIdentity(Map<String, dynamic> payload) {
  final identityMaps = <Map<String, dynamic>>[
    _map(payload['app']),
    _map(payload['application']),
  ];

  final slugs = <String>[
    _string(payload['app_slug']),
    _string(payload['slug']),
    for (final identity in identityMaps) _string(identity['slug']),
  ];
  for (final slug in slugs.where((value) => value.isNotEmpty)) {
    if (slug != CelebrationConfig.appSlug) {
      throw const BootstrapFormatException(
        'The payload belongs to a different application.',
      );
    }
  }

  final packageIds = <String>[
    _string(payload['package_id']),
    _string(payload['android_package_id']),
    _string(payload['application_id']),
    for (final identity in identityMaps) ...<String>[
      _string(identity['package_id']),
      _string(identity['android_package_id']),
      _string(identity['application_id']),
    ],
  ];
  for (final packageId in packageIds.where((value) => value.isNotEmpty)) {
    if (packageId != CelebrationConfig.androidPackageId) {
      throw const BootstrapFormatException(
        'The payload contains a different Android package identity.',
      );
    }
  }

  final identityNames = <String>[
    _string(payload['app_name']),
    for (final identity in identityMaps) _string(identity['name']),
  ];
  if (identityNames.any(_isExcludedBrandIdentity)) {
    throw const BootstrapFormatException(
      'The payload contains content for a different application.',
    );
  }
}

void _validateRoutes(dynamic value) {
  for (final route in _mapList(value)) {
    final routeValues = <String>[
      _string(route['path']),
      _string(route['route']),
      _string(route['route_key']),
      _string(route['key']),
    ];
    if (routeValues.any(_isExcludedRoute)) {
      throw const BootstrapFormatException(
        'The payload contains a route for a different application.',
      );
    }
  }
}

bool _isExcludedBrandIdentity(String value) {
  final normalized = value.toLowerCase();
  return normalized.contains('dunamis') ||
      normalized.contains('seeds of destiny');
}

bool _isExcludedRoute(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('_', '-');
  if (normalized.isEmpty) return false;
  final segments =
      normalized.split(RegExp(r'[/.:]')).where((item) => item.isNotEmpty);
  return normalized.contains('dunamis') ||
      normalized.contains('seeds-of-destiny') ||
      segments.contains('sod');
}
