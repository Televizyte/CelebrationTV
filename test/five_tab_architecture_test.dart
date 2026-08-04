import 'package:celebration_tv/config/celebration_config.dart';
import 'package:celebration_tv/features/appshub/bootstrap_models.dart';
import 'package:celebration_tv/features/articles/article_channel.dart';
import 'package:celebration_tv/navigation/app_navigation_contract.dart';
import 'package:celebration_tv/navigation/celebration_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines exactly five canonical engine tabs', () {
    expect(CanonicalTab.values, hasLength(5));
    expect(
      CanonicalTab.values.map((tab) => tab.engineKey),
      orderedEquals(<String>['home', 'watch', 'inspire', 'explore', 'more']),
    );
    expect(
      CanonicalTab.values.map((tab) => tab.defaultLabel),
      orderedEquals(<String>['Home', 'Watch', 'Inspire', 'Explore', 'More']),
    );
  });

  test('offline navigation retains all canonical tabs', () {
    final tabs = AppTabContract.resolve(CelebrationBootstrap.bundled());
    expect(tabs, hasLength(5));
    expect(tabs.every((tab) => tab.visible), isTrue);
    expect(
        tabs.map((tab) => tab.canonical).toSet(), CanonicalTab.values.toSet());
  });

  test('AppsHub can configure labels, visibility, and order', () {
    final bootstrap = CelebrationBootstrap.parse(<String, dynamic>{
      'app': <String, dynamic>{'slug': CelebrationConfig.appSlug},
      'tabs': <dynamic>[
        <String, dynamic>{
          'engine_key': 'explore',
          'label': 'Discover',
          'order': -1,
        },
        <String, dynamic>{
          'engine_key': 'home',
          'label': 'Welcome',
          'order': 2,
        },
        <String, dynamic>{
          'engine_key': 'more',
          'visible': false,
          'order': 9,
        },
        <String, dynamic>{'engine_key': 'unknown-engine', 'order': 0},
      ],
    });
    final tabs = AppTabContract.resolve(bootstrap);

    expect(tabs, hasLength(5));
    expect(tabs.first.canonical, CanonicalTab.explore);
    expect(tabs.first.label, 'Discover');
    expect(
      tabs.singleWhere((tab) => tab.canonical == CanonicalTab.home).label,
      'Welcome',
    );
    expect(
      tabs.singleWhere((tab) => tab.canonical == CanonicalTab.more).visible,
      isFalse,
    );
  });

  test('known routes are isolated to Celebration engine destinations', () {
    final routes = <String>{
      ...AppRouteContract.rootPaths,
      ...AppRouteContract.placeholderPaths,
    };
    expect(routes.every(AppRouteContract.isKnown), isTrue);
    expect(routes.any((route) => route.toLowerCase().contains('dunamis')),
        isFalse);
    expect(
        routes.any((route) => route.toLowerCase().contains('/sod')), isFalse);
    expect(AppRouteContract.isKnown('/inside-dunamis'), isFalse);
  });

  test('unknown routes normalize and resolve to the safe unknown page', () {
    const parser = CelebrationRouteInformationParser();
    expect(
        AppRouteContract.normalize('/Future/Unknown/?a=1'), '/future/unknown');
    expect(AppRouteContract.isKnown('/future/unknown'), isFalse);
    expect(parser, isA<RouteInformationParser<CelebrationRoutePath>>());
  });

  test('theme and namespace identity stay exact', () {
    expect(CelebrationConfig.primaryRoyalBlue.toARGB32(), 0xFF0D47A1);
    expect(CelebrationConfig.secondaryGold.toARGB32(), 0xFFFFC107);
    expect(CelebrationConfig.cacheNamespace, 'dxm.celebration-tv');
    expect(CelebrationConfig.notificationTopicNamespace, 'celebration_tv');
  });

  test('article channels preserve dynamic placement and metadata', () {
    final channel = ArticleChannel.fromJson(<String, dynamic>{
      'slug': 'future-channel',
      'title': 'Future Channel',
      'description': 'Backend-provided editorial channel',
      'route_key': 'articles.future-channel',
      'tab_placement': 'inspire',
      'section_placement': 'after-featured',
      'icon': 'auto_stories',
      'artwork_url': 'assets/channel.webp',
      'layout_type': 'editorial_grid',
      'sort_order': 20,
      'is_visible': true,
      'is_featured': true,
      'notification_settings': <String, dynamic>{'enabled': true},
      'content_filters': <String, dynamic>{'type': 'article'},
      'settings': <String, dynamic>{'columns': 2},
      'future_field': 'preserved',
    });

    expect(channel.slug, 'future-channel');
    expect(channel.tabPlacement, 'inspire');
    expect(channel.layoutType, 'editorial_grid');
    expect(channel.notificationSettings['enabled'], isTrue);
    expect(channel.contentFilters['type'], 'article');
    expect(channel.settings['columns'], 2);
    expect(channel.unknownFields['future_field'], 'preserved');

    final catalog = ArticleChannel.listFromPayload(<String, dynamic>{
      'article_channels': <dynamic>[
        <String, dynamic>{'slug': 'second', 'title': 'Second', 'order': 2},
        <String, dynamic>{'slug': 'first', 'title': 'First', 'order': 1},
        <String, dynamic>{'slug': '', 'title': 'Invalid'},
      ],
    });
    expect(catalog.map((item) => item.slug),
        orderedEquals(<String>['first', 'second']));
  });
}
