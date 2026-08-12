import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/celebration_config.dart';
import 'appshub_client.dart';
import 'bootstrap_models.dart';
import '../hub/models/hub_models.dart';

abstract interface class BootstrapCache {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SharedPreferencesBootstrapCache implements BootstrapCache {
  @override
  Future<String?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }
}

class CelebrationBootstrapStore extends ChangeNotifier {
  final AppsHubClient client;
  final BootstrapCache cache;
  final DateTime Function() _now;

  CelebrationBootstrap _bootstrap = CelebrationBootstrap.bundled();
  DateTime? _retrievedAt;
  bool _refreshing = false;
  String? _lastError;
  final Map<String, HubPayload> _hubs = <String, HubPayload>{};
  final Set<String> _refreshingHubs = <String>{};
  final Map<String, String> _hubErrors = <String, String>{};

  CelebrationBootstrapStore({
    required this.client,
    BootstrapCache? cache,
    DateTime Function()? now,
  })  : cache = cache ?? SharedPreferencesBootstrapCache(),
        _now = now ?? DateTime.now;

  CelebrationBootstrap get bootstrap => _bootstrap;
  DateTime? get retrievedAt => _retrievedAt;
  bool get refreshing => _refreshing;
  String? get lastError => _lastError;
  HubPayload hub(String tab) =>
      _hubs[tab.trim().toLowerCase()] ?? HubPayload.bundled(tab);
  bool hubRefreshing(String tab) =>
      _refreshingHubs.contains(tab.trim().toLowerCase());
  String? hubError(String tab) => _hubErrors[tab.trim().toLowerCase()];

  Future<void> loadCachedHub(String tab) async {
    final key = tab.trim().toLowerCase();
    if (!_supportedHubTab(key)) return;
    try {
      final encoded = await cache.read(CelebrationConfig.hubCacheKey(key));
      if (encoded == null || encoded.trim().isEmpty) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return;
      final envelope = Map<String, dynamic>.from(decoded);
      if (envelope['app_slug'] != CelebrationConfig.appSlug ||
          envelope['tab'] != key) return;
      final payload = envelope['payload'];
      if (payload is! Map) return;
      _hubs[key] = HubPayload.parse(
        Map<String, dynamic>.from(payload),
        expectedTab: key,
      );
      notifyListeners();
    } catch (_) {
      // Existing valid memory or bundled fallback remains authoritative.
    }
  }

  Future<bool> refreshHub(String tab) async {
    final key = tab.trim().toLowerCase();
    if (!_supportedHubTab(key) || _refreshingHubs.contains(key)) return false;
    _refreshingHubs.add(key);
    _hubErrors.remove(key);
    notifyListeners();
    try {
      final parsed = HubPayload.parse(
        await client.fetchHub(key),
        expectedTab: key,
      );
      await cache.write(
        CelebrationConfig.hubCacheKey(key),
        jsonEncode(<String, dynamic>{
          'app_slug': CelebrationConfig.appSlug,
          'tab': key,
          'retrieved_at': _now().toUtc().toIso8601String(),
          'payload': parsed.toJson(),
        }),
      );
      _hubs[key] = parsed;
      return true;
    } catch (error) {
      _hubErrors[key] = error is AppsHubClientException
          ? error.message
          : 'AppsHub $key content was not updated.';
      return false;
    } finally {
      _refreshingHubs.remove(key);
      notifyListeners();
    }
  }

  Future<void> loadCached() async {
    try {
      final encoded = await cache.read(CelebrationConfig.bootstrapCacheKey);
      if (encoded == null || encoded.trim().isEmpty) return;
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return;
      final envelope = Map<String, dynamic>.from(decoded);
      if (envelope['app_slug'] != CelebrationConfig.appSlug) return;
      final payload = envelope['payload'];
      if (payload is! Map) return;

      _bootstrap =
          CelebrationBootstrap.parse(Map<String, dynamic>.from(payload));
      _retrievedAt = DateTime.tryParse(
        envelope['retrieved_at']?.toString() ?? '',
      );
      notifyListeners();
    } catch (_) {
      // Bundled identity remains authoritative when cache is unreadable.
    }
  }

  Future<bool> refresh() async {
    if (_refreshing) return false;
    _refreshing = true;
    _lastError = null;
    notifyListeners();

    try {
      final parsed = CelebrationBootstrap.parse(await client.fetchBootstrap());
      final retrievedAt = _now().toUtc();
      await cache.write(
        CelebrationConfig.bootstrapCacheKey,
        jsonEncode(<String, dynamic>{
          'app_slug': CelebrationConfig.appSlug,
          'retrieved_at': retrievedAt.toIso8601String(),
          'payload': parsed.toJson(),
        }),
      );
      _bootstrap = parsed;
      _retrievedAt = retrievedAt;
      return true;
    } catch (error) {
      _lastError = error is AppsHubClientException
          ? error.message
          : 'AppsHub configuration was not updated.';
      return false;
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}

bool _supportedHubTab(String tab) =>
    const <String>{'home', 'watch', 'inspire', 'explore', 'more'}.contains(tab);

class CelebrationBootstrapScope
    extends InheritedNotifier<CelebrationBootstrapStore> {
  const CelebrationBootstrapScope({
    super.key,
    required CelebrationBootstrapStore store,
    required super.child,
  }) : super(notifier: store);

  static CelebrationBootstrapStore of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<CelebrationBootstrapScope>();
    assert(scope != null, 'CelebrationBootstrapScope was not found.');
    return scope!.notifier!;
  }
}
