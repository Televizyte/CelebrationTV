import 'dart:io';

import 'package:celebration_tv/config/celebration_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled Celebration identity and branding paths remain exact', () {
    expect(CelebrationConfig.appName, 'Celebration TV');
    expect(CelebrationConfig.shortName, 'CTV');
    expect(CelebrationConfig.appSlug, 'celebration-tv');
    expect(
      CelebrationConfig.androidPackageId,
      'com.digitxtramedia.celebrationtv',
    );
    expect(CelebrationConfig.primaryRoyalBlue.toARGB32(), 0xFF0D47A1);
    expect(CelebrationConfig.secondaryGold.toARGB32(), 0xFFFFC107);
    expect(
      CelebrationConfig.tagline,
      'Revealing Jesus. Releasing Destinies',
    );
    expect(
      CelebrationConfig.logoAssetPath,
      'assets/branding/celebration_tv_logo.png',
    );
    expect(
      CelebrationConfig.splashAssetPath,
      'assets/branding/celebration_tv_splash.jpg',
    );
  });

  test('runtime branding uses declared derivatives instead of root sources',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/branding/'));
    expect(File(CelebrationConfig.logoAssetPath).existsSync(), isTrue);
    expect(File(CelebrationConfig.splashAssetPath).existsSync(), isTrue);
    expect(CelebrationConfig.logoAssetPath, isNot('Celebrationtv_logo.png'));
    expect(
      CelebrationConfig.splashAssetPath,
      isNot('Celebration TV Splash Screen.jpg'),
    );
  });

  test('Android launcher and splash references resolve to Celebration assets',
      () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final launchBackground = File(
      'android/app/src/main/res/drawable/launch_background.xml',
    ).readAsStringSync();
    final android12Theme = File(
      'android/app/src/main/res/values-v31/styles.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains('package="com.digitxtramedia.celebrationtv"'),
    );
    expect(manifest, contains('android:label="Celebration TV"'));
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:theme="@style/LaunchTheme"'));
    expect(
      launchBackground,
      contains('@drawable/celebration_tv_splash'),
    );
    expect(android12Theme, contains('@mipmap/ic_launcher'));

    for (final density in <String>[
      'mipmap-mdpi',
      'mipmap-hdpi',
      'mipmap-xhdpi',
      'mipmap-xxhdpi',
      'mipmap-xxxhdpi',
    ]) {
      expect(
        File('android/app/src/main/res/$density/ic_launcher.png').existsSync(),
        isTrue,
      );
    }

    final resourcePaths = Directory('android/app/src/main/res')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path.toLowerCase())
        .join('\n');
    expect(resourcePaths, isNot(contains('dunamis')));
    expect(resourcePaths, isNot(contains('sod')));
  });

  test('production branding configuration contains no foreign identity', () {
    final sources = <String>[
      File('lib/config/celebration_config.dart').readAsStringSync(),
      File('lib/main.dart').readAsStringSync(),
      File('pubspec.yaml').readAsStringSync(),
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
    ].join('\n').toLowerCase();

    expect(sources, isNot(contains('dunamis')));
    expect(sources, isNot(contains('seeds of destiny')));
    expect(sources, isNot(contains('inside dunamis')));
    expect(sources, isNot(contains('dunamis_tv')));
  });
}
