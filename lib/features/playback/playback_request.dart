enum PlaybackSourceType {
  uploadedVideo('uploaded_video'),
  externalVideo('external_video'),
  hls('hls'),
  youtubeVideo('youtube_video'),
  youtubePlaylist('youtube_playlist'),
  webEmbed('web_embed'),
  externalLink('external_link'),
  unknown('unknown');

  final String wireKey;
  const PlaybackSourceType(this.wireKey);

  static PlaybackSourceType parse(dynamic value) {
    final key = value?.toString().trim().toLowerCase() ?? '';
    return values.firstWhere(
      (item) => item.wireKey == key,
      orElse: () => PlaybackSourceType.unknown,
    );
  }
}

class PlaybackRequest {
  final PlaybackSourceType sourceType;
  final String provider;
  final String url;
  final String providerId;
  final String mediaAssetId;
  final String mimeType;
  final bool isLive;
  final int? durationSeconds;
  final double? aspectRatio;
  final bool embedAllowed;
  final bool externalOpenAllowed;
  final String title;
  final String description;
  final String artwork;
  final String contentId;
  final String channelId;
  final String playlistId;
  final List<Map<String, dynamic>> relatedActions;
  final String advertisingPolicyKey;
  final Map<String, dynamic> metadata;

  const PlaybackRequest({
    required this.sourceType,
    required this.provider,
    required this.url,
    required this.providerId,
    required this.mediaAssetId,
    required this.mimeType,
    required this.isLive,
    required this.durationSeconds,
    required this.aspectRatio,
    required this.embedAllowed,
    required this.externalOpenAllowed,
    required this.title,
    required this.description,
    required this.artwork,
    required this.contentId,
    required this.channelId,
    required this.playlistId,
    required this.relatedActions,
    required this.advertisingPolicyKey,
    required this.metadata,
  });

  factory PlaybackRequest.fromJson(Map<String, dynamic> json) =>
      PlaybackRequest(
        sourceType: PlaybackSourceType.parse(json['source_type']),
        provider: _text(json['provider']),
        url: _text(json['url']),
        providerId: _text(json['provider_id']),
        mediaAssetId: _text(json['media_asset_id']),
        mimeType: _text(json['mime_type']),
        isLive: _bool(json['is_live'], false),
        durationSeconds: _intOrNull(json['duration_seconds']),
        aspectRatio: _doubleOrNull(json['aspect_ratio']),
        embedAllowed: _bool(json['embed_allowed'], false),
        externalOpenAllowed: _bool(json['external_open_allowed'], false),
        title: _text(json['title']),
        description: _text(json['description']),
        artwork: _text(json['artwork'] ?? json['artwork_url']),
        contentId: _text(json['content_id']),
        channelId: _text(json['channel_id']),
        playlistId: _text(json['playlist_id']),
        relatedActions: _mapList(json['related_actions']),
        advertisingPolicyKey: _text(json['advertising_policy_key']),
        metadata: Map<String, dynamic>.unmodifiable(json),
      );

  bool get isSupported => sourceType != PlaybackSourceType.unknown;
  bool get protectedContext =>
      isLive || sourceType != PlaybackSourceType.externalLink;
}

String _text(dynamic value) => value?.toString().trim() ?? '';
bool _bool(dynamic value, bool fallback) => value is bool
    ? value
    : value is num
        ? value != 0
        : fallback;
int? _intOrNull(dynamic value) =>
    value is int ? value : int.tryParse(_text(value));
double? _doubleOrNull(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(_text(value));
List<Map<String, dynamic>> _mapList(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) =>
            Map<String, dynamic>.unmodifiable(Map<String, dynamic>.from(item)))
        .toList(growable: false)
    : const <Map<String, dynamic>>[];
