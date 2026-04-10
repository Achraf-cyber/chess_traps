import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class TrapGridCard extends StatelessWidget {
  const TrapGridCard({super.key, required this.trap, this.label});
  final ChessTrap trap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          TrapDetailRoute(index: trap.id).push<void>(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.colors.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth;
                      return StaticChessboard(
                        size: size,
                        orientation: .white,
                        fen: trap.fen,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trap.trapName,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
