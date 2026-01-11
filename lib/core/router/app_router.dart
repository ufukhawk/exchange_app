import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/home_wrapper.dart';
import '../../presentation/screens/settings_screen.dart';
import '../constants/app_constants.dart';
import '../state_management/state_manager.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(StateManager stateManager) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteConstants.home,
      routes: [
        GoRoute(
          path: RouteConstants.home,
          builder: (context, state) => HomeWrapper(stateManager: stateManager),
        ),
        GoRoute(
          path: RouteConstants.settings,
          builder: (context, state) =>
              SettingsScreen(stateManager: stateManager),
        ),
      ],
    );
  }
}
