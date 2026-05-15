import 'package:stockfish/stockfish.dart';

void main() async {
  final engine = Stockfish();
  engine.stdout.listen((event) {
    stdout.writeln(event);
  });
  engine.stdin = 'isready';
  await Future<void>.delayed(const Duration(seconds: 2));
  engine.dispose();
}
