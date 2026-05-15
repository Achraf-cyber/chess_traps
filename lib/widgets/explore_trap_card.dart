import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

class ExploreTrapCard extends StatelessWidget {
  const ExploreTrapCard({super.key, required this.trap, this.showBadge = true});

  final ChessTrap trap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    // Generate a pseudo-difficulty based on move count for extra detail
    final String difficulty = trap.moves.length > 10
        ? "Advanced"
        : trap.moves.length > 6
        ? "Intermediate"
        : "Beginner";

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          // ignore: deprecated_member_use
          color: context.colors.outlineVariant.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: context.colors.shadow.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => TrapDetailRoute(index: trap.id).push<void>(context),
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
                    // ignore: deprecated_member_use
                    color: context.colors.surfaceContainerHighest.withOpacity(0.3),
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
                          // ignore: deprecated_member_use
                          color: context.colors.surface.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: context.colors.outlineVariant.withOpacity(0.3),
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
                        fontWeight: FontWeight.w800,
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
                          // ignore: deprecated_member_use
                          color: context.colors.primary.withOpacity(0.8),
                        ),
                        Expanded(
                          child: Text(
                            trap.opening,
                            style: context.textTheme.labelSmall?.copyWith(
                              // ignore: deprecated_member_use
                              color: context.colors.onSurfaceVariant.withOpacity(0.8),
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

