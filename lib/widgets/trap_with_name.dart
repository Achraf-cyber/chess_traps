import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

import '../data/fens.dart' as fens;
import '../utils.dart';

class TrapWithName extends StatelessWidget {
  const TrapWithName({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticChessboard(
          size: 48,
          orientation: .white,
          fen: fens.initialBoardFen,
        ),
        Text(context.phrase.trapOfTheDay),
      ],
    );
  }
}
