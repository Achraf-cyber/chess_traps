import 'dart:math';
import 'package:chess_traps/data/search_by_moves/chess_search.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/data/traps/openings.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'traps_group_provider.g.dart';

@riverpod
Map<String, List<int>> trapsGroupSource(Ref ref) {
  final openingNames = ecoOpenings
      .map((opening) => opening.name.trim())
      .where((name) => name.isNotEmpty)
      .toSet();
  final byOpening = <String, List<int>>{};

  for (final trap in chessTraps) {
    final opening = trap.opening.trim();
    if (opening.isEmpty || !openingNames.contains(opening)) {
      continue;
    }
    byOpening.putIfAbsent(opening, () => []).add(trap.id);
  }

  final sortedKeys = byOpening.keys.toList()..sort();
  return {for (final key in sortedKeys) key: byOpening[key]!};
}

@riverpod
List<ChessTrap> trapsSearchByName(Ref ref, String name) {
  final traps = searchTrapByName(name);
  return traps;
}

@riverpod
List<ChessTrap> trapsOfGroup(Ref ref, String groupName) {
  final groups = ref.watch(trapsGroupSourceProvider);
  final indices = groups[groupName] ?? [];
  return indices
      .where((index) => index >= 0 && index < chessTraps.length)
      .map((index) => chessTraps[index])
      .toList();
}

@riverpod
ChessTrap? randomFeaturedTrap(Ref ref) {
  final allTraps = chessTraps.where((t) => t.trapName.trim().isNotEmpty).toList();
  if (allTraps.isEmpty) return null;
  final random = Random.secure();
  return allTraps[random.nextInt(allTraps.length)];
}
