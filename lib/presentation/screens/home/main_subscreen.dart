import 'dart:math';
import 'dart:ui';


import 'package:chess_traps/presentation/state/traps/traps_group_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/presentation/state/traps/traps_provider.dart';
import 'package:chess_traps/presentation/state/streak/streak_provider.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainSubscreen extends ConsumerWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapOfTheDay = ref.watch(trapOfTheDayProvider);
    final allTraps = ref.watch(trapsProvider);
    final streak = ref.watch(streakProvider);
    final trapsGroups = ref.watch(trapsGroupSourceProvider);
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        // ── Heroic Header ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _HomeHeader(scheme: scheme, totalTraps: allTraps.length, streak: streak.count),
        ),

        // ── Trap of the Day ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: context.phrase.trapOfTheDay),
                const SizedBox(height: 16),
                _FeaturedTrapCard(trap: trapOfTheDay),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        ),

        // ── Quick Actions ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: context.phrase.exploreMore),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionChip(
                        icon: Icons.shuffle_rounded,
                        label: context.phrase.randomTrap,
                        color: scheme.primary,
                        onTap: () {
                          final trap =
                              allTraps[Random.secure().nextInt(allTraps.length)];
                          InterstitialAdManager().onTrapViewed();
                          TrapDetailRoute(index: trap.id).push<void>(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionChip(
                        icon: Icons.sports_esports_rounded,
                        label: context.phrase.play_mode,
                        color: scheme.secondary,
                        onTap: () => const PlayRoute().go(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionChip(
                        icon: Icons.manage_search_rounded,
                        label: context.phrase.search,
                        color: scheme.tertiary,
                        onTap: () => const SearchByMovesRoute().go(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        ),

        // ── Browse Openings ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 16),
                child: _SectionLabel(label: context.phrase.browseByOpening),
              ),
              _OpeningPillsRow(groups: trapsGroups),
            ],
          )
              .animate()
              .fadeIn(delay: 350.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header (Heroic Gradient)
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.scheme, required this.totalTraps, required this.streak});
  final ColorScheme scheme;
  final int totalTraps;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  context.phrase.appName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    color: scheme.onSurface,
                    height: 1.05,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, size: 18, color: scheme.onPrimary),
                      const SizedBox(width: 4),
                      Text(
                        streak.toString(),
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Featured Trap Card (Trap of the Day) with Premium UI
// ─────────────────────────────────────────────────────────────────────────────

class _FeaturedTrapCard extends ConsumerStatefulWidget {
  const _FeaturedTrapCard({required this.trap});
  final ChessTrap trap;

  @override
  ConsumerState<_FeaturedTrapCard> createState() => _FeaturedTrapCardState();
}

class _FeaturedTrapCardState extends ConsumerState<_FeaturedTrapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        InterstitialAdManager().onTrapViewed();
        TrapDetailRoute(index: widget.trap.id).push<void>(context);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.surfaceContainerHigh.withValues(alpha: 0.8),
                      scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chess board thumbnail with subtle shadow
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: IgnorePointer(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: StaticChessboard(
                              size: 120,
                              orientation: widget.trap.targetSide,
                              fen: widget.trap.fen,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Info column
                    Expanded(
                      child: SizedBox(
                        height: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, size: 12, color: scheme.primary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      context.phrase.featuredTrap.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Trap name
                            Text(
                              widget.trap.getLocalizedName(context),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.trap.opening,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    context.phrase.startTraining,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: scheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick action chip (Premium Card)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionChip extends StatefulWidget {
  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Icon(widget.icon, size: 26, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Openings horizontal pill row
// ─────────────────────────────────────────────────────────────────────────────

class _OpeningPillsRow extends StatelessWidget {
  const _OpeningPillsRow({required this.groups});
  final Map<String, List<int>> groups;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = groups.entries.toList();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return InkWell(
            onTap: () => TrapGroupRoute(name: entry.key).push<void>(context),
            borderRadius: BorderRadius.circular(30),
            splashColor: scheme.primary.withValues(alpha: 0.1),
            highlightColor: scheme.primary.withValues(alpha: 0.05),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.8),
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
