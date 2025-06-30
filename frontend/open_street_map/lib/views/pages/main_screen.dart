// main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../widgets/drawer_widget.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'saved_destination_page.dart';
import 'route_history_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'assigned_route_page.dart';
import '/services/assigned_route_service.dart';

class MainScreen extends StatelessWidget {
  final String token;
  final String baseUrl;

  late final AssignedRouteService assignedRouteService;

  MainScreen({required this.token, required this.baseUrl, super.key}) {
    assignedRouteService = AssignedRouteService(baseUrl: baseUrl, token: token);
  }

  List<Widget> get _pages => [
        const HomePage(),
        ProfilePage(baseUrl: baseUrl, token: token),
        SavedDestinationsPage(token: token, baseUrl: baseUrl),
        const RouteHistoryPage(),
        const SettingsPage(),
        const AboutPage(),
        AssignedRoutesPage(assignedRouteService: assignedRouteService),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bottomNavItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.map),
        label: tr('main.home'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: tr('main.profile'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.bookmark),
        label: tr('main.saved'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.history),
        label: tr('main.history'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: tr('main.settings'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.info),
        label: tr('main.about'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.map_outlined),
        label: tr('main.assigned_routes'),
      ),
    ];

    return Consumer<ValueNotifier<int>>(
      builder: (context, selectedPageNotifier, _) {
        return ValueListenableBuilder<int>(
          valueListenable: selectedPageNotifier,
          builder: (context, selectedPage, _) {
            final bool isHomePage = selectedPage == 0;

            return Scaffold(
              appBar: isHomePage
                  ? AppBar(
                      title: Text(
                        'main.title'.tr(),
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    )
                  : null,
              drawer: isHomePage ? const DrawerWidget() : null,
              body: _pages[selectedPage],
              bottomNavigationBar: isHomePage
                  ? null
                  : BottomNavigationBar(
                      currentIndex: selectedPage,
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: theme.colorScheme.primary,
                      unselectedItemColor: theme.unselectedWidgetColor,
                      backgroundColor:
                          theme.bottomNavigationBarTheme.backgroundColor ??
                              theme.colorScheme.surface,
                      items: bottomNavItems,
                      onTap: (index) => selectedPageNotifier.value = index,
                    ),
            );
          },
        );
      },
    );
  }
}
