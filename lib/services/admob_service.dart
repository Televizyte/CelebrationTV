import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remote_config_service.dart';

class AdMobService {
  AdMobService._();
  static final instance = AdMobService._();

  static const String appId = "ca-app-pub-4171224553175356~5152707997";
  static const String bannerId = "ca-app-pub-4171224553175356/6326441096";
  static const String nativeId = "ca-app-pub-4171224553175356/7072926414";
  static const String interstitialId = "ca-app-pub-4171224553175356/6196881919";

  InterstitialAd? _interstitial;
  DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);
  bool _loadingInterstitial = false;

  void configure() {
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (_loadingInterstitial) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  void maybeShowInterstitial(BuildContext context, {String reason = 'nav'}) {
    if (!RemoteConfigService().enableInterstitial) return;
    final cooldown = Duration(seconds: RemoteConfigService().interstitialCooldownSec);
    final now = DateTime.now();
    if (_interstitial != null && now.difference(_lastShown) >= cooldown) {
      _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitial();
        },
      );
      _interstitial!.show();
      _lastShown = now;
    } else {
      if (_interstitial == null) _loadInterstitial();
    }
  }

  BannerAd? createBanner() {
    if (!RemoteConfigService().enableBanner) return null;
    return BannerAd(
      adUnitId: bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    );
  }

  NativeAd? createNative({required void Function() onLoaded, required void Function(LoadAdError) onFailed}) {
    if (!RemoteConfigService().enableNative) return null;
    return NativeAd(
      adUnitId: nativeId,
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          onFailed(err);
        },
      ),
      request: const AdRequest(),
    );
  }
}
