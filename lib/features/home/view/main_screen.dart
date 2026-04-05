import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../router.dart';
import '../../../utils.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Uri uri = GoRouterState.of(context).uri;
    
    int currentIndex = 0;
    if (uri.path.startsWith('/traps')) {
      currentIndex = 1;
    } else if (uri.path.startsWith('/favorites')) {
      currentIndex = 2;
    } else if (uri.path.startsWith('/searchbymoves')) {
      currentIndex = 3;
    } else if (uri.path.startsWith('/profile')) {
      currentIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              const HomeRoute().go(context);
            case 1:
              const TrapsRoute().go(context);
            case 2:
              const FavoritesRoute().go(context);
            case 3:
              const SearchByMovesRoute().go(context);
            case 4:
              const ProfileRoute().go(context);
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.phrase.home,
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.chess.data),
            selectedIcon: Icon(FontAwesomeIcons.chess.data),
            label: context.phrase.traps,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: context.phrase.favorite,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            selectedIcon: const Icon(Icons.search_outlined),
            label: context.phrase.search,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.phrase.profile,
          ),
        ],
      ),
    );
  }
}
