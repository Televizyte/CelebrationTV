import 'package:flutter/material.dart';

/// Immutable identity and backend coordinates for the Celebration TV host.
abstract final class CelebrationConfig {
  static const appName = 'Celebration TV';
  static const shortName = 'CTV';
  static const appSlug = 'celebration-tv';
  static const androidPackageId = 'com.digitxtramedia.celebrationtv';
  static const appsHubBaseUrl = 'https://admin.appshub.digitxtramedia.com';

  // No application token is committed to source. Supply it through an
  // approved release-time configuration mechanism when one is available.
  static const appToken = String.fromEnvironment('CELEBRATION_APPSHUB_TOKEN');

  static const primaryRoyalBlue = Color(0xFF0D47A1);
  static const secondaryGold = Color(0xFFFFC107);
  static const tagline = 'Revealing Jesus. Releasing Destinies';
  static const logoAssetPath = 'assets/branding/celebration_tv_logo.png';
  static const splashAssetPath = 'assets/branding/celebration_tv_splash.jpg';

  static const cacheNamespace = 'dxm.$appSlug';
  static const bootstrapCacheKey = '$cacheNamespace.hub.bootstrap.cache.v1';
  static const notificationTopicNamespace = 'celebration_tv';

  static const bundledIdentity = <String, dynamic>{
    'app': <String, dynamic>{
      'name': appName,
      'short_name': shortName,
      'slug': appSlug,
      'package_id': androidPackageId,
    },
    'branding': <String, dynamic>{
      'primary_color': '#0D47A1',
      'secondary_color': '#FFC107',
      'tagline': tagline,
      'logo_asset': logoAssetPath,
      'splash_asset': splashAssetPath,
    },
    'capabilities': <String, dynamic>{},
    'feature_flags': <String, dynamic>{},
    'tabs': <dynamic>[],
    'routes': <dynamic>[],
    'sections': <dynamic>[],
    'ads': <String, dynamic>{},
  };
}
