import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils.dart';

import '../../../data/chess_trap.dart';
import '../../../providers/trap_game_provider.dart';
import '../../../providers/traps_provider.dart';

class TrapDetailScreen extends ConsumerStatefulWidget {
  const TrapDetailScreen({super.key, required this.trapIndex});
  final int trapIndex;

  @override
  ConsumerState<TrapDetailScreen> createState() => _TrapDetailScreenState();
}

class _TrapDetailScreenState extends ConsumerState<TrapDetailScreen> {
  int currentMoveIndex = 0;

  @override
  Widget build(BuildContext context) {
    final trapGame = ref.watch(TrapGameProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.phrase.chessTraps),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: cg.Chessboard.fixed(
                    size: MediaQuery.of(context).size.width - 32,
                    orientation: Side.white,
                    fen: fen,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ?.trapName ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        trap?.commentedMoves ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: currentMoveIndex > 0
                            ? () => setState(() => currentMoveIndex = 0)
                            : null,
                        icon: const Icon(Icons.fast_rewind),
                      ),
                      IconButton(
                        onPressed: currentMoveIndex > 0
                            ? () => setState(() => currentMoveIndex--)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      IconButton(
                        onPressed: currentMoveIndex < maxMoves
                            ? () => setState(() => currentMoveIndex++)
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios),
                      ),
                      IconButton(
                        onPressed: currentMoveIndex < maxMoves
                            ? () => setState(() => currentMoveIndex = maxMoves)
                            : null,
                        icon: const Icon(Icons.fast_forward),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
