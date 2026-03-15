import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/chess_trap.dart';
import 'traps_provider.dart';

part 'trap_game_provider.g.dart';

@riverpod
Future<Position> trapGame(Ref ref, int index) async {
  final List<ChessTrap> traps = await ref.watch(trapsProvider.future);
  if (index < 0 || index >= traps.length) {
    throw Exception('Trap not found');
  }

  final ChessTrap trap = traps[index];

  // Create a new game
  Position game = Chess.initial;

  // Parse the clean_moves PGN string
  // E.g., "1.e4 e5 2.Ne2 Bc5 3.f4 Qf6 4.c3 Nc6"
  final String pgnData = trap.cleanMoves;

  // Basic parsing: remove numbers like "1.", "2." and split by space
  final List<String> movesParams = pgnData
      .replaceAll(RegExp(r'\d+\.'), '')
      .trim()
      .split(RegExp(r'\s+'));

  for (final moveStr in movesParams) {
    if (moveStr.isEmpty) {
      continue;
    }

    // Convert SAN to Move and apply
    // dartchess provides a way to parse SAN
    try {
      final Move? move = game.parseSan(moveStr);
      if (move != null) {
        game = game.playUnchecked(move);
      }
    } catch (e) {
      debugPrint('Error parsing move $moveStr: $e');
    }
  }

  return game;
}
