import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/traps_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/train_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/trap_detail_screen.dart';
import 'screens/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/traps',
          pageBuilder: (context, state) => const NoTransitionPage(child: TrapsScreen()),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => const NoTransitionPage(child: FavoritesScreen()),
        ),
        GoRoute(
          path: '/train',
          pageBuilder: (context, state) => const NoTransitionPage(child: TrainScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/trap/:index',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final indexStr = state.pathParameters['index']!;
        final index = int.tryParse(indexStr) ?? 0;
        return TrapDetailScreen(trapIndex: index);
      },
    ),
  ],
);
