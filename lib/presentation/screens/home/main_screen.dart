import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router.dart';
import '../../../utils.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = GoRouterState.of(context).uri;

    // Map paths → nav indices (5 items)
    int currentIndex = 0;
    if (uri.path.startsWith('/traps') ||
        uri.path.startsWith('/group')) {
      currentIndex = 1;
    } else if (uri.path.startsWith('/searchbymoves')) {
      currentIndex = 2;
    } else if (uri.path.startsWith('/play')) {
      currentIndex = 3;
    } else if (uri.path.startsWith('/profile')) {
      currentIndex = 4;
    }

    void onTap(int idx) {
      switch (idx) {
        case 0:
          const HomeRoute().go(context);
        case 1:
          const TrapsRoute().go(context);
        case 2:
          const SearchByMovesRoute().push<void>(context);
        case 3:
          const PlayRoute().push<void>(context);
        case 4:
          const ProfileRoute().go(context);
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: currentIndex,
        onTap: onTap,
        homeLabel: context.phrase.home,
        learnLabel: context.phrase.traps,
        searchLabel: context.phrase.search,
        playLabel: context.phrase.play,
        settingsLabel: context.phrase.profile,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom animated bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.homeLabel,
    required this.learnLabel,
    required this.searchLabel,
    required this.playLabel,
    required this.settingsLabel,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final String homeLabel;
  final String learnLabel;
  final String searchLabel;
  final String playLabel;
  final String settingsLabel;

  static const _icons = <(IconData, IconData)>[
    (Icons.home_outlined, Icons.home_rounded),
    (Icons.menu_book_outlined, Icons.menu_book_rounded),
    (Icons.search_outlined, Icons.search_rounded),
    (Icons.castle_outlined, Icons.castle_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labels = [homeLabel, learnLabel, searchLabel, playLabel, settingsLabel];
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(5, (index) {
            final selected = currentIndex == index;
            final (outlinedIcon, filledIcon) = _icons[index];
            return Expanded(
              child: _NavItem(
                icon: selected ? filledIcon : outlinedIcon,
                label: labels[index],
                selected: selected,
                onTap: () => onTap(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final color = selected ? scheme.onSurface : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      splashColor: scheme.primary.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 23, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
