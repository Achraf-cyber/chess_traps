import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/chess_trap.dart';
import '../generated/chess/base_chess_traps.dart';

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
