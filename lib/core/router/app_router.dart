import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_scanner/core/constants/app_constants.dart';
import 'package:smart_scanner/core/presentation/screens/bootstrap_placeholder_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.routeHome,
    routes: [
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const BootstrapPlaceholderScreen(),
      ),
    ],
  );
});
