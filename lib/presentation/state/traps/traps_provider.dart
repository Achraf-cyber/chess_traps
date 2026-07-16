import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';

part 'traps_provider.g.dart';

@Riverpod(keepAlive: true)
List<ChessTrap> traps(Ref ref) {
  return chessTraps;
}

@riverpod
ChessTrap trapOfTheDay(Ref ref) {
  final allTraps = ref.watch(trapsProvider);
  if (allTraps.isEmpty) return chessTraps[0];

  final date = DateTime.now().toUtc();
  final int seed = date.year * 10000 + date.month * 100 + date.day;
  final index = seed % allTraps.length;
  return allTraps[index];
}

ChessTrap indexToChessTrap(int index) {
  return chessTraps[index];
}

/// Other traps in the same opening, for the "related traps" suggestion at
/// the end of a trap. Falls back to a few traps overall if the opening only
/// has this one trap.
@riverpod
List<ChessTrap> relatedTraps(Ref ref, int trapId) {
  final allTraps = ref.watch(trapsProvider);
  ChessTrap? trap;
  for (final t in allTraps) {
    if (t.id == trapId) {
      trap = t;
      break;
    }
  }
  if (trap == null) return const [];
  final openingId = trap.openingId;

  final sameOpening = allTraps
      .where((t) => t.id != trapId && t.openingId == openingId && openingId.isNotEmpty)
      .toList();
  if (sameOpening.isNotEmpty) return sameOpening.take(6).toList();

  return allTraps.where((t) => t.id != trapId).take(6).toList();
}
