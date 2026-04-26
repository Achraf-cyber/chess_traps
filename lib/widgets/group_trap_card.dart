import 'dart:math' as math;

import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

class GroupTrapCard extends StatelessWidget {
  const GroupTrapCard({
    super.key,
    required this.trap,
  });

  final ChessTrap trap;
  static const _defaultFen =
      'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => TrapDetailRoute(index: trap.id).push<void>(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trap.trapName,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.ads_click_rounded,
                                size: 14,
                                color: context.colors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${trap.moves.length} moves sequence',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.colors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    IgnorePointer(
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ) * 0.9;
                            return StaticChessboard(
                              size: size,
                              orientation: .white,
                              fen: _isLikelyFen(trap.fen) ? trap.fen : _defaultFen,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  trap.commentedMoves,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLikelyFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 && parts.first.contains('/');
  }
}
