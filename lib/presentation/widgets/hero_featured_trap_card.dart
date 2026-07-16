import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

/// Large featured card shown at the top of the Trap List screen.
/// No daily-limit gating — tapping goes directly to the detail screen.
class HeroFeaturedTrapCard extends StatelessWidget {
  const HeroFeaturedTrapCard({super.key, required this.trap});
  final ChessTrap trap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            InterstitialAdManager().onTrapViewed();
            TrapDetailRoute(index: trap.id).push<void>(context);
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          child: SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Board fills the right half, visually
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 180,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(AppSizes.radiusXXL),
                      ),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            colors: [Colors.transparent, Colors.black],
                            stops: [0.0, 0.3],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: StaticChessboard(
                          size: 180,
                          orientation: trap.targetSide,
                          fen: trap.fen,
                        ),
                      ),
                    ),
                  ),
                ),

                // Text content on the left
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  right: 160,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // "Featured" badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusS),
                          ),
                          child: Text(
                            context.phrase.featuredTrap.toUpperCase(),
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        // Trap name
                        Text(
                          trap.getLocalizedName(context),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.onSurface,
                            height: 1.15,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Opening name + cta arrow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              trap.opening,
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    context.phrase.startTraining,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 13,
                                  color: scheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Border overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: scheme.outline.withValues(alpha: 0.4),
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusXXL),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
