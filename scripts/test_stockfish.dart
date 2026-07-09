import 'dart:io';
import 'package:multistockfish/multistockfish.dart';
void main() async {
  final engine = Stockfish.instance;
  engine.stdout.listen((String event) {
    stdout.writeln(event);
  });
  await engine.start();
  engine.stdin = 'isready';
  await Future<void>.delayed(const Duration(seconds: 2));
  await engine.quit();
}
