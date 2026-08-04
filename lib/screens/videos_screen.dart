import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/remote_config_service.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class VideosScreen extends StatefulWidget {
  final String? initialUrl;
  const VideosScreen({super.key, this.initialUrl});
  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final rc = RemoteConfigService();
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
    final url = widget.initialUrl ??
        (rc.playlists.isNotEmpty ? rc.playlists.first['ytPlaylistUrl'] : "https://youtube.com");
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Videos')),
        body: Column(
          children: [
            Expanded(child: WebViewWidget(controller: controller)),
            if (_banner != null)
              SizedBox(
                height: _banner!.size.height.toDouble(),
                width: _banner!.size.width.toDouble(),
                child: AdWidget(ad: _banner!),
              ),
          ],
        ),
      ),
    );
  }
}
