// ignore_for_file: avoid_print
import 'package:dartchess/dartchess.dart';

void main() {
  final pos = Chess.fromSetup(Setup.standard);
  print(pos.isCheckmate);
  print(pos.isStalemate);
}
