import 'package:dartchess/dartchess.dart';

/// True when [move] is a pawn arriving on the last rank without a promotion
/// role attached.
///
/// Chessground reports the drag as a plain [NormalMove] with `promotion: null`.
/// dartchess rejects that move as illegal — a pawn cannot legally sit on the
/// back rank — so `makeSan` throws and the move is silently dropped. Screens
/// must catch this case *before* playing the move and ask the user which piece
/// they want, either through their own dialog or by handing the move to
/// chessground's built-in selector via `GameData.promotionMove`.
bool isPromotionPending(Position position, Move move) {
  if (move is! NormalMove || move.promotion != null) return false;
  final piece = position.board.pieceAt(move.from);
  if (piece?.role != Role.pawn) return false;
  final rank = move.to.rank;
  return rank == 0 || rank == 7;
}
