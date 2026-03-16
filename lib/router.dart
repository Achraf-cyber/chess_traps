import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/favorites/view/favorites_screen.dart';
import 'features/home/view/main_screen.dart';
import 'features/home/view/main_subscreen.dart';
import 'features/profile/view/profile_screen.dart';
import 'features/training/view/train_screen.dart';
import 'features/traps/view/trap_detail_screen.dart';
import 'features/traps/view/traps_screen.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: $appRoutes,
);

@TypedShellRoute<MainShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<TrapsRoute>(path: '/traps'),
    TypedGoRoute<FavoritesRoute>(path: '/favorites'),
    TypedGoRoute<TrainRoute>(path: '/train'),
    TypedGoRoute<ProfileRoute>(path: '/profile'),
  ],
)
class MainShellRouteData extends ShellRouteData {
  const MainShellRouteData();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainScreen(child: navigator);
  }
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: MainSubscreen());
}

class TrapsRoute extends GoRouteData with $TrapsRoute {
  const TrapsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: TrapsScreen());
}

class FavoritesRoute extends GoRouteData with $FavoritesRoute {
  const FavoritesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: FavoritesScreen());
}

class TrainRoute extends GoRouteData with $TrainRoute {
  const TrainRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: TrainScreen());
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: ProfileScreen());
}

@TypedGoRoute<TrapDetailRoute>(path: '/trap/:index')
class TrapDetailRoute extends GoRouteData with $TrapDetailRoute {
  const TrapDetailRoute({required this.index});
  final int index;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TrapDetailScreen(trapIndex: index);
}
