import 'dart:io';
import 'dart:convert';

import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/data/chess_move_node.dart';

const String outputFolder = 'lib/generated/chess';
const String moveTrieFile = 'prebuilt_move_trie.dart';
const String nameIndexFile = 'prebuilt_name_index.dart';

void main() async {
  String normalizeName(String s) => s.toLowerCase();

  // --- Helper to build move trie ---
  ChessMoveNode insertMoves(
    List<String> moves,
    int trapId, [
    ChessMoveNode? root,
  ]) {
    root ??= const ChessMoveNode(move: '', children: {}, values: []);
    var node = root;

    for (final move in moves) {
      node.children[move] ??= ChessMoveNode(
        move: move,
        children: {},
        values: [],
      );
      node = node.children[move]!;
    }

    // Attach trapId at the leaf node
    node.values.add(trapId);

    return root;
  }

  // --- Build move trie ---
  final ChessMoveNode moveTrieRoot = ChessMoveNode(
    move: '',
    children: <String, ChessMoveNode>{},
    values: <int>[],
  );
  for (final trap in chessTraps) {
    insertMoves(trap.moves, trap.id, moveTrieRoot);
  }

  // --- Build name index ---
  final Map<String, List<int>> nameIndex = {};
  for (final trap in chessTraps) {
    for (final key in [
      normalizeName(trap.opening),
      normalizeName(trap.trapName),
    ]) {
      nameIndex.putIfAbsent(key, () => <int>[]).add(trap.id);
    }
  }

  // --- Serialize ChessMoveNode to strictly typed Dart code ---
  String serializeTrieNode(ChessMoveNode node) {
    final childrenCode = node.children.entries
        .map((e) => "${jsonEncode(e.key)}: ${serializeTrieNode(e.value)}")
        .join(',\n');

    // Adding explicit <int> to fix strict-inference
    final valuesCode = node.values.isEmpty
        ? '<int>[]'
        : '<int>[${node.values.join(', ')}]';

    // Adding explicit <String, ChessMoveNode> to fix strict-inference
    return 'ChessMoveNode(move: ${jsonEncode(node.move)}, children: <String, ChessMoveNode>{$childrenCode}, values: $valuesCode)';
  }

  // --- Serialize Name Index to strictly typed Dart map ---
  String serializeNameIndex(Map<String, List<int>> index) {
    final entries = index.entries
        .map((e) {
          final key = jsonEncode(e.key);
          final vals = e.value.join(', ');
          // Adding explicit <int> array typing
          return '$key: <int>[$vals]';
        })
        .join(',\n');

    // Wrapping in an explicitly typed Map
    return '<String, List<int>>{\n$entries\n}';
  }

  // --- Generate move trie file ---
  await Directory(outputFolder).create(recursive: true);
  final moveFile = File('$outputFolder/$moveTrieFile');
  final moveContent = StringBuffer();
  moveContent.writeln('// GENERATED FILE - DO NOT EDIT');
  moveContent.writeln('// Prebuilt ChessMoveNode trie for fast move search\n');

  // NOTE: Removed `import 'base_chess_traps.dart';` because it was unused and violates strict lints
  moveContent.writeln("import '../../data/chess_move_node.dart';\n");

  // Generates a fully cascading compile-time constant tree
  moveContent.writeln(
    'const ChessMoveNode moveTrie = ${serializeTrieNode(moveTrieRoot)};',
  );
  await moveFile.writeAsString(moveContent.toString());

  // --- Generate name index file ---
  final nameFile = File('$outputFolder/$nameIndexFile');
  final nameContent = StringBuffer();
  nameContent.writeln('// GENERATED FILE - DO NOT EDIT');
  nameContent.writeln('// Flat name index for openings/trap names\n');

  // Generates a fully cascading compile-time constant map
  nameContent.writeln(
    'const Map<String, List<int>> nameIndex = ${serializeNameIndex(nameIndex)};',
  );
  await nameFile.writeAsString(nameContent.toString());

  // --- Utility to run dart commands ---
  Future<void> runDartCommand(List<String> args) async {
    final result = await Process.run('dart', args);
    if (result.exitCode != 0) {
      stderr.writeln(
        '⚠ Command failed: dart ${args.join(' ')}\n${result.stdout}\n${result.stderr}',
      );
    } else {
      stdout.writeln('✅ Command succeeded: dart ${args.join(' ')}');
    }
  }

  // --- Apply formatting, fix, and analysis for both files ---
  for (final filePath in [moveFile.path, nameFile.path]) {
    await runDartCommand(['format', filePath]);
    await runDartCommand(['fix', '--apply', filePath]);
    await runDartCommand([
      'analyze',
      '--fatal-infos',
      '--fatal-warnings',
      filePath,
    ]);
  }

  stdout.writeln('✅ Prebuilt move trie and name index generation complete!');
}
