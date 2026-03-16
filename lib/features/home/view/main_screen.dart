import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';

import '../../../router.dart';
import '../../../utils.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current URI path to determine which bottom nav item is selected
    final Uri uri = GoRouterState.of(context).uri;
    var currentIndex = 0;
    if (uri.path.startsWith('/traps')) {
      currentIndex = 1;
    } else if (uri.path.startsWith('/favorites')) {
      currentIndex = 2;
    } else if (uri.path.startsWith('/train')) {
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
              const TrainRoute().go(context);
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
            icon: const Icon(Ionicons.train_outline),
            selectedIcon: const Icon(Ionicons.train),
            label: context.phrase.training,
          ),
          // NavigationDestination(
          //   icon: const Icon(Icons.person_outline),
          //   selectedIcon: const Icon(Icons.person),
          //   label: context.phrase.profile,
          // ),
        ],
      ),
    );
  }
}
