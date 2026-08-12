import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../features/appshub/bootstrap_store.dart';
import '../features/hub/renderer/hub_section_renderer.dart';
import '../services/admob_service.dart';

class LiveScreen extends StatefulWidget {
  final ValueChanged<String> onNavigate;

  const LiveScreen({super.key, required this.onNavigate});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _banner = AdMobService.instance.createBanner();
    _banner?.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = CelebrationBootstrapScope.of(context);
    final sections = store.hub('watch').sections;
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: sections.isEmpty
                ? _WatchEmptyState(refreshing: store.hubRefreshing('watch'))
                : RefreshIndicator(
                    onRefresh: () => store.refreshHub('watch'),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 14, bottom: 24),
                      itemCount: sections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 22),
                      itemBuilder: (_, index) => HubSectionRenderer(
                        section: sections[index],
                        onNavigate: widget.onNavigate,
                      ),
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

class _WatchEmptyState extends StatelessWidget {
  final bool refreshing;
  const _WatchEmptyState({required this.refreshing});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            refreshing
                ? 'Refreshing Watch discovery...'
                : 'Watch channels are not available offline yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
}
