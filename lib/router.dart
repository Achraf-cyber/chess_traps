import 'package:chess_traps/features/traps/view/trap_detail_screen.dart';
import 'package:chess_traps/features/traps/view/traps_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/favorites/view/favorites_screen.dart';
import 'features/home/view/main_screen.dart';
import 'features/home/view/main_subscreen.dart';
import 'features/profile/view/user_profile_screen.dart';
import 'features/search_by_moves/view/trap_search_screen.dart';
import 'features/traps/view/trap_list_screen.dart';

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
    TypedGoRoute<ProfileRoute>(path: '/profile'),
    TypedGoRoute<SearchByMovesRoute>(path: '/searchbymoves'),
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
      const NoTransitionPage(child: TrapListScreen());
}

class FavoritesRoute extends GoRouteData with $FavoritesRoute {
  const FavoritesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: FavoritesScreen());
}

class SearchByMovesRoute extends GoRouteData with $SearchByMovesRoute {
  const SearchByMovesRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: TrapSearchScreen());
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: UserProfileScreen());
}

@TypedGoRoute<TrapDetailRoute>(path: '/trap/:index')
class TrapDetailRoute extends GoRouteData with $TrapDetailRoute {
  const TrapDetailRoute({required this.index});
  final int index;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TrapDetailScreen(trapIndex: index);
}

@TypedGoRoute<TrapGroupRoute>(path: '/group/:name')
class TrapGroupRoute extends GoRouteData with $TrapGroupRoute {
  const TrapGroupRoute({required this.name});
  final String name;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TrapsGroupScreen(groupName: name);
}
