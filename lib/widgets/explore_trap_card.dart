import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_traps/providers/daily_limit_provider.dart';
import 'package:chess_traps/services/rewarded_ad_manager.dart';

class ExploreTrapCard extends ConsumerWidget {
  const ExploreTrapCard({super.key, required this.trap, this.showBadge = true});

  final ChessTrap trap;
  final bool showBadge;

  void _handleTap(BuildContext context, WidgetRef ref) {
    final dailyLimit = ref.read(dailyLimitProvider.notifier);
    if (!dailyLimit.canViewTrap()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.phrase.limitReached),
          content: const Text("You've viewed your 10 free traps for today! Watch a short ad to unlock all traps for the rest of the day."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.phrase.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (RewardedAdManager().isAdAvailable) {
                  RewardedAdManager().showAdIfAvailable(
                    onRewardEarned: () {
                      dailyLimit.unlockForToday();
                      TrapDetailRoute(index: trap.id).push<void>(context);
                    },
                    onFailed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ad could not be loaded. Try again later.")),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ad not ready yet. Try again later.")),
                  );
                  RewardedAdManager().loadAd();
                }
              },
              child: Text(context.phrase.watchAd),
            ),
          ],
        ),
      );
      return;
    }
    
    dailyLimit.incrementViewCount();
    TrapDetailRoute(index: trap.id).push<void>(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate a pseudo-difficulty based on move count for extra detail
    final String difficulty = trap.moves.length > 10
        ? context.phrase.advanced
        : trap.moves.length > 6
        ? context.phrase.intermediate
        : context.phrase.beginner;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant,
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: context.colors.surfaceContainerHighest,
                    child: IgnorePointer(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          return StaticChessboard(
                            size: width,
                            orientation: trap.targetSide,
                            fen: trap.fen,
                          );
                        },
                      ),
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.colors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          difficulty,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trap.getLocalizedName(context),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 14,
                          color: context.colors.primary,
                        ),
                        Expanded(
                          child: Text(
                            trap.opening,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}

