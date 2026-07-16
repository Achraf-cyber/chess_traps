import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the play-screen promotion fix.
///
/// The original bug: a pawn reaching the last rank was handed to the engine as
/// a promotion-less [NormalMove], which dartchess rejects — so the move
/// silently did nothing. The fix asks the user which piece to promote to and,
/// as a safety net, defaults to a queen for any promotion-less last-rank pawn
/// move. These tests pin down the dartchess behaviour that fix relies on.
void main() {
  group('promotion', () {
    // White pawn on a7, ready to promote on a8.
    final beforePromotion = Chess.fromSetup(
      Setup.parseFen('8/P7/8/8/8/8/8/k6K w - - 0 1'),
    );

    test('a promotion-less last-rank pawn move is illegal', () {
      final move = NormalMove.fromUci('a7a8'); // no promotion role
      expect(() => beforePromotion.play(move), throwsA(isA<PlayException>()));
    });

    test('withPromotion makes the same move legal (safety net behaviour)', () {
      final move = NormalMove.fromUci('a7a8').withPromotion(Role.queen);
      final after = beforePromotion.play(move);
      expect(after.board.pieceAt(Square.a8)?.role, Role.queen);
    });

    test('under-promotion to a knight is supported', () {
      final move = NormalMove.fromUci('a7a8').withPromotion(Role.knight);
      final after = beforePromotion.play(move);
      expect(after.board.pieceAt(Square.a8)?.role, Role.knight);
    });

    test('destination rank detection matches the screen guard (0/7)', () {
      expect(Square.a8.rank == 7, isTrue); // white promotes on rank index 7
      expect(Square.a1.rank == 0, isTrue); // black promotes on rank index 0
    });
  });
}
