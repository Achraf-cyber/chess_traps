import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'package:chess_traps/core/services/move_annotator.dart';
import 'package:chess_traps/presentation/state/play/play_game_provider.dart';
import 'package:chess_traps/utils.dart';

class PostGameExplanationCaption extends StatelessWidget {
  const PostGameExplanationCaption({required this.state});
  final PlayGameState state;

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = state.browseIndex ?? state.fenHistory.length - 1;
    if (effectiveIndex <= 0 || effectiveIndex > state.moveHistory.length) {
      return const SizedBox.shrink();
    }

    final beforeFen = state.fenHistory[effectiveIndex - 1];
    final afterFen = state.fenHistory[effectiveIndex];
    final uci = state.moveHistory[effectiveIndex - 1];

    Position before;
    Position after;
    Move move;
    String san;
    try {
      before = Chess.fromSetup(Setup.parseFen(beforeFen));
      after = Chess.fromSetup(Setup.parseFen(afterFen));
      move = NormalMove.fromUci(uci);
      final (_, sanResult) = before.makeSan(move);
      san = sanResult;
    } catch (_) {
      return const SizedBox.shrink();
    }

    final explanation = explainMove(
      context: context,
      before: before,
      move: move,
      after: after,
      san: san,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: context.colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: context.textTheme.bodySmall?.copyWith(
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
