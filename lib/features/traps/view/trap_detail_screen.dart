import 'package:chess_traps/providers/favorites_provider.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils.dart';

import '../../../providers/trap_game_provider.dart';

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
    final trap = ref.watch(trapGameProvider(widget.trapIndex));
    final maxMoves = trap.moves.length;
    final position = pgnToPositionIndex(trap.cleanMoves, currentMoveIndex);
    final favorite = ref.watch(favoritesProvider.notifier);
    final isFavorite = ref.watch(favoritesProvider).contains(trap.id);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.phrase.chessTraps),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: cg.Chessboard.fixed(
                  size: MediaQuery.of(context).size.width - 32,
                  orientation: Side.white,
                  fen: position.fen,
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
                  Row(
                    children: [
                      Text(
                        trap.trapName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          favorite.toggleFavorite(trap.id);
                        },
                        icon: isFavorite
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : const Icon(Icons.favorite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        trap.cleanMoves,
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
