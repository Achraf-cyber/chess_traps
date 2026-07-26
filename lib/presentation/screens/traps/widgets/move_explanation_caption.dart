import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_traps/core/services/move_annotator.dart';
import 'package:chess_traps/presentation/state/traps/trap_game_provider.dart';
import 'package:chess_traps/utils.dart';

class MoveExplanationCaption extends ConsumerWidget {
  const MoveExplanationCaption({
    required this.trapIndex,
    required this.moveIndex,
    required this.san,
  });

  final int trapIndex;
  final int moveIndex; // position AFTER the move to explain
  final String san;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final before = ref.watch(trapPositionProvider(trapIndex, moveIndex - 1));
    final after = ref.watch(trapPositionProvider(trapIndex, moveIndex));
    final move = before.parseSan(san);
    if (move == null) return const SizedBox.shrink();

    final explanation = explainMove(
      context: context,
      before: before,
      move: move,
      after: after,
      san: san,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 14, color: context.colors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              explanation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
