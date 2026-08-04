import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/remote_config_service.dart';
import '../services/admob_service.dart';
import 'videos_screen.dart';
import 'live_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final rc = RemoteConfigService();
  final List<NativeAd> _nativeAds = [];
  final List<bool> _loaded = [];
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _prepareNativeAds();
    _banner = AdMobService.instance.createBanner()..load();
  }

  void _prepareNativeAds() {
    if (!rc.enableNative) return;
    // Preload several native ads for insertion after every N items.
    for (int i = 0; i < 6; i++) {
      _loaded.add(false);
      final ad = AdMobService.instance.createNative(
        onLoaded: () => setState(() => _loaded[i] = true),
        onFailed: (_) {},
      );
      if (ad != null) {
        _nativeAds.add(ad);
        ad.load();
      }
    }
  }

  @override
  void dispose() {
    for (final ad in _nativeAds) {
      ad.dispose();
    }
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlists = rc.playlists;
    final nFreq = rc.nativeFrequency; // 3 from Remote Config

    // Build list items + insert native ad after every nFreq items.
    final tiles = <Widget>[];
    int nativeIndex = 0;

    for (int i = 0; i < playlists.length; i++) {
      final p = playlists[i];
      tiles.add(
        ListTile(
          leading: const Icon(Icons.playlist_play),
          title: Text(p['title'] ?? 'Playlist'),
          onTap: () {
            AdMobService.instance.maybeShowInterstitial(context, reason: 'open_playlist');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideosScreen(initialUrl: p['ytPlaylistUrl']),
              ),
            );
          },
        ),
      );

      final shouldInsertNative = rc.enableNative && nFreq > 0 && ((i + 1) % nFreq == 0);
      if (shouldInsertNative && nativeIndex < _nativeAds.length) {
        final idx = nativeIndex++; // pick next preloaded ad
        tiles.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 120,
              child: _loaded[idx]
                  ? AdWidget(ad: _nativeAds[idx])
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }
    }

    return SafeArea(
      child: Column(
        children: [
          ListTile(
            title: Text(
              rc.heroTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Don’t show interstitial when going to Live (video content).
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveScreen()),
                );
              },
              child: const Text('Watch Live'),
            ),
          ),
          const Divider(),
          Expanded(child: ListView(children: tiles)),
          if (_banner != null)
            SizedBox(
              height: _banner!.size.height.toDouble(),
              width: _banner!.size.width.toDouble(),
              child: AdWidget(ad: _banner!),
            ),
        ],
      ),
    );
  }
}
