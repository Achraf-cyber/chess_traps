import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

import 'package:chess_traps/utils.dart';

/// Unicode glyph for a piece [Role]. Kept here so every surface that draws a
/// captured piece agrees on the symbol set.
String pieceGlyph(Role role) => switch (role) {
  Role.pawn => '♟',
  Role.knight => '♞',
  Role.bishop => '♝',
  Role.rook => '♜',
  Role.queen => '♛',
  Role.king => '♚',
};

/// The pieces one player has captured, followed by their material lead.
///
/// Previously each screen shipped its own version of this row — the play
/// screen drew Unicode glyphs, the trap screen drew FontAwesome icons with a
/// different height and colour scheme — so the same information looked like two
/// unrelated widgets. This is the single implementation both use.
class CapturedPiecesRow extends StatelessWidget {
  const CapturedPiecesRow({
    super.key,
    required this.pieces,
    required this.side,
    this.advantage,
    this.width,
    this.height = 20,
  });

  /// Pieces to draw.
  final List<Role> pieces;

  /// Colour the glyphs are drawn in — i.e. the side the captured pieces
  /// belonged to.
  final Side side;

  /// Material lead in pawns. Only rendered when greater than zero, so callers
  /// can pass a raw score without pre-filtering.
  final int? advantage;

  /// Optional fixed width; when null the row sizes to its parent.
  final double? width;

  final double height;

  @override
  Widget build(BuildContext context) {
    final lead = advantage ?? 0;
    if (pieces.isEmpty && lead <= 0) {
      return SizedBox(height: height, width: width);
    }

    final isWhite = side == Side.white;
    return SizedBox(
      width: width,
      height: height,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              children: [
                for (final role in pieces)
                  Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: Text(
                      pieceGlyph(role),
                      style: TextStyle(
                        color: isWhite ? Colors.white : Colors.black87,
                        fontSize: 16,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 1),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (lead > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+$lead',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
