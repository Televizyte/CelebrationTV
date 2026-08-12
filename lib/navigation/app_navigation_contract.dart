import 'package:flutter/material.dart';

import '../features/appshub/bootstrap_models.dart';
import '../features/devotional/models/devotional_destination.dart';

enum CanonicalTab {
  home('home', '/', 'Home', Icons.home_outlined),
  watch('watch', '/watch', 'Watch', Icons.live_tv_outlined),
  inspire('inspire', '/inspire', 'Inspire', Icons.auto_awesome_outlined),
  explore('explore', '/explore', 'Explore', Icons.explore_outlined),
  more('more', '/more', 'More', Icons.more_horiz);

  final String engineKey;
  final String path;
  final String defaultLabel;
  final IconData icon;

  const CanonicalTab(
    this.engineKey,
    this.path,
    this.defaultLabel,
    this.icon,
  );

  static CanonicalTab? fromEngineKey(String value) {
    final normalized = value.trim().toLowerCase();
    for (final tab in values) {
      if (tab.engineKey == normalized) return tab;
    }
    return null;
  }

  static CanonicalTab? fromPath(String value) {
    final normalized = AppRouteContract.normalize(value);
    for (final tab in values) {
      if (tab.path == normalized) return tab;
    }
    return null;
  }
}

class AppTabContract {
  final CanonicalTab canonical;
  final String label;
  final int order;
  final bool visible;
  final Map<String, dynamic> metadata;

  const AppTabContract({
    required this.canonical,
    required this.label,
    required this.order,
    required this.visible,
    this.metadata = const <String, dynamic>{},
  });

  static List<AppTabContract> resolve(CelebrationBootstrap bootstrap) {
    final configured = <CanonicalTab, Map<String, dynamic>>{};
    for (final item in bootstrap.tabs) {
      final key = _text(
        item['engine_key'] ?? item['key'] ?? item['route_key'] ?? item['slug'],
      );
      final canonical = CanonicalTab.fromEngineKey(key);
      if (canonical != null) configured[canonical] = item;
    }

    final resolved = <AppTabContract>[];
    for (var index = 0; index < CanonicalTab.values.length; index++) {
      final canonical = CanonicalTab.values[index];
      final item = configured[canonical];
      resolved.add(AppTabContract(
        canonical: canonical,
        label: _text(item?['label'] ?? item?['title']).isEmpty
            ? canonical.defaultLabel
            : _text(item?['label'] ?? item?['title']),
        order: _integer(item?['order'] ?? item?['sort_order'], index),
        visible: _boolean(
          item?['visible'] ?? item?['is_visible'] ?? item?['enabled'],
          true,
        ),
        metadata: item ?? const <String, dynamic>{},
      ));
    }
    resolved.sort((left, right) {
      final order = left.order.compareTo(right.order);
      return order != 0
          ? order
          : left.canonical.index.compareTo(right.canonical.index);
    });
    return List<AppTabContract>.unmodifiable(resolved);
  }
}

abstract final class AppRouteContract {
  static const rootPaths = <String>{
    '/',
    '/watch',
    '/inspire',
    '/explore',
    '/more'
  };

  static const placeholderPaths = <String>{
    '/articles',
    '/articles/channel',
    '/articles/detail',
    '/short-videos',
    '/short-videos/library',
    '/quotes',
    '/quotes/library',
    '/tools',
    '/tools/bible',
    '/tools/notes',
    '/tools/quote-creator',
    '/books',
    '/books/detail',
    '/books/reader',
    '/quiz',
    '/games',
    '/games/dominion-match',
    '/games/race-of-faith',
    '/games/kingdom-builder',
    '/saved',
    '/downloads',
    '/notifications',
    '/account',
    '/support',
    '/about',
    '/legal',
    '/settings',
    '/share',
    '/rate',
  };

  static String normalize(String value) {
    final uri = Uri.tryParse(value);
    var path = uri?.path.trim() ?? '';
    if (path.isEmpty) return '/';
    if (!path.startsWith('/')) path = '/$path';
    if (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return path.toLowerCase();
  }

  static bool isKnown(String path) {
    final normalized = normalize(path);
    return rootPaths.contains(normalized) ||
        placeholderPaths.contains(normalized) ||
        devotionalRoute(normalized) != null ||
        watchRoute(normalized) != null;
  }

  static WatchRouteMatch? watchRoute(String path) {
    final normalized = normalize(path);
    final match = RegExp(
      r'^/watch/(channels|playlists|videos|live)/([a-z0-9]+(?:-[a-z0-9]+)*)$',
    ).firstMatch(normalized);
    if (match == null) return null;
    return WatchRouteMatch(collection: match.group(1)!, slug: match.group(2)!);
  }

  static DevotionalRouteMatch? devotionalRoute(String path) {
    final normalized = normalize(path);
    final match = RegExp(
      r'^/devotionals/([a-z0-9]+(?:-[a-z0-9]+)*)(?:/(read|watch|quotes|quiz))?$',
    ).firstMatch(normalized);
    if (match == null) return null;
    final suffix = match.group(2);
    final type = switch (suffix) {
      'read' => DevotionalEngineType.read,
      'watch' => DevotionalEngineType.watch,
      'quotes' => DevotionalEngineType.quotes,
      'quiz' => DevotionalEngineType.quiz,
      _ => null,
    };
    return DevotionalRouteMatch(slug: match.group(1)!, destinationType: type);
  }

  static CanonicalTab ownerOf(String path) {
    final normalized = normalize(path);
    final root = CanonicalTab.fromPath(normalized);
    if (root != null) return root;
    if (normalized.startsWith('/watch/')) return CanonicalTab.watch;
    if (normalized.startsWith('/articles') ||
        normalized.startsWith('/short-videos') ||
        normalized.startsWith('/quotes') ||
        normalized.startsWith('/devotionals')) {
      return CanonicalTab.inspire;
    }
    if (normalized.startsWith('/tools') ||
        normalized.startsWith('/books') ||
        normalized.startsWith('/quiz') ||
        normalized.startsWith('/games')) {
      return CanonicalTab.explore;
    }
    return CanonicalTab.more;
  }
}

class WatchRouteMatch {
  final String collection;
  final String slug;

  const WatchRouteMatch({required this.collection, required this.slug});
}

class DevotionalRouteMatch {
  final String slug;
  final DevotionalEngineType? destinationType;

  const DevotionalRouteMatch({
    required this.slug,
    required this.destinationType,
  });
}

String _text(dynamic value) => value?.toString().trim() ?? '';

int _integer(dynamic value, int fallback) {
  if (value is int) return value;
  return int.tryParse(_text(value)) ?? fallback;
}

bool _boolean(dynamic value, bool fallback) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = _text(value).toLowerCase();
  if (<String>{'true', '1', 'yes', 'enabled'}.contains(normalized)) return true;
  if (<String>{'false', '0', 'no', 'disabled'}.contains(normalized))
    return false;
  return fallback;
}
