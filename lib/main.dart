import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/live_screen.dart';
import 'screens/videos_screen.dart';
import 'screens/inspire_screen.dart';
import 'screens/more_screen.dart';
import 'services/admob_service.dart';
import 'services/remote_config_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Preload remote config
  await RemoteConfigService().init();

  runApp(const CelebrationTvApp());
}

class CelebrationTvApp extends StatefulWidget {
  const CelebrationTvApp({super.key});

  @override
  State<CelebrationTvApp> createState() => _CelebrationTvAppState();
}

class _CelebrationTvAppState extends State<CelebrationTvApp> {
  int _index = 0;
  final _pages = const [
    HomeScreen(),
    LiveScreen(),
    VideosScreen(),
    InspireScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdMobService.instance.configure();
    _initMessaging();
  }

  Future<void> _initMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.subscribeToTopic('general');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFC107), // gold accent
        secondary: Color(0xFF0D47A1), // deep blue
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Celebration TV',
      theme: theme,
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            final now = DateTime.now();
            final blockInterstitial = _pages[_index] is LiveScreen || _pages[i] is LiveScreen;
            if (!blockInterstitial) {
              AdMobService.instance.maybeShowInterstitial(context, reason: 'nav_tab');
            }
            setState(() => _index = i);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.live_tv), label: 'Live'),
            NavigationDestination(icon: Icon(Icons.playlist_play), label: 'Videos'),
            NavigationDestination(icon: Icon(Icons.bolt), label: 'Inspire'),
            NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
          ],
        ),
      ),
    );
  }
}
