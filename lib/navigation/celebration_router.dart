import 'package:flutter/material.dart';

import '../features/appshub/bootstrap_store.dart';
import '../features/devotional/models/devotional_destination.dart';
import '../features/devotional/models/devotional_hub_config.dart';
import '../features/devotional/screens/devotional_hub_screen.dart';
import '../features/devotional/screens/devotional_quiz_screen.dart';
import '../features/devotional/screens/devotional_quotes_screen.dart';
import '../features/devotional/screens/devotional_read_screen.dart';
import '../features/devotional/screens/devotional_watch_screen.dart';
import '../screens/home_screen.dart';
import '../screens/inspire_screen.dart';
import '../screens/live_screen.dart';
import '../screens/more_screen.dart';
import 'app_navigation_contract.dart';

class CelebrationRoutePath {
  final String location;
  const CelebrationRoutePath(this.location);
}

class CelebrationRouteInformationParser
    extends RouteInformationParser<CelebrationRoutePath> {
  const CelebrationRouteInformationParser();

  @override
  Future<CelebrationRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return CelebrationRoutePath(
      AppRouteContract.normalize(routeInformation.uri.toString()),
    );
  }

  @override
  RouteInformation restoreRouteInformation(CelebrationRoutePath configuration) {
    return RouteInformation(uri: Uri.parse(configuration.location));
  }
}

class CelebrationRouterDelegate extends RouterDelegate<CelebrationRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<CelebrationRoutePath> {
  final CelebrationBootstrapStore bootstrapStore;
  String _location = '/';

  CelebrationRouterDelegate({required this.bootstrapStore}) {
    bootstrapStore.addListener(_onBootstrapChanged);
  }

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  CelebrationRoutePath get currentConfiguration =>
      CelebrationRoutePath(_location);

  void navigate(String location) {
    final normalized = AppRouteContract.normalize(location);
    if (_location == normalized) return;
    _location = normalized;
    notifyListeners();
  }

  void selectTab(CanonicalTab tab) => navigate(tab.path);

  @override
  Future<void> setNewRoutePath(CelebrationRoutePath configuration) async {
    _location = AppRouteContract.normalize(configuration.location);
  }

  @override
  Widget build(BuildContext context) {
    final known = AppRouteContract.isKnown(_location);
    final owner = known
        ? AppRouteContract.ownerOf(_location)
        : CanonicalTab.fromPath(_location) ?? CanonicalTab.home;
    final isRoot = AppRouteContract.rootPaths.contains(_location);

    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        MaterialPage<void>(
          key: const ValueKey<String>('celebration-shell'),
          child: CelebrationShell(
            selectedTab: owner,
            tabs: AppTabContract.resolve(bootstrapStore.bootstrap),
            onSelectTab: selectTab,
            onNavigate: navigate,
          ),
        ),
        if (!isRoot)
          MaterialPage<void>(
            key: ValueKey<String>('destination:$_location'),
            child: known
                ? _buildDestination(owner)
                : UnknownRouteScreen(
                    route: _location,
                    onClose: () => selectTab(CanonicalTab.home),
                  ),
          ),
      ],
      onDidRemovePage: (page) {
        if (!AppRouteContract.rootPaths.contains(_location)) {
          selectTab(owner);
        }
      },
    );
  }

  Widget _buildDestination(CanonicalTab owner) {
    final route = AppRouteContract.devotionalRoute(_location);
    if (route == null) {
      return EnginePlaceholderScreen(
        route: _location,
        onClose: () => selectTab(owner),
      );
    }

    final config = DevotionalHubConfig.resolve(bootstrapStore.bootstrap);
    if (!config.visible || route.slug != config.slug) {
      return UnknownRouteScreen(
        route: _location,
        onClose: () => selectTab(CanonicalTab.inspire),
      );
    }
    if (route.destinationType == null) {
      return DevotionalHubScreen(
        config: config,
        onNavigate: navigate,
        onBack: () => selectTab(CanonicalTab.inspire),
      );
    }

    final destination = config.destination(route.destinationType!);
    if (destination == null || !destination.visible) {
      return UnknownRouteScreen(
        route: _location,
        onClose: () => navigate('/devotionals/${config.slug}'),
      );
    }
    final back = () => navigate('/devotionals/${config.slug}');
    switch (destination.engineType) {
      case DevotionalEngineType.read:
        return DevotionalReadScreen(
          destination: destination,
          onBack: back,
          onNavigate: navigate,
        );
      case DevotionalEngineType.watch:
        return DevotionalWatchScreen(destination: destination, onBack: back);
      case DevotionalEngineType.quotes:
        return DevotionalQuotesScreen(
          destination: destination,
          onBack: back,
          onNavigate: navigate,
        );
      case DevotionalEngineType.quiz:
        return DevotionalQuizScreen(
          destination: destination,
          capabilityEnabled: config.quizCapabilityEnabled(
            bootstrapStore.bootstrap,
          ),
          onBack: back,
        );
    }
  }

  void _onBootstrapChanged() => notifyListeners();

  @override
  void dispose() {
    bootstrapStore.removeListener(_onBootstrapChanged);
    super.dispose();
  }
}

class CelebrationShell extends StatelessWidget {
  final CanonicalTab selectedTab;
  final List<AppTabContract> tabs;
  final ValueChanged<CanonicalTab> onSelectTab;
  final ValueChanged<String> onNavigate;

  const CelebrationShell({
    super.key,
    required this.selectedTab,
    required this.tabs,
    required this.onSelectTab,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final visibleTabs =
        tabs.where((tab) => tab.visible).toList(growable: false);
    final effectiveTabs = visibleTabs.isEmpty ? tabs : visibleTabs;
    var selectedIndex = effectiveTabs.indexWhere(
      (tab) => tab.canonical == selectedTab,
    );
    if (selectedIndex < 0) selectedIndex = 0;
    final effectiveSelection = effectiveTabs[selectedIndex].canonical;

    return Scaffold(
      body: IndexedStack(
        index: CanonicalTab.values.indexOf(effectiveSelection),
        children: <Widget>[
          const HomeScreen(),
          const LiveScreen(),
          InspireScreen(onNavigate: onNavigate),
          const _ExploreRootScreen(),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            onSelectTab(effectiveTabs[index].canonical),
        destinations: <NavigationDestination>[
          for (final tab in effectiveTabs)
            NavigationDestination(
              icon: Icon(tab.canonical.icon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _ExploreRootScreen extends StatelessWidget {
  const _ExploreRootScreen();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Explore engines will appear here as AppsHub capabilities are enabled.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class EnginePlaceholderScreen extends StatelessWidget {
  final String route;
  final VoidCallback onClose;

  const EnginePlaceholderScreen({
    super.key,
    required this.route,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onClose),
        title: const Text('Celebration TV'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.extension_outlined, size: 48),
              const SizedBox(height: 16),
              const Text(
                'This shared engine is prepared and will be connected in a focused phase.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(route, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  final String route;
  final VoidCallback onClose;

  const UnknownRouteScreen({
    super.key,
    required this.route,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: onClose)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.route_outlined, size: 48),
              const SizedBox(height: 16),
              const Text('This destination is not available.'),
              const SizedBox(height: 8),
              Text(route, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
