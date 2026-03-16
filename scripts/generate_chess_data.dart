import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' hide File;

const String reset = '\x1B[0m';
const String green = '\x1B[32m';

void main() async {
  final trapsfile = File('../assets/chess/g700.json');
  // ignore: avoid_slow_async_io
  if (!await trapsfile.exists()) {
    stderr.writeln('File not found: ${trapsfile.path}');
    return;
  }

  final String trapsString = await trapsfile.readAsString();
  final json = jsonDecode(trapsString) as List;
  final content = StringBuffer();

  content.writeln(r'// GENERATED FILE DO NOT EDIT');
  content.writeln(r'// ignore_for_file: prefer_single_quotes');
  content.writeln("import '../../data/chess_trap.dart';");
  content.writeln('const List<ChessTrap> chessTraps = [\n');
  var id = 0;
  final uniques = <String>{};
  for (final group in json) {
    for (final trap in group as List) {
      final trapMap = trap as Map;
      final movesString = trapMap['clean_moves'] as String;

      if (uniques.contains(movesString)) {
        continue;
      } else {
        uniques.add(movesString);
      }
      final fen = pgnToFen(movesString);

      final regExp = RegExp(r'\d+\.');
      final List<String> moves = movesString
          .split(regExp)
          .where((e) => e.trim().isNotEmpty)
          .expand((e) => e.trim().split(' '))
          .toList();
      final moveList = moves.where((e) => e.isNotEmpty).join("','");
      content.writeln("""
ChessTrap(
 id: ${id++}, 
  cleanMoves: '${trapMap['clean_moves']}',
  metadata: '${trapMap['metadata']}',
  opening: '${trapMap['opening']}',
  trapName: ${jsonEncode(trapMap['trap_name'])},
  commentedMoves: '${trapMap['commented_moves']}',
  moves: ['$moveList'],
  fen: '$fen'
),
""");
    }
  }
  content.writeln('];');

  // Ensure output folder exists
  const outputFolder = '../lib/generated/chess';
  await Directory(outputFolder).create(recursive: true);

  final baseFile = File('$outputFolder/base_chess_traps.dart');
  await baseFile.writeAsString(content.toString());

  // Run dart format and capture result
  final ProcessResult result = await Process.run('dart', [
    'format',
    baseFile.path,
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('Formatting failed:\n${result.stderr}');
  } else {
    stdout.writeln('$green Finished formatting and writing $reset');
  }
}

String pgnToFen(String pgn) {
  final game = PgnGame.parsePgn(pgn);
  var position = PgnGame.startingPosition(game.headers);

  for (final node in game.moves.mainline()) {
    final move = position.parseSan(node.san);
    if (move == null) break;
    position = position.play(move);
  }
  return position.fen;
}
