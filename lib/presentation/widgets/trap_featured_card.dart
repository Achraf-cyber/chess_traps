import 'package:chess_traps/core/constants/app_sizes.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

/// Full-width featured trap card.
/// Used on any screen that needs a large single-trap highlight.
/// [title] is displayed as the category badge above the trap name.
class TrapFeaturedCard extends StatelessWidget {
  const TrapFeaturedCard({
    super.key,
    required this.trap,
    required this.title,
  });

  final ChessTrap trap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          InterstitialAdManager().onTrapViewed();
          TrapDetailRoute(index: trap.id).push<void>(context);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: info column
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Trap name
                    Text(
                      trap.getLocalizedName(context),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: scheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trap.opening,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // CTA button
                    ElevatedButton.icon(
                      onPressed: () =>
                          TrapDetailRoute(index: trap.id).push<void>(context),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(context.phrase.learnNow),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: board thumbnail
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth;
                        return StaticChessboard(
                          size: size,
                          orientation: Side.white,
                          fen: trap.fen,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
