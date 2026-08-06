enum DevotionalEngineType {
  read('devotional_read', 'devotional.read'),
  watch('devotional_watch', 'devotional.watch'),
  quotes('devotional_quotes', 'devotional.quotes'),
  quiz('devotional_quiz', 'devotional.quiz');

  final String wireKey;
  final String adPolicyKey;

  const DevotionalEngineType(this.wireKey, this.adPolicyKey);

  static DevotionalEngineType? fromWireKey(String value) {
    final normalized = value.trim().toLowerCase();
    for (final type in values) {
      if (type.wireKey == normalized) return type;
    }
    return null;
  }
}

class DevotionalPlaybackSource {
  final String sourceType;
  final String provider;
  final String url;
  final String videoId;
  final String playlistId;
  final String mediaAssetId;
  final bool live;
  final Map<String, dynamic> metadata;

  const DevotionalPlaybackSource({
    required this.sourceType,
    required this.provider,
    required this.url,
    required this.videoId,
    required this.playlistId,
    required this.mediaAssetId,
    required this.live,
    required this.metadata,
  });

  factory DevotionalPlaybackSource.fromJson(Map<String, dynamic> json) {
    return DevotionalPlaybackSource(
      sourceType: _text(json['source_type'] ?? json['type']),
      provider: _text(json['provider']),
      url: _text(json['url'] ?? json['playback_url']),
      videoId: _text(json['video_id'] ?? json['provider_video_id']),
      playlistId: _text(
        json['playlist_id'] ?? json['provider_playlist_id'],
      ),
      mediaAssetId: _text(json['media_asset_id']),
      live: _boolean(json['live'] ?? json['is_live'], false),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }

  bool get hasSource =>
      sourceType.isNotEmpty &&
      (url.isNotEmpty ||
          videoId.isNotEmpty ||
          playlistId.isNotEmpty ||
          mediaAssetId.isNotEmpty);
}

class DevotionalQuoteDesign {
  final Map<String, dynamic> raw;

  const DevotionalQuoteDesign(this.raw);

  bool get hasDesignMetadata => raw.isNotEmpty;
  String get backgroundImage =>
      _text(raw['background_image_url'] ?? raw['background_image']);
  String get backgroundColor =>
      _text(raw['background_color'] ?? raw['bg_color']);
  String get gradientColor =>
      _text(raw['background_color_2'] ?? raw['gradient_color']);
  String get textColor => _text(raw['text_color']);
  String get fontFamily => _text(raw['font_family'] ?? raw['font_key']);
  double get fontSize => _double(raw['font_size'], 24, 12, 64);
  int get fontWeight => _integer(raw['font_weight'], 700);
  String get alignment => _text(raw['text_align']);
  double get lineHeight => _double(raw['line_height'], 1.35, 0.8, 2.4);
  double get aspectRatio => _double(raw['aspect_ratio'], 0.8, 0.4, 2.0);
  double get padding =>
      _double(raw['card_padding'] ?? raw['padding'], 24, 0, 72);
  double get overlay => _double(raw['overlay_strength'], 0.55, 0, 100) > 1
      ? _double(raw['overlay_strength'], 55, 0, 100) / 100
      : _double(raw['overlay_strength'], 0.55, 0, 1);
  String get watermark => _text(raw['watermark']);
  String get attribution =>
      _text(raw['attribution'] ?? raw['source'] ?? raw['author']);
}

class DevotionalQuote {
  final String id;
  final String text;
  final String attribution;
  final DevotionalQuoteDesign design;
  final Map<String, dynamic> metadata;

  const DevotionalQuote({
    required this.id,
    required this.text,
    required this.attribution,
    required this.design,
    required this.metadata,
  });

  factory DevotionalQuote.fromJson(Map<String, dynamic> json) {
    final payload = _map(json['payload']);
    final design = _normalizeQuoteDesign(<String, dynamic>{
      ..._map(json['design']),
      ..._map(payload['design']),
    });
    return DevotionalQuote(
      id: _text(json['id'] ?? json['slug']),
      text: _text(
        json['quote_text'] ?? json['quote'] ?? json['text'] ?? payload['text'],
      ),
      attribution: _text(
        json['attribution'] ?? json['source'] ?? json['author'],
      ),
      design: DevotionalQuoteDesign(Map<String, dynamic>.unmodifiable(design)),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }
}

class DevotionalPost {
  final String id;
  final String title;
  final String publicationDate;
  final String scripture;
  final String body;
  final String keyPoint;
  final List<String> assignments;
  final String prayer;
  final String furtherReading;
  final String author;
  final String artwork;
  final Map<String, dynamic> metadata;

  const DevotionalPost({
    required this.id,
    required this.title,
    required this.publicationDate,
    required this.scripture,
    required this.body,
    required this.keyPoint,
    required this.assignments,
    required this.prayer,
    required this.furtherReading,
    required this.author,
    required this.artwork,
    required this.metadata,
  });

  factory DevotionalPost.fromJson(Map<String, dynamic> json) {
    return DevotionalPost(
      id: _text(json['id'] ?? json['slug']),
      title: _text(json['title']),
      publicationDate: _text(
        json['publication_date'] ?? json['published_at'] ?? json['date'],
      ),
      scripture: _text(json['scripture'] ?? json['anchor_scripture']),
      body: _text(json['body'] ?? json['content']),
      keyPoint: _text(
        json['remember_this'] ?? json['key_point'] ?? json['key_points'],
      ),
      assignments: _strings(json['assignments']),
      prayer: _text(json['prayer']),
      furtherReading: _text(
        json['further_reading'] ?? json['related_media'],
      ),
      author: _text(json['author']),
      artwork: _text(json['artwork'] ?? json['artwork_url']),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }

  bool get hasContent => title.isNotEmpty || body.isNotEmpty;
}

class DevotionalDestination {
  final DevotionalEngineType engineType;
  final String engineKey;
  final String title;
  final String subtitle;
  final String description;
  final String route;
  final String artwork;
  final String icon;
  final int order;
  final bool visible;
  final bool featured;
  final String contentChannel;
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> metadata;

  const DevotionalDestination({
    required this.engineType,
    required this.engineKey,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.route,
    required this.artwork,
    required this.icon,
    required this.order,
    required this.visible,
    required this.featured,
    required this.contentChannel,
    required this.notificationSettings,
    required this.settings,
    required this.metadata,
  });

  static DevotionalDestination? tryFromJson(Map<String, dynamic> json) {
    final type = DevotionalEngineType.fromWireKey(_text(json['engine_type']));
    if (type == null) return null;
    return DevotionalDestination(
      engineType: type,
      engineKey: _text(json['engine_key'] ?? json['key']),
      title: _text(json['title']),
      subtitle: _text(json['subtitle']),
      description: _text(json['description']),
      route: _safeRoute(_text(json['route'] ?? _map(json['action'])['route'])),
      artwork: _text(json['artwork'] ?? json['artwork_url']),
      icon: _text(json['icon']),
      order:
          _integer(json['order'] ?? json['sort_order'], type.index * 10 + 10),
      visible: _boolean(
        json['visible'] ?? json['is_visible'] ?? json['enabled'],
        true,
      ),
      featured: _boolean(json['featured'] ?? json['is_featured'], false),
      contentChannel: _text(
        json['content_channel'] ??
            json['video_channel'] ??
            json['quote_channel'] ??
            json['quiz_definition'],
      ),
      notificationSettings: Map<String, dynamic>.unmodifiable(
        _map(json['notification_settings']),
      ),
      settings: Map<String, dynamic>.unmodifiable(_map(json['settings'])),
      metadata: Map<String, dynamic>.unmodifiable(json),
    );
  }

  String get adPolicyKey => engineType.adPolicyKey;
  bool get protectedContext =>
      engineType == DevotionalEngineType.watch ||
      engineType == DevotionalEngineType.quiz;

  DevotionalPlaybackSource get playback => DevotionalPlaybackSource.fromJson(
        <String, dynamic>{
          ..._map(metadata['playback']),
          ..._map(settings['playback']),
        },
      );

  DevotionalPost get post => DevotionalPost.fromJson(
        <String, dynamic>{
          ..._map(metadata['post']),
          ..._map(settings['post']),
        },
      );

  List<DevotionalQuote> get quotes {
    final raw = metadata['quotes'] ?? settings['quotes'];
    if (raw is! List) return const <DevotionalQuote>[];
    return raw
        .whereType<Map>()
        .map(
            (item) => DevotionalQuote.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.text.isNotEmpty)
        .toList(growable: false);
  }
}

String _text(dynamic value) => value?.toString().trim() ?? '';

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int _integer(dynamic value, int fallback) =>
    value is int ? value : int.tryParse(_text(value)) ?? fallback;

double _double(dynamic value, double fallback, double min, double max) {
  final parsed =
      value is num ? value.toDouble() : double.tryParse(_text(value));
  return (parsed ?? fallback).clamp(min, max).toDouble();
}

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

List<String> _strings(dynamic value) {
  if (value is List) {
    return value.map(_text).where((item) => item.isNotEmpty).toList();
  }
  final text = _text(value);
  return text.isEmpty ? const <String>[] : <String>[text];
}

String _safeRoute(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('/devotionals/') ? value.trim() : '';
}

Map<String, dynamic> _normalizeQuoteDesign(Map<String, dynamic> design) {
  final normalized = <String, dynamic>{...design};
  final background = _map(design['background']);
  final text = _map(design['text']);
  final attribution = _map(design['attribution']);

  void use(String key, dynamic value) {
    if (value != null && !normalized.containsKey(key)) normalized[key] = value;
  }

  use('background_image_url', background['image_url'] ?? background['image']);
  use('background_color', background['color']);
  use('background_color_2', background['color2'] ?? background['gradient']);
  use('overlay_strength',
      background['overlay_strength'] ?? background['overlay']);
  use('font_family', text['font_family'] ?? text['font_key']);
  use('font_size', text['font_size']);
  use('font_weight', text['font_weight']);
  use('text_align', text['align']);
  use('line_height', text['line_height']);
  use('text_color', text['color']);
  use('card_padding', text['padding']);
  if (design['attribution'] is Map) {
    normalized['attribution'] = attribution['text'];
  } else {
    use('attribution', attribution['text']);
  }
  return normalized;
}
