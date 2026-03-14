import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current URI path to determine which bottom nav item is selected
    final uri = GoRouterState.of(context).uri;
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
              context.go('/');
              break;
            case 1:
              context.go('/traps');
              break;
            case 2:
              context.go('/favorites');
              break;
            case 3:
              context.go('/train');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Traps',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
