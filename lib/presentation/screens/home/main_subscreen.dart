import 'dart:math';

import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chess_traps/presentation/state/traps/traps_group_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/presentation/state/traps/traps_provider.dart';
import 'package:chess_traps/presentation/state/streak/streak_provider.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainSubscreen extends ConsumerWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapOfTheDay = ref.watch(trapOfTheDayProvider);
    final allTraps = ref.watch(trapsProvider);
    final streak = ref.watch(streakProvider);
    final trapsGroups = ref.watch(trapsGroupSourceProvider);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList.list(
              children: [
                _HomeHeader(streak: streak.count),
                const SizedBox(height: 20),
                _SectionLabel(label: context.phrase.trapOfTheDay),
                const SizedBox(height: 12),
                _TrapOfTheDay(trap: trapOfTheDay),
                const SizedBox(height: 32),
                _SectionLabel(label: context.phrase.exploreMore),
                const SizedBox(height: 4),
                _ActionRow(
                  icon: Icons.shuffle_rounded,
                  label: context.phrase.randomTrap,
                  onTap: () {
                    final trap =
                        allTraps[Random.secure().nextInt(allTraps.length)];
                    InterstitialAdManager().onTrapViewed();
                    TrapDetailRoute(index: trap.id).push<void>(context);
                  },
                ),
                _ActionRow(
                  icon: Icons.castle_outlined,
                  label: context.phrase.play_mode,
                  onTap: () => const PlayRoute().go(context),
                ),
                _ActionRow(
                  icon: Icons.manage_search_rounded,
                  label: context.phrase.search,
                  onTap: () => const SearchByMovesRoute().go(context),
                ),
                const SizedBox(height: 32),
                _SectionLabel(label: context.phrase.browseByOpening),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _OpeningsRow(groups: trapsGroups)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            context.phrase.appName,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
        if (streak > 0) ...[
          Icon(
            Icons.local_fire_department_outlined,
            size: 18,
            color: scheme.tertiary,
          ),
          const SizedBox(width: 2),
          Text(
            streak.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.tertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// The day's trap as a diagram with its caption, the way a chess book sets it.
class _TrapOfTheDay extends ConsumerWidget {
  const _TrapOfTheDay({required this.trap});
  final ChessTrap trap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final boardTheme = ref.watch(chessSettingsProvider).boardTheme;

    void open() {
      InterstitialAdManager().onTrapViewed();
      TrapDetailRoute(index: trap.id).push<void>(context);
    }

    return InkWell(
      onTap: open,
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: IgnorePointer(
                child: StaticChessboard(
                  size: constraints.maxWidth,
                  orientation: trap.targetSide,
                  fen: trap.fen,
                  settings: StaticChessboardSettings(
                    colorScheme: boardTheme.colorScheme,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            trap.getLocalizedName(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.phrase.startTraining,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpeningsRow extends StatelessWidget {
  const _OpeningsRow({required this.groups});
  final Map<String, List<int>> groups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = groups.entries.toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return OutlinedButton(
            onPressed: () => TrapGroupRoute(name: entry.key).push<void>(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              side: BorderSide(color: scheme.outline),
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(localizedOpening(context, entry.key)),
          );
        },
      ),
    );
  }
}
