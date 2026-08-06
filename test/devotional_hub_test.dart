import 'dart:io';

import 'package:celebration_tv/config/celebration_config.dart';
import 'package:celebration_tv/features/appshub/bootstrap_models.dart';
import 'package:celebration_tv/features/devotional/models/devotional_destination.dart';
import 'package:celebration_tv/features/devotional/models/devotional_hub_config.dart';
import 'package:celebration_tv/navigation/app_navigation_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled hub exposes exactly four neutral devotional engines', () {
    final config = DevotionalHubConfig.bundled();

    expect(config.slug, 'rhema-for-living');
    expect(
      config.destinations.map((item) => item.engineType),
      orderedEquals(DevotionalEngineType.values),
    );
    expect(
      config.destinations.map((item) => item.engineType.wireKey),
      orderedEquals(<String>[
        'devotional_read',
        'devotional_watch',
        'devotional_quotes',
        'devotional_quiz',
      ]),
    );
  });

  test('AppsHub controls hub labels, ordering, visibility, and metadata', () {
    final bootstrap = _bootstrap(<String, dynamic>{
      'devotional_hub': <String, dynamic>{
        'engine_type': 'devotional_hub',
        'engine_key': 'rhema_daily',
        'slug': 'rhema-for-living',
        'title': 'Today in Rhema',
        'subtitle': 'Backend subtitle',
        'artwork_url': 'https://example.invalid/rhema.webp',
        'order': 7,
        'featured': true,
        'notification_settings': <String, dynamic>{'topic': 'rhema'},
        'future_hub_field': 'preserved',
        'children': <dynamic>[
          <String, dynamic>{
            'engine_type': 'devotional_quotes',
            'title': 'Words to Keep',
            'order': 1,
            'visible': true,
          },
          <String, dynamic>{
            'engine_type': 'future_devotional_engine',
            'title': 'Unsupported child',
            'order': 2,
          },
          <String, dynamic>{
            'engine_type': 'devotional_read',
            'title': 'Read Today',
            'order': 3,
            'visible': false,
          },
        ],
      },
    });

    final config = DevotionalHubConfig.resolve(bootstrap);
    expect(config.title, 'Today in Rhema');
    expect(config.order, 7);
    expect(config.featured, isTrue);
    expect(config.notificationSettings['topic'], 'rhema');
    expect(config.metadata['future_hub_field'], 'preserved');
    expect(config.destinations, hasLength(2));
    expect(config.destinations.first.title, 'Words to Keep');
    expect(config.destination(DevotionalEngineType.read)!.visible, isFalse);
  });

  test('only neutral parameterized devotional routes are accepted', () {
    for (final route in <String>[
      '/devotionals/rhema-for-living',
      '/devotionals/rhema-for-living/read',
      '/devotionals/rhema-for-living/watch',
      '/devotionals/rhema-for-living/quotes',
      '/devotionals/rhema-for-living/quiz',
    ]) {
      expect(AppRouteContract.isKnown(route), isTrue, reason: route);
      expect(AppRouteContract.ownerOf(route), CanonicalTab.inspire);
    }

    for (final route in <String>[
      '/sod',
      '/watch/sod',
      '/devotionals/rhema-for-living/foreign',
      '/devotionals/bad_slug/read',
    ]) {
      expect(AppRouteContract.isKnown(route), isFalse, reason: route);
    }

    final unsafe = DevotionalDestination.tryFromJson(<String, dynamic>{
      'engine_type': 'devotional_read',
      'route': '/sod/today',
    });
    expect(unsafe!.route, isEmpty);
  });

  test('quote design metadata supports nested and missing designs', () {
    final quote = DevotionalQuote.fromJson(<String, dynamic>{
      'id': 'q1',
      'quote_text': 'Grace is sufficient.',
      'design': <String, dynamic>{
        'background': <String, dynamic>{
          'color': '#0D47A1',
          'image_url': 'https://example.invalid/background.webp',
          'overlay': 65,
        },
        'text': <String, dynamic>{
          'color': '#FFFFFF',
          'font_family': 'serif',
          'font_size': 30,
        },
        'attribution': <String, dynamic>{'text': 'Rhema For Living'},
      },
    });
    final plain = DevotionalQuote.fromJson(<String, dynamic>{
      'quote_text': 'A plain backend quote.',
    });

    expect(quote.design.backgroundColor, '#0D47A1');
    expect(quote.design.textColor, '#FFFFFF');
    expect(quote.design.fontSize, 30);
    expect(quote.design.overlay, 0.65);
    expect(quote.design.attribution, 'Rhema For Living');
    expect(plain.design.hasDesignMetadata, isFalse);
  });

  test('quiz stays unavailable unless AppsHub explicitly enables it', () {
    final bundled = CelebrationBootstrap.bundled();
    expect(
      DevotionalHubConfig.resolve(bundled).quizCapabilityEnabled(bundled),
      isFalse,
    );

    final enabled = _bootstrap(<String, dynamic>{
      'capabilities': <String, dynamic>{'devotional_quiz': true},
      'devotional_hub': <String, dynamic>{
        'engine_type': 'devotional_hub',
        'slug': 'rhema-for-living',
        'children': <dynamic>[
          <String, dynamic>{
            'engine_type': 'devotional_quiz',
            'visible': true,
          },
        ],
      },
    });
    expect(
      DevotionalHubConfig.resolve(enabled).quizCapabilityEnabled(enabled),
      isTrue,
    );
  });

  test('watch payload remains provider-neutral', () {
    for (final source in <Map<String, dynamic>>[
      <String, dynamic>{
        'source_type': 'hls',
        'provider': 'direct',
        'url': 'https://example.invalid/live.m3u8',
        'is_live': true,
      },
      <String, dynamic>{
        'source_type': 'playlist',
        'provider': 'youtube',
        'playlist_id': 'playlist-id',
      },
      <String, dynamic>{
        'source_type': 'uploaded',
        'provider': 'appshub_media',
        'media_asset_id': 'media-42',
      },
    ]) {
      final playback = DevotionalPlaybackSource.fromJson(source);
      expect(playback.hasSource, isTrue);
      expect(playback.sourceType, isNotEmpty);
      expect(playback.provider, isNotEmpty);
    }
  });

  test('offline fallback preserves Celebration identity and namespace', () {
    final config = DevotionalHubConfig.resolve(CelebrationBootstrap.bundled());
    expect(config.visible, isTrue);
    expect(config.destinations, isNotEmpty);
    expect(CelebrationConfig.appSlug, 'celebration-tv');
    expect(CelebrationConfig.cacheNamespace, startsWith('dxm.celebration-tv'));
    expect(CelebrationConfig.primaryRoyalBlue.toARGB32(), 0xFF0D47A1);
    expect(CelebrationConfig.secondaryGold.toARGB32(), 0xFFFFC107);
  });

  test('devotional production files contain no foreign ministry identity', () {
    final roots = <Directory>[
      Directory('lib/features/devotional'),
      Directory('lib/navigation'),
    ];
    final forbidden = RegExp(
      r'(Seeds of Destiny|Inside Dunamis|Dunamis TV|dxm\.dunamis|/sod)',
      caseSensitive: false,
    );

    for (final root in roots) {
      for (final file in root.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.dart')) continue;
        expect(forbidden.hasMatch(file.readAsStringSync()), isFalse,
            reason: file.path);
      }
    }
  });
}

CelebrationBootstrap _bootstrap(Map<String, dynamic> additions) {
  return CelebrationBootstrap.parse(<String, dynamic>{
    'app': <String, dynamic>{'slug': CelebrationConfig.appSlug},
    ...additions,
  });
}
