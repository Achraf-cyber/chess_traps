import 'dart:convert';
import 'dart:io';

import 'package:chess_traps/generated/chess/base_chess_traps.dart';

String green = '\x1B[31m';
String reset = '\x1B[0m';

const outputFileName = r'../lib/generated/chess_groups.dart';

void main() {
  final groups = <String, List<int>>{};
  for (final chessGame in chessTraps) {
    groups[chessGame.opening] ??= [];
    groups[chessGame.opening]!.add(chessGame.id);
  }
  final content = StringBuffer();
  // content.writeln("import 'package:chess_traps/data/chess_trap.dart';");
  content.writeln("const trapsGroup = {");
  for (final MapEntry(key: key, value: value) in groups.entries) {
    content.writeln("${jsonEncode(key)} : $value,");
  }
  content.writeln("};");
  final outputFile = File(outputFileName);
  outputFile.writeAsString(content.toString());
}
