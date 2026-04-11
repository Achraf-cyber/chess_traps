// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final file = File('lib/generated/chess/base_chess_traps.dart');
  final content = file.readAsStringSync();

  // Basic regex to find cleanMoves values
  final exp = RegExp(r'cleanMoves:\s+"([^"]+)"');
  final matches = exp.allMatches(content);

  final moves = <String>[];
  for (final m in matches) {
    moves.add(m.group(1)!);
  }

  final counts = <String, int>{};
  for (final m in moves) {
    counts[m] = (counts[m] ?? 0) + 1;
  }

  final duplicates = counts.entries.where((e) => e.value > 1).toList();
  if (duplicates.isEmpty) {
    print('No duplicates found in base_chess_traps.dart');
  } else {
    print('Found ${duplicates.length} duplicates:');
    for (final d in duplicates) {
      print('${d.value}x: ${d.key}');
    }
  }
}
