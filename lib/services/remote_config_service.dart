import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final RemoteConfigService _i = RemoteConfigService._();
  RemoteConfigService._();
  factory RemoteConfigService() => _i;

  late FirebaseRemoteConfig rc;

  Future<void> init() async {
    rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 5),
    ));
    await rc.fetchAndActivate();
  }

  String get heroImage => _mapPath(['hero','image']);
  String get heroTitle => _mapPath(['hero','title'], fallback: 'You are WELCOME — ENJOY');
  String get livePrimary => _mapPath(['live','primaryUrl']);
  List<String> get liveFallbacks => _listPath(['live','fallbacks']);
  List<Map<String, dynamic>> get playlists => _listObj(['playlists']);
  List<Map<String, dynamic>> get webLinks => _listObj(['webLinks']);

  bool get enableBanner => _mapPathBool(['ads','enableBanner'], true);
  bool get enableNative => _mapPathBool(['ads','enableNative'], true);
  bool get enableInterstitial => _mapPathBool(['ads','enableInterstitial'], true);
  int get interstitialCooldownSec => int.tryParse(_mapPath(['ads','interstitialCooldownSec'], fallback: '30')) ?? 30;
  int get nativeFrequency => int.tryParse(_mapPath(['ads','nativeFrequency'], fallback: '4')) ?? 4;

  String _mapPath(List<String> path, {String fallback = ''}) {
    try {
      final data = json.decode(rc.getString('app_config'));
      dynamic cur = data;
      for (final k in path) {
        cur = cur[k];
      }
      return (cur ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  bool _mapPathBool(List<String> path, bool fallback) {
    final s = _mapPath(path, fallback: fallback.toString());
    return s == 'true';
    }

  List<String> _listPath(List<String> path) {
    try {
      final data = json.decode(rc.getString('app_config'));
      dynamic cur = data;
      for (final k in path) {
        cur = cur[k];
      }
      return (cur as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _listObj(List<String> path) {
    try {
      final data = json.decode(rc.getString('app_config'));
      dynamic cur = data;
      for (final k in path) {
        cur = cur[k];
      }
      return (cur as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
