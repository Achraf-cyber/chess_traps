import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:chess_traps/presentation/screens/traps/trap_detail_screen.dart';
import 'package:chess_traps/presentation/screens/traps/traps_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/main_screen.dart';
import 'presentation/screens/home/main_subscreen.dart';
import 'presentation/screens/profile/user_profile_screen.dart';
import 'presentation/screens/search_by_moves/trap_search_screen.dart';
import 'presentation/screens/traps/trap_list_screen.dart';
import 'presentation/screens/play/play_screen.dart';
import 'package:chess_traps/presentation/screens/onboarding/onboarding_screen.dart';

part 'router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

bool hasCompletedOnboarding = false;

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  observers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  redirect: (context, state) {
    if (!hasCompletedOnboarding && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    ...$appRoutes,
  ],
);

@TypedShellRoute<MainShellRouteData>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<HomeRoute>(path: '/'),
    TypedGoRoute<TrapsRoute>(path: '/traps'),
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
      const NoTransitionPage(child: TrapListScreen());
}

@TypedGoRoute<PlayRoute>(path: '/play')
class PlayRoute extends GoRouteData with $PlayRoute {
  const PlayRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: PlayScreen());
}

@TypedGoRoute<FavoritesRoute>(path: '/favorites')
class FavoritesRoute extends GoRouteData with $FavoritesRoute {
  const FavoritesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FavoritesScreen();
}


@TypedGoRoute<SearchByMovesRoute>(path: '/searchbymoves')
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

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      const NoTransitionPage(child: OnboardingScreen());
}
