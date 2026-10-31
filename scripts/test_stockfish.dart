import 'dart:io';
import 'package:multistockfish/multistockfish.dart';
void main() async {
  final engine = await Stockfish.create(onStdout: stdout.writeln);
  engine.stdin = 'isready';
  await Future<void>.delayed(const Duration(seconds: 2));
  await engine.dispose();
}
