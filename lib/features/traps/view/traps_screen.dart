import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router.dart';
import '../../../utils.dart';

class TrapsScreen extends ConsumerWidget {
  const TrapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trapsGroups = ref.watch(trapsGroupSourceProvider);
    return Column(
      children: [
        Text(context.phrase.chessTraps),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,

            children: [
              for (final MapEntry(:key, :value) in trapsGroups.entries)
                Card(
                  child: InkWell(
                    onTap: () {
                      TrapDetailRoute(index: value[0]).push(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth * 0.8;
                            return StaticChessboard(
                              size: width,
                              orientation: .white,
                              fen: Position.initialPosition(.chess).fen,
                            );
                          },
                        ),
                        Center(
                          child: Text(
                            key,
                            style: context.textTheme.bodySmall!.copyWith(
                              fontWeight: .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
