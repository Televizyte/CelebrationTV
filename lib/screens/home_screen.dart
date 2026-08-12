import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../features/appshub/bootstrap_store.dart';
import '../features/hub/renderer/hub_section_renderer.dart';
import '../services/admob_service.dart';
import '../services/remote_config_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RemoteConfigService _remoteConfig = RemoteConfigService();
  final List<NativeAd> _nativeAds = <NativeAd>[];
  final List<bool> _loaded = <bool>[];
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _prepareNativeAds();
    final banner = AdMobService.instance.createBanner();
    _banner = banner;
    banner?.load();
  }

  void _prepareNativeAds() {
    if (!_remoteConfig.enableNative) return;
    for (var index = 0; index < 6; index++) {
      _loaded.add(false);
      final adIndex = index;
      final ad = AdMobService.instance.createNative(
        onLoaded: () {
          if (mounted && adIndex < _loaded.length) {
            setState(() => _loaded[adIndex] = true);
          }
        },
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
    final store = CelebrationBootstrapScope.of(context);
    final sections = store.hub('home').sections;
    final children = <Widget>[];
    var adIndex = 0;
    for (var index = 0; index < sections.length; index++) {
      children.add(
        HubSectionRenderer(
            section: sections[index], onNavigate: widget.onNavigate),
      );
      children.add(const SizedBox(height: 22));
      final frequency = _remoteConfig.nativeFrequency;
      if (_remoteConfig.enableNative &&
          frequency > 0 &&
          (index + 1) % frequency == 0 &&
          adIndex < _nativeAds.length) {
        final current = adIndex++;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: SizedBox(
              height: 120,
              child: _loaded[current]
                  ? AdWidget(ad: _nativeAds[current])
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      }
    }

    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: sections.isEmpty
                ? _HomeEmptyState(refreshing: store.hubRefreshing('home'))
                : RefreshIndicator(
                    onRefresh: () => store.refreshHub('home'),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 14, bottom: 24),
                      children: children,
                    ),
                  ),
          ),
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

class _HomeEmptyState extends StatelessWidget {
  final bool refreshing;
  const _HomeEmptyState({required this.refreshing});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            refreshing
                ? 'Refreshing Celebration TV Home...'
                : 'Home content is not available offline yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
