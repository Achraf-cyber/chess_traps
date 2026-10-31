import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/router.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A trap in the search results: the position it ends on, what it's called,
/// and the moves still to come from the position on the search board.
class SearchResultTile extends ConsumerWidget {
  const SearchResultTile({super.key, required this.trap, required this.ply});

  static const _thumbnailSize = 72.0;

  final ChessTrap trap;

  /// How many of the trap's moves are already on the search board.
  final int ply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardTheme = ref.watch(chessSettingsProvider).boardTheme;
    final line = _remainingLine();
    final opening = trap.getLocalizedOpening(context);

    return InkWell(
      onTap: () => TrapDetailRoute(index: trap.id).push<void>(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: IgnorePointer(
                child: StaticChessboard(
                  size: _thumbnailSize,
                  orientation: trap.targetSide,
                  fen: trap.fen,
                  settings: StaticChessboardSettings(
                    colorScheme: boardTheme.colorScheme,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trap.getLocalizedName(context),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (opening.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      opening,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (line.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Chess notation reads left to right in every language.
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        line,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The moves from [ply] on, numbered: `3. Bc4 Nf6 4. Ng5`.
  String _remainingLine() {
    final line = StringBuffer();
    for (var i = ply; i < trap.moves.length; i++) {
      final number = i ~/ 2 + 1;
      if (i.isEven) {
        line.write('$number. ');
      } else if (i == ply) {
        line.write('$number... ');
      }
      line.write('${trap.moves[i]} ');
    }
    return line.toString().trimRight();
  }
}
