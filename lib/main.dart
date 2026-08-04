import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'config/celebration_config.dart';
import 'features/appshub/appshub_client.dart';
import 'features/appshub/bootstrap_store.dart';
import 'navigation/celebration_router.dart';
import 'services/remote_config_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Preload remote config
  await RemoteConfigService().init();

  final bootstrapStore = CelebrationBootstrapStore(
    client: AppsHubClient(
      baseUrl: CelebrationConfig.appsHubBaseUrl,
      appSlug: CelebrationConfig.appSlug,
      appToken: CelebrationConfig.appToken,
    ),
  );
  await bootstrapStore.loadCached();

  runApp(CelebrationTvApp(bootstrapStore: bootstrapStore));
  unawaited(bootstrapStore.refresh());
}

class CelebrationTvApp extends StatefulWidget {
  final CelebrationBootstrapStore bootstrapStore;

  const CelebrationTvApp({super.key, required this.bootstrapStore});

  @override
  State<CelebrationTvApp> createState() => _CelebrationTvAppState();
}

class _CelebrationTvAppState extends State<CelebrationTvApp> {
  late final CelebrationRouterDelegate _routerDelegate;
  static const _routeInformationParser = CelebrationRouteInformationParser();

  @override
  void initState() {
    super.initState();
    _routerDelegate = CelebrationRouterDelegate(
      bootstrapStore: widget.bootstrapStore,
    );
    _initMessaging();
  }

  Future<void> _initMessaging() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.subscribeToTopic(
      CelebrationConfig.notificationTopicNamespace,
    );
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    widget.bootstrapStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: CelebrationConfig.secondaryGold,
        secondary: CelebrationConfig.primaryRoyalBlue,
      ),
      useMaterial3: true,
    );

    return CelebrationBootstrapScope(
      store: widget.bootstrapStore,
      child: MaterialApp.router(
        title: CelebrationConfig.appName,
        theme: theme,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
      ),
    );
  }
}
