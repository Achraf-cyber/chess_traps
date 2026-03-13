import 'package:chess_traps/data/fens.dart' as fens;
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

class TrapWithName extends StatelessWidget {
  const TrapWithName({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StaticChessboard(
          size: 48,
          orientation: .white,
          fen: fens.initialBoardFen,
        ),
        Text(context.phrase.trapOfTheDay),
      ],
    );
  }
}
