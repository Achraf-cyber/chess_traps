// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $mainShellRouteData,
  $trapDetailRoute,
  $trapGroupRoute,
];

RouteBase get $mainShellRouteData => ShellRouteData.$route(
  factory: $MainShellRouteDataExtension._fromState,
  routes: [
    GoRouteData.$route(path: '/', factory: $HomeRoute._fromState),
    GoRouteData.$route(path: '/traps', factory: $TrapsRoute._fromState),
    GoRouteData.$route(path: '/favorites', factory: $FavoritesRoute._fromState),
    GoRouteData.$route(path: '/train', factory: $TrainRoute._fromState),
    GoRouteData.$route(path: '/profile', factory: $ProfileRoute._fromState),
  ],
);

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TrapsRoute on GoRouteData {
  static TrapsRoute _fromState(GoRouterState state) => const TrapsRoute();

  @override
  String get location => GoRouteData.$location('/traps');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FavoritesRoute on GoRouteData {
  static FavoritesRoute _fromState(GoRouterState state) =>
      const FavoritesRoute();

  @override
  String get location => GoRouteData.$location('/favorites');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TrainRoute on GoRouteData {
  static TrainRoute _fromState(GoRouterState state) => const TrainRoute();

  @override
  String get location => GoRouteData.$location('/train');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $trapDetailRoute => GoRouteData.$route(
  path: '/trap/:index',
  factory: $TrapDetailRoute._fromState,
);

mixin $TrapDetailRoute on GoRouteData {
  static TrapDetailRoute _fromState(GoRouterState state) =>
      TrapDetailRoute(index: int.parse(state.pathParameters['index']!));

  TrapDetailRoute get _self => this as TrapDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/trap/${Uri.encodeComponent(_self.index.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $trapGroupRoute => GoRouteData.$route(
  path: '/group/:name',
  factory: $TrapGroupRoute._fromState,
);

mixin $TrapGroupRoute on GoRouteData {
  static TrapGroupRoute _fromState(GoRouterState state) =>
      TrapGroupRoute(name: state.pathParameters['name']!);

  TrapGroupRoute get _self => this as TrapGroupRoute;

  @override
  String get location =>
      GoRouteData.$location('/group/${Uri.encodeComponent(_self.name)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
