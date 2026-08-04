import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/remote_config_service.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
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
    final primary = rc.livePrimary;
    final fallback = rc.liveFallbacks.isNotEmpty ? rc.liveFallbacks.first : "https://youtube.com";
    final url = primary.isNotEmpty ? primary : fallback;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Live')),
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
