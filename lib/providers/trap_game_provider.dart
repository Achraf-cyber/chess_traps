import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartchess/dartchess.dart';
import 'traps_provider.dart';

final trapGameProvider = FutureProvider.family<Position, int>((ref, index) async {
  final traps = await ref.watch(trapsProvider.future);
  if (index < 0 || index >= traps.length) {
    throw Exception('Trap not found');
  }
  
  final trap = traps[index];
  
  // Create a new game
  Position game = Chess.initial;
  
  // Parse the clean_moves PGN string
  // E.g., "1.e4 e5 2.Ne2 Bc5 3.f4 Qf6 4.c3 Nc6"
  final pgnData = trap.cleanMoves;
  
  // Basic parsing: remove numbers like "1.", "2." and split by space
  final movesParams = pgnData.replaceAll(RegExp(r'\d+\.'), '').trim().split(RegExp(r'\s+'));
  
  for (var moveStr in movesParams) {
    if (moveStr.isEmpty) continue;
    
    // Convert SAN to Move and apply
    // dartchess provides a way to parse SAN
    try {
      final move = game.parseSan(moveStr);
      if (move != null) {
        game = game.playUnchecked(move);
      }
    } catch (e) {
      print('Error parsing move $moveStr: $e');
    }
  }
  
  return game;
});
