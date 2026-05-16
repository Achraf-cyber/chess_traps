import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess_traps/providers/daily_limit_provider.dart';
import 'package:chess_traps/providers/learned_traps_provider.dart';
import 'package:chess_traps/services/rewarded_ad_manager.dart';

import 'package:flutter_animate/flutter_animate.dart';

class ExploreTrapCard extends ConsumerWidget {
  const ExploreTrapCard({super.key, required this.trap, this.showBadge = true});

  final ChessTrap trap;
  final bool showBadge;

  void _handleTap(BuildContext context, WidgetRef ref) {
    final dailyLimit = ref.read(dailyLimitProvider.notifier);
    if (!dailyLimit.canViewTrap()) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.phrase.daily_limit_reached),
          content: Text(context.phrase.limit_reached_body),
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
                        SnackBar(
                          content: Text(context.phrase.ad_load_failed),
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.phrase.ad_not_ready),
                    ),
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
    final learnedTraps = ref.watch(learnedTrapsProvider);
    final isLearned = learnedTraps.contains(trap.id);

    return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _handleTap(context, ref),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                trap.getLocalizedName(context),
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isLearned)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Colors.green.withValues(alpha: 0.8),
                              ),
                          ],
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
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
