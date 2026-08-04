import 'dart:convert';

import 'package:celebration_tv/config/celebration_config.dart';
import 'package:celebration_tv/features/appshub/appshub_client.dart';
import 'package:celebration_tv/features/appshub/bootstrap_models.dart';
import 'package:celebration_tv/features/appshub/bootstrap_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('identity, endpoints, cache key, and colors remain exact', () {
    final client = AppsHubClient(
      baseUrl: CelebrationConfig.appsHubBaseUrl,
      appSlug: CelebrationConfig.appSlug,
    );
    expect(CelebrationConfig.appSlug, 'celebration-tv');
    expect(client.bootstrapUri.toString(),
        'https://admin.appshub.digitxtramedia.com/api/v1/apps/celebration-tv/bootstrap');
    expect(client.hubUri('home').toString(),
        'https://admin.appshub.digitxtramedia.com/api/v1/apps/celebration-tv/hub?tab=home');
    expect(CelebrationConfig.bootstrapCacheKey,
        'dxm.celebration-tv.hub.bootstrap.cache.v1');
    expect(CelebrationConfig.primaryRoyalBlue.toARGB32(), 0xFF0D47A1);
    expect(CelebrationConfig.secondaryGold.toARGB32(), 0xFFFFC107);
    client.close();
  });

  test('parses direct-root payload with missing optional fields', () {
    final parsed = CelebrationBootstrap.parse(<String, dynamic>{
      'app': <String, dynamic>{'slug': 'celebration-tv'},
      'future_contract': <String, dynamic>{'version': 2},
    });
    expect(parsed.identity.name, CelebrationConfig.appName);
    expect(parsed.tabs, isEmpty);
    expect(parsed.unknownFields, contains('future_contract'));
  });

  test('parses data-wrapped payload', () {
    final parsed = CelebrationBootstrap.parse(<String, dynamic>{
      'data': <String, dynamic>{
        'app': <String, dynamic>{'slug': 'celebration-tv'},
        'capabilities': <String, dynamic>{'watch': true},
      },
    });
    expect(parsed.identity.slug, CelebrationConfig.appSlug);
    expect(parsed.capabilities['watch'], isTrue);
  });

  test('accepts complete Celebration identity and neutral dynamic content', () {
    final parsed = CelebrationBootstrap.parse(<String, dynamic>{
      'app': <String, dynamic>{
        'slug': CelebrationConfig.appSlug,
        'name': CelebrationConfig.appName,
        'short_name': CelebrationConfig.shortName,
        'package_id': CelebrationConfig.androidPackageId,
      },
      'article_channels': <dynamic>[
        <String, dynamic>{'title': 'Future Ministry Channel'},
        <String, dynamic>{'title': 'Rhema For Living'},
        <String, dynamic>{'title': 'Wonders Without Numbers'},
      ],
    });

    expect(parsed.identity.slug, CelebrationConfig.appSlug);
    expect(parsed.identity.packageId, CelebrationConfig.androidPackageId);
    expect(parsed.unknownFields, contains('article_channels'));
  });

  test('rejects malformed and explicit foreign identity', () {
    final invalid = <Map<String, dynamic>>[
      <String, dynamic>{},
      <String, dynamic>{
        'app': <String, dynamic>{'slug': 'another-app'}
      },
      <String, dynamic>{
        'app': <String, dynamic>{
          'slug': 'celebration-tv',
          'package_id': 'com.example.foreign',
        },
      },
      <String, dynamic>{
        'app': <String, dynamic>{'slug': 'celebration-tv'},
        'app_slug': 'another-app',
      },
      <String, dynamic>{
        'data': <String, dynamic>{
          'app': <String, dynamic>{
            'slug': 'celebration-tv',
            'name': 'Dunamis TV',
          },
        },
      },
      <String, dynamic>{
        'app': <String, dynamic>{'slug': 'celebration-tv'},
        'routes': <dynamic>[
          <String, dynamic>{'path': '/sod'}
        ],
      },
    ];
    for (final payload in invalid) {
      expect(() => CelebrationBootstrap.parse(payload),
          throwsA(isA<BootstrapFormatException>()));
    }
  });

  test('bundled identity is available offline without foreign fallbacks', () {
    final encoded =
        jsonEncode(CelebrationBootstrap.bundled().toJson()).toLowerCase();
    expect(encoded, contains('celebration-tv'));
    expect(encoded, isNot(contains('dunamis')));
    expect(encoded, isNot(contains('/sod')));
  });

  test('valid cache is preserved after malformed refresh', () async {
    final cache = _MemoryCache();
    final cached = CelebrationBootstrap.parse(<String, dynamic>{
      'app': <String, dynamic>{
        'slug': 'celebration-tv',
        'name': 'Cached Celebration TV',
      },
    });
    await cache.write(
        CelebrationConfig.bootstrapCacheKey,
        jsonEncode(<String, dynamic>{
          'app_slug': CelebrationConfig.appSlug,
          'retrieved_at': '2026-08-04T08:00:00.000Z',
          'payload': cached.toJson(),
        }));
    final store = CelebrationBootstrapStore(
      client: AppsHubClient(
        baseUrl: CelebrationConfig.appsHubBaseUrl,
        appSlug: CelebrationConfig.appSlug,
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      ),
      cache: cache,
    );
    await store.loadCached();
    expect(store.bootstrap.identity.name, 'Cached Celebration TV');
    expect(await store.refresh(), isFalse);
    expect(store.bootstrap.identity.name, 'Cached Celebration TV');
    store.dispose();
  });

  test('cache belonging to another slug is rejected', () async {
    final cache = _MemoryCache();
    await cache.write(
        CelebrationConfig.bootstrapCacheKey,
        jsonEncode(<String, dynamic>{
          'app_slug': 'another-app',
          'payload': <String, dynamic>{
            'app': <String, dynamic>{
              'slug': 'celebration-tv',
              'name': 'Wrong cache'
            },
          },
        }));
    final store = CelebrationBootstrapStore(
      client: AppsHubClient(
        baseUrl: CelebrationConfig.appsHubBaseUrl,
        appSlug: CelebrationConfig.appSlug,
        httpClient: MockClient((_) async => http.Response('{}', 500)),
      ),
      cache: cache,
    );
    await store.loadCached();
    expect(store.bootstrap.identity.name, CelebrationConfig.appName);
    store.dispose();
  });
}

class _MemoryCache implements BootstrapCache {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
