import 'dart:math';

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
  final maxInd = chessTraps.length;
  final date = DateTime.now();
  final int seed = date.year * 10000 + date.month * 100 + date.day;
  final id = seed % maxInd;
  return chessTraps[id];
}

@riverpod
ChessTrap randomTrap(Ref ref) {
  final maxInd = chessTraps.length;
  final int id = Random().nextInt(maxInd);
  return chessTraps[id];
}

ChessTrap indexToChessTrap(int index) {
  return chessTraps[index];
}
