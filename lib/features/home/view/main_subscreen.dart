import 'package:chess_traps/data/fens.dart' as fens;
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
        Column(children: [Text(context.phrase.recentTraps)]),
      ],
    );
  }
}
