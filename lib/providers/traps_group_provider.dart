import 'package:chess_traps/data/chess_search.dart';
import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/generated/chess_groups.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'traps_group_provider.g.dart';

@riverpod
Map<String, List<int>> trapsGroupSource(Ref ref) {
  return trapsGroup;
}

@riverpod
List<ChessTrap> trapsSearchByName(Ref ref, String name) {
  final traps = searchTrapByName(name);
  return traps;
}

@riverpod
List<ChessTrap> trapsOfGroup(Ref ref, String groupName) {
  return trapsGroup[groupName]!
      .toList()
      .map((element) => chessTraps[element])
      .toList();
}
