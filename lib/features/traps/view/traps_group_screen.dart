import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chess_traps/router.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils.dart';

class TrapsGroupScreen extends ConsumerWidget {
  const TrapsGroupScreen({super.key, required this.groupName});
  final String groupName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elements = ref.watch(trapsOfGroupProvider(groupName));
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                for (final trap in elements)
                  Card(
                    child: InkWell(
                      onTap: () {
                        TrapDetailRoute(index: trap.id).push<void>(context);
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
                              groupName,
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
      ),
    );
  }
}
