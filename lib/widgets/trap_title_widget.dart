import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class TrapTitleWidget extends StatelessWidget {
  const TrapTitleWidget({super.key, required this.label, required this.trap});
  final String label;
  final ChessTrap trap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          TrapDetailRoute(index: trap.id).push<void>(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Center(
                      child: Builder(builder: (context) {
                        final boardSize = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : 120.0;
                        return SizedBox.square(
                          dimension: boardSize,
                          child: StaticChessboard(
                            size: boardSize,
                            orientation: .white,
                            fen: trap.fen,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trap.trapName,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
