import 'package:stockfish/stockfish.dart';

void main() async {
  final engine = Stockfish();
  engine.stdout.listen((event) {
    print(event);
  });
  engine.stdin = 'isready';
  await Future.delayed(Duration(seconds: 2));
  engine.dispose();
}
