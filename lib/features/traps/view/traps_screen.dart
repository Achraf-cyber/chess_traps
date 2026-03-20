import 'package:chess_traps/providers/traps_group_provider.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../router.dart';
import '../../../utils.dart';

class TrapsScreen extends ConsumerStatefulWidget {
  const TrapsScreen({super.key});

  @override
  ConsumerState<TrapsScreen> createState() => _TrapsScreenState();
}

class _TrapsScreenState extends ConsumerState<TrapsScreen> {
  final controler = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controler.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      TrapGroupRoute(name: key).push<void>(context);
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
