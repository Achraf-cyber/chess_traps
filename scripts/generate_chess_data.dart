import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' hide File;
import 'package:chess_traps/data/openings.dart';

const String reset = '\x1B[0m';
const String green = '\x1B[32m';

void main() async {
  final trapsDir = Directory('data/chess traps');
  // ignore: avoid_slow_async_io
  if (!await trapsDir.exists()) {
    stderr.writeln('Folder not found: ${trapsDir.path}');
    return;
  }

  final pgnFiles = await trapsDir
      .list()
      .where((e) => e is File && e.path.toLowerCase().endsWith('.pgn'))
      .cast<File>()
      .toList();

  if (pgnFiles.isEmpty) {
    stderr.writeln('No PGN files found in: ${trapsDir.path}');
    return;
  }

  final games = <PgnGame>[];
  for (final f in pgnFiles) {
    final text = await f.readAsString();
    for (final chunk in _splitPgnIntoGames(text)) {
      try {
        games.add(PgnGame.parsePgn(chunk));
      } catch (e) {
        stderr.writeln('Failed parsing PGN game in ${f.path}: $e');
      }
    }
  }

  final content = StringBuffer();

  content.writeln(r'// GENERATED FILE DO NOT EDIT');
  content.writeln(r'// ignore_for_file: prefer_single_quotes');
  content.writeln("import '../../data/chess_trap.dart';");
  content.writeln('const List<ChessTrap> chessTraps = [\n');
  var id = 0;
  final uniques = <String>{};
  final groups = <String, List<int>>{};
  for (final game in games) {
    final sanMoves = game.moves.mainline().map((n) => n.san).toList();
    if (sanMoves.isEmpty) continue;

    final cleanMoves = _sanMovesToNumberedPgn(sanMoves);
    final uniqueKey = sanMoves.join(' ');
    if (uniques.contains(uniqueKey)) {
      continue;
    }
    uniques.add(uniqueKey);

    final fen = _pgnToFen(cleanMoves);

    // Look up opening from our openings database
    final matchedOpening = _findOpening(sanMoves);
    final opening = matchedOpening?.name ?? (game.headers['Opening'] ?? '');
    final openingId = matchedOpening?.id ?? '';

    // Add to groups
    groups.putIfAbsent(opening, () => []).add(id);

    final trapName =
        game.headers['ChapterName'] ?? game.headers['Event'] ?? opening;
    final metadata = _buildMetadata(game.headers);

    final moveList = sanMoves.map(_encode).join(',');

    content.writeln('ChessTrap(');
    content.writeln('  id: ${id++},');
    content.writeln('  cleanMoves: ${_encode(cleanMoves)},');
    content.writeln('  metadata: ${_encode(metadata)},');
    content.writeln('  opening: ${_encode(opening)},');
    content.writeln('  openingId: ${_encode(openingId)},');
    content.writeln('  trapName: ${_encode(trapName)},');

    // NOTE: commentedMoves not needed yet -> keep as plain cleaned moves.
    content.writeln('  commentedMoves: ${_encode(cleanMoves)},');
    content.writeln('  moves: [$moveList],');
    content.writeln('  fen: ${_encode(fen)},');
    content.writeln('),\n');
  }
  content.writeln('];');

  // Ensure output folder exists
  const outputFolder = 'lib/generated/chess';
  await Directory(outputFolder).create(recursive: true);

  final baseFile = File('$outputFolder/base_chess_traps.dart');
  await baseFile.writeAsString(content.toString());

  await _runDartCommand(['format', baseFile.path]);

  // Generate chess_groups.dart
  final groupsFile = File('lib/generated/chess_groups.dart');
  final groupsContent = StringBuffer();
  groupsContent.writeln('const trapsGroup = {');
  final sortedGroupNames = groups.keys.toList()..sort();
  for (final name in sortedGroupNames) {
    groupsContent.writeln('${jsonEncode(name)} : ${groups[name]},');
  }
  groupsContent.writeln('};');
  await groupsFile.writeAsString(groupsContent.toString());
  await _runDartCommand(['format', groupsFile.path]);

  // Generate trie + name index from the updated chessTraps list
  await _runDartCommand(['run', 'scripts/generate_chess_tries.dart']);

  stdout.writeln('$green Finished generating traps and tries $reset');
}

/// Finds the longest matching opening from [ecoOpenings] that is a prefix of [trapMoves].
OpeningEntry? _findOpening(List<String> trapMoves) {
  OpeningEntry? bestMatch;
  for (final opening in ecoOpenings) {
    if (opening.moves.length > trapMoves.length) continue;

    bool match = true;
    for (int i = 0; i < opening.moves.length; i++) {
      if (opening.moves[i] != trapMoves[i]) {
        match = false;
        break;
      }
    }

    if (match) {
      if (bestMatch == null || opening.moves.length > bestMatch.moves.length) {
        bestMatch = opening;
      }
    }
  }
  return bestMatch;
}

String _pgnToFen(String pgn) {
  final game = PgnGame.parsePgn(pgn);
  var position = PgnGame.startingPosition(game.headers);

  for (final node in game.moves.mainline()) {
    final move = position.parseSan(node.san);
    if (move == null) break;
    position = position.play(move);
  }
  return position.fen;
}

Future<void> _runDartCommand(List<String> args) async {
  final result = await Process.run('dart', args);
  if (result.exitCode != 0) {
    stderr.writeln(
      '⚠ Command failed: dart ${args.join(' ')}\n${result.stdout}\n${result.stderr}',
    );
  } else {
    stdout.writeln('✅ Command succeeded: dart ${args.join(' ')}');
  }
}

Iterable<String> _splitPgnIntoGames(String pgnFileContents) sync* {
  final normalized = pgnFileContents.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return;

  // Lichess studies export multiple games; each starts with [Event "..."]
  final parts = normalized.split(RegExp(r'(?=\[Event\s+")'));
  for (final part in parts) {
    final chunk = part.trim();
    if (chunk.isEmpty) continue;
    if (!chunk.startsWith('[Event')) continue;
    yield chunk;
  }
}

String _sanMovesToNumberedPgn(List<String> moves) {
  final buf = StringBuffer();
  var moveNumber = 1;
  for (var i = 0; i < moves.length; i++) {
    if (i.isEven) {
      if (buf.isNotEmpty) buf.write(' ');
      buf.write('$moveNumber.${moves[i]}');
    } else {
      buf.write(' ${moves[i]}');
      moveNumber++;
    }
  }
  return buf.toString();
}

String _buildMetadata(Map<String, String> headers) {
  final study = headers['StudyName'];
  final chapter = headers['ChapterName'];
  final eco = headers['ECO'];
  final annotator = headers['Annotator'];

  final parts = <String>[
    if (study != null && study.trim().isNotEmpty) study.trim(),
    if (chapter != null && chapter.trim().isNotEmpty) chapter.trim(),
    if (eco != null && eco.trim().isNotEmpty) eco.trim(),
    if (annotator != null && annotator.trim().isNotEmpty) annotator.trim(),
  ];

  return parts.isEmpty ? '' : parts.join(' - ');
}

String _encode(String value) {
  // jsonEncode produces a quoted string literal safe for Dart source.
  // Example: hello -> "hello", Alapin’s -> "Alapin\u2019s"
  return jsonEncode(value);
}
