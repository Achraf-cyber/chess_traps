import 'package:chess_traps/data/chess_trap.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/generated/chess/prebuilt_name_index.dart';

List<ChessTrap> searchTrapByName(String name) {
  final result = <int>[];
  for (final MapEntry<String, List<int>>(:key, :value) in nameIndex.entries) {
    if (key.contains(name)) {
      result.addAll(value);
    }
  }
  return getTrapsListById(result);
}

List<ChessTrap> getTrapsListById(List<int> ids) {
  return ids.map((id) => chessTraps[id]).toList();
}
