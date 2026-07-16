import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:dartchess/dartchess.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/utils.dart';

part 'trap_game_provider.g.dart';

@riverpod
ChessTrap? trapGame(Ref ref, int index) {
  final List<ChessTrap> traps = chessTraps;
  if (index < 0 || index >= traps.length) {
    return null;
  }

  final ChessTrap trap = traps[index];

  return trap;
}

@riverpod
Position trapPosition(Ref ref, int index, int moveIndex) {
  final trap = ref.watch(trapGameProvider(index));
  if (trap == null) {
    return pgnToPositionIndex("", 0); // Safe fallback
  }
  return pgnToPositionIndex(trap.cleanMoves, moveIndex);
}
