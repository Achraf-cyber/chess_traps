import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_traps/presentation/state/traps/learned_traps_provider.dart';

class ExploreTrapCard extends ConsumerWidget {
  const ExploreTrapCard({super.key, required this.trap, this.showBadge = true});

  final ChessTrap trap;
  final bool showBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final learnedTraps = ref.watch(learnedTrapsProvider);
    final isLearned = learnedTraps.contains(trap.id);

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          InterstitialAdManager().onTrapViewed();
          TrapDetailRoute(index: trap.id).push<void>(context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isLearned
                  ? scheme.primary.withValues(alpha: 0.4)
                  : scheme.outline.withValues(alpha: 0.35),
              width: isLearned ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Chess board thumbnail
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    IgnorePointer(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return StaticChessboard(
                            size: constraints.maxWidth,
                            orientation: trap.targetSide,
                            fen: trap.fen,
                          );
                        },
                      ),
                    ),
                    // Learned badge: subtle dot in corner
                    if (isLearned)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surfaceContainerHighest,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          trap.getLocalizedName(context),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                            letterSpacing: -0.1,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        trap.opening,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
