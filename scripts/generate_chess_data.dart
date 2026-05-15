import 'dart:convert';
import 'dart:io';

import 'package:dartchess/dartchess.dart' hide File;
import 'package:chess_traps/data/openings.dart';

void main() async {
  final trapsDir = Directory('data/chess traps');
  if (!trapsDir.existsSync()) {
    throw Exception('Folder not found: ${trapsDir.path}');
  }

  final pgnFiles = await trapsDir
      .list()
      .where((e) => e is File && e.path.toLowerCase().endsWith('.pgn'))
      .cast<File>()
      .toList();

  if (pgnFiles.isEmpty) {
    throw Exception('No PGN files found in: ${trapsDir.path}');
  }

  final games = <PgnGame>[];
  for (final f in pgnFiles) {
    final text = await f.readAsString();
    for (final chunk in _splitPgnIntoGames(text)) {
      try {
        games.add(PgnGame.parsePgn(chunk));
      } catch (e) {
        stdout.writeln('Failed parsing PGN game in ${f.path}: $e');
      }
    }
  }

  stdout.writeln('Loaded ${games.length} games. Starting Stockfish...');

  final stockfishProcess = await Process.start('stockfish.exe', []);
  
  int currentScore = 0;
  bool isComputing = false;

  stockfishProcess.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((output) {
    if (output.startsWith('info depth') && output.contains('score cp ')) {
      final parts = output.split('score cp ');
      if (parts.length > 1) {
        final scoreStr = parts[1].split(' ').first;
        currentScore = int.tryParse(scoreStr) ?? 0;
      }
    } else if (output.startsWith('info depth') && output.contains('score mate ')) {
      final parts = output.split('score mate ');
      if (parts.length > 1) {
        final scoreStr = parts[1].split(' ').first;
        currentScore = (int.tryParse(scoreStr) ?? 0) > 0 ? 10000 : -10000;
      }
    }
    if (output.startsWith('bestmove')) {
      isComputing = false;
    }
  });

  Future<Side> determineTargetSide(String fen) async {
    currentScore = 0;
    isComputing = true;
    
    stockfishProcess.stdin.writeln('position fen $fen');
    stockfishProcess.stdin.writeln('go movetime 100');
    
    while (isComputing) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    
    final parts = fen.split(' ');
    final sideToMove = parts.length > 1 ? parts[1] : 'w';
    
    if (sideToMove == 'w') {
      return currentScore > 0 ? Side.white : Side.black;
    } else {
      return currentScore > 0 ? Side.black : Side.white;
    }
  }

  final content = StringBuffer();
  content.writeln(r'// GENERATED FILE DO NOT EDIT');
  content.writeln(r'// ignore_for_file: prefer_single_quotes');
  content.writeln("import '../../data/chess_trap.dart';");
  content.writeln("import 'package:dartchess/dartchess.dart';");
  content.writeln('const List<ChessTrap> chessTraps = [\n');
  var id = 0;
  final uniques = <String>{};
  final groups = <String, List<int>>{};
  
  for (int i = 0; i < games.length; i++) {
    final game = games[i];
    final sanMoves = game.moves.mainline().map((n) => n.san).toList();
    if (sanMoves.isEmpty) continue;

    final cleanMoves = _sanMovesToNumberedPgn(sanMoves);
    final uniqueKey = sanMoves.join(' ');
    if (uniques.contains(uniqueKey)) {
      continue;
    }
    uniques.add(uniqueKey);

    final fen = _pgnToFen(cleanMoves);
    stdout.writeln('Evaluating [${i + 1}/${games.length}] FEN: $fen');
    final targetSide = await determineTargetSide(fen);

    final matchedOpening = _findOpening(sanMoves);
    final opening = matchedOpening?.name ?? (game.headers['Opening'] ?? '');
    final openingId = matchedOpening?.id ?? '';

    groups.putIfAbsent(opening, () => []).add(id);

    String cleanName(String name) {
      if (name.isEmpty) return name;
      // Remove leading digits, dots, dashes, and spaces
      var cleaned = name.replaceAll(RegExp(r'^[\d\.\-\s]+'), '').trim();
      // Basic capitalization if it's not already
      if (cleaned.isNotEmpty) {
        cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
      }
      return cleaned;
    }

    var trapName = game.headers['ChapterName'] ?? game.headers['Event'] ?? opening;
    var trapNameFr = game.headers['Event_fr'] ?? '';
    var trapNameEs = game.headers['Event_es'] ?? '';
    var trapNameAr = game.headers['Event_ar'] ?? '';

    trapName = cleanName(trapName);
    trapNameFr = cleanName(trapNameFr);
    trapNameEs = cleanName(trapNameEs);
    trapNameAr = cleanName(trapNameAr);

    final metadata = _buildMetadata(game.headers);

    final moveList = sanMoves.map(_encode).join(',');

    content.writeln('ChessTrap(');
    content.writeln('  id: ${id++},');
    content.writeln('  cleanMoves: ${_encode(cleanMoves)},');
    content.writeln('  metadata: ${_encode(metadata)},');
    content.writeln('  opening: ${_encode(opening)},');
    content.writeln('  openingId: ${_encode(openingId)},');
    content.writeln('  trapName: ${_encode(trapName)},');
    if (trapNameFr.isNotEmpty) content.writeln('  trapNameFr: ${_encode(trapNameFr)},');
    if (trapNameEs.isNotEmpty) content.writeln('  trapNameEs: ${_encode(trapNameEs)},');
    if (trapNameAr.isNotEmpty) content.writeln('  trapNameAr: ${_encode(trapNameAr)},');
    content.writeln('  commentedMoves: ${_encode(cleanMoves)},');
    content.writeln('  moves: [$moveList],');
    content.writeln('  fen: ${_encode(fen)},');
    content.writeln('  targetSide: ${targetSide == Side.white ? "Side.white" : "Side.black"},');
    content.writeln('),\n');
  }
  content.writeln('];');

  stockfishProcess.kill();

  const outputFolder = 'lib/generated/chess';
  await Directory(outputFolder).create(recursive: true);
  final baseFile = File('$outputFolder/base_chess_traps.dart');
  await baseFile.writeAsString(content.toString());
  stdout.writeln('Running dart format...');
  await Process.run('dart', ['format', baseFile.path]);

  final groupsFile = File('lib/generated/chess_groups.dart');
  final groupsContent = StringBuffer();
  groupsContent.writeln('const trapsGroup = {');
  final sortedGroupNames = groups.keys.toList()..sort();
  for (final name in sortedGroupNames) {
    groupsContent.writeln('${jsonEncode(name)} : ${groups[name]},');
  }
  groupsContent.writeln('};');
  await groupsFile.writeAsString(groupsContent.toString());
  await Process.run('dart', ['format', groupsFile.path]);

  stdout.writeln('Generating tries...');
  await Process.run('dart', ['run', 'scripts/generate_chess_tries.dart']);
  
  stdout.writeln('Done!');
  exit(0);
}

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

Iterable<String> _splitPgnIntoGames(String pgnFileContents) sync* {
  final normalized = pgnFileContents.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return;
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
  return jsonEncode(value);
}
