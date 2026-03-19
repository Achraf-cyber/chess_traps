import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/utils.dart';
import 'package:dartchess/dartchess.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/chess_trap.dart';

part 'trap_game_provider.g.dart';

@riverpod
ChessTrap trapGame(Ref ref, int index) {
  final List<ChessTrap> traps = chessTraps;
  if (index < 0 || index >= traps.length) {
    throw Exception('Trap not found');
  }

  final ChessTrap trap = traps[index];

  return trap;
}
