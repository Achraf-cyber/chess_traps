import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:chess_traps/utils.dart';

/// Rule-based, offline, localized explanation for a single chess move.
///
/// Explains WHY a move matters (mate, sacrifice, fork, capture, check,
/// development) rather than just WHAT it is (the SAN already shows that).
/// Deterministic and instant — no network, no per-trap authoring needed.
/// Shared by trap detail (per-move captions), practice mode, and post-game
/// analysis on the Play screen.
class MoveAnnotation {
  const MoveAnnotation(this.text, this.kind);
  final String text;
  final MoveAnnotationKind kind;
}

enum MoveAnnotationKind { checkmate, sacrifice, fork, capture, check, quiet }

String explainMove({
  required BuildContext context,
  required Position before,
  required Move move,
  required Position after,
  required String san,
}) {
  final phrase = context.phrase;
  final piece = move is NormalMove ? before.board.pieceAt(move.from) : null;
  final pieceName = piece != null ? _pieceName(context, piece.role) : '';

  if (after.isCheckmate) {
    return phrase.explainCheckmate(pieceName);
  }

  if (move is NormalMove) {
    final captured = before.board.pieceAt(move.to);
    final isCapture = captured != null;

    // Sacrifice: this move gives up material (captured piece worth less
    // than the piece moved, or moves into an undefended attacked square)
    // without receiving fair value back.
    if (piece != null && _isSacrifice(before, after, move, piece, captured)) {
      return phrase.explainSacrifice(pieceName);
    }

    if (isCapture) {
      final capturedName = _pieceName(context, captured.role);
      return phrase.explainCapture(pieceName, capturedName);
    }

    final forkedRoles = _forkedRoles(after, move.to, piece?.color);
    if (forkedRoles.length >= 2) {
      final names = forkedRoles.map((r) => _pieceName(context, r)).join(
        phrase.andSeparator,
      );
      return phrase.explainFork(pieceName, names);
    }

    if (after.isCheck) {
      return phrase.explainCheck(pieceName);
    }
  }

  if (san.contains('O-O-O')) return phrase.explainCastleQueenside;
  if (san.contains('O-O')) return phrase.explainCastleKingside;
  if (move is NormalMove && move.promotion != null) {
    return phrase.explainPromotion(_pieceName(context, move.promotion!));
  }

  return phrase.explainDevelop(pieceName);
}

/// A move is a sacrifice if it hands over material value greater than what
/// (if anything) was captured, and the destination square is now attacked by
/// the opponent and not sufficiently defended.
bool _isSacrifice(
  Position before,
  Position after,
  NormalMove move,
  Piece movedPiece,
  Piece? captured,
) {
  final movedValue = _pieceValue(movedPiece.role);
  final capturedValue = captured != null ? _pieceValue(captured.role) : 0;
  if (movedValue <= capturedValue) return false;

  final opponent = movedPiece.color.opposite;
  final attackers = _attackersOf(after, move.to, opponent);
  return attackers.isNotEmpty;
}

Iterable<Square> _attackersOf(Position pos, Square square, Side by) sync* {
  for (final entry in pos.board.pieces) {
    final (sq, p) = entry;
    if (p.color != by) continue;
    final targets = attacks(p, sq, pos.board.occupied);
    if (targets.has(square)) yield sq;
  }
}

/// Roles of same-color-opponent pieces attacked by the piece that just
/// landed on [square], excluding the king (checks are reported separately).
List<Role> _forkedRoles(Position after, Square square, Side? movedColor) {
  if (movedColor == null) return const [];
  final piece = after.board.pieceAt(square);
  if (piece == null) return const [];

  final targets = attacks(piece, square, after.board.occupied);
  final roles = <Role>[];
  for (final target in targets.squares) {
    final targetPiece = after.board.pieceAt(target);
    if (targetPiece != null &&
        targetPiece.color != movedColor &&
        targetPiece.role != Role.king &&
        _pieceValue(targetPiece.role) >= 3) {
      roles.add(targetPiece.role);
    }
  }
  return roles;
}

int _pieceValue(Role role) => switch (role) {
      Role.pawn => 1,
      Role.knight => 3,
      Role.bishop => 3,
      Role.rook => 5,
      Role.queen => 9,
      Role.king => 0,
    };

String _pieceName(BuildContext context, Role role) => switch (role) {
      Role.pawn => context.phrase.piecePawn,
      Role.knight => context.phrase.pieceKnight,
      Role.bishop => context.phrase.pieceBishop,
      Role.rook => context.phrase.pieceRook,
      Role.queen => context.phrase.pieceQueen,
      Role.king => context.phrase.pieceKing,
    };
