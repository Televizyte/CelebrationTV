import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/remote_config_service.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RemoteConfigService();
    return ListView(
      children: [
        const ListTile(title: Text('Web Links', style: TextStyle(fontWeight: FontWeight.bold))),
        for (final w in rc.webLinks)
          ListTile(
            leading: const Icon(Icons.link),
            title: Text(w['title'] ?? 'Link'),
            onTap: () async {
              final uri = Uri.parse(w['url']);
              // open inside app: use WebView screen or in-app browser; here we fallback to launch in-app browser
              await launchUrl(uri, mode: LaunchMode.inAppWebView);
            },
          ),
        const Divider(),
        const ListTile(title: Text('About')),
        const ListTile(
          title: Text('Celebration TV'),
          subtitle: Text('Revealing Jesus. Releasing Destinies.'),
        )
      ],
    );
  }
}
