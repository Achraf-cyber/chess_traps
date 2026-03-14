import 'package:chess_traps/data/fens.dart';
import 'package:chess_traps/generated/assets.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/widgets/trap_with_name.dart';
import 'package:chessground/chessground.dart';
import 'package:flutter/material.dart';

class MainSubscreen extends StatelessWidget {
  const MainSubscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAssets.imagesHomeImagePng),
        Row(children: [TrapWithName(), TrapWithName()]),
        Column(
          children: [
            Text(context.phrase.recentTraps),
            Row(
              children: [
                Chessboard.fixed(
                  size: 200,
                  orientation: .white,
                  fen: initialBoardFen,
                ),
                Text(context.phrase.exampleTrap),
                Text(context.phrase.lastTimeChecked),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
