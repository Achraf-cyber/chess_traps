import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import '../providers/trap_game_provider.dart';
import '../providers/traps_provider.dart';

class TrapDetailScreen extends ConsumerStatefulWidget {
  final int trapIndex;
  
  const TrapDetailScreen({super.key, required this.trapIndex});

  @override
  ConsumerState<TrapDetailScreen> createState() => _TrapDetailScreenState();
}

class _TrapDetailScreenState extends ConsumerState<TrapDetailScreen> {
  int currentMoveIndex = 0;

  @override
  Widget build(BuildContext context) {
    final trapGameAsync = ref.watch(trapGameProvider(widget.trapIndex));
    final trapsAsync = ref.watch(trapsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Trap Details'),
      ),
      body: trapGameAsync.when(
        data: (game) {
          final trap = trapsAsync.value?[widget.trapIndex];
          
          // Get FEN up to the current move index
          var fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
          if (currentMoveIndex > 0) {
            // Replay the game to calculate FEN
            Position replayGame = Chess.initial;
            final pgnData = trap?.cleanMoves ?? '';
            final movesParams = pgnData.replaceAll(RegExp(r'\d+\.'), '').trim().split(RegExp(r'\s+'));
            
            for (int i = 0; i < currentMoveIndex && i < movesParams.length; i++) {
              final moveStr = movesParams[i];
              if (moveStr.isEmpty) continue;
              try {
                final move = replayGame.parseSan(moveStr);
                if (move != null) {
                  replayGame = replayGame.playUnchecked(move);
                }
              } catch (e) {
                // Ignore parse errors
              }
            }
            fen = replayGame.fen;
          }

          final maxMoves = trap?.cleanMoves.replaceAll(RegExp(r'\d+\.'), '').trim().split(RegExp(r'\s+')).length ?? 0;

          return Column(
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
                      Text(trap?.trapName ?? 'Loading...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(trap?.commentedMoves ?? '', style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: currentMoveIndex > 0 ? () => setState(() => currentMoveIndex = 0) : null, 
                            icon: const Icon(Icons.fast_rewind)
                          ),
                          IconButton(
                            onPressed: currentMoveIndex > 0 ? () => setState(() => currentMoveIndex--) : null, 
                            icon: const Icon(Icons.arrow_back_ios)
                          ),
                          IconButton(
                            onPressed: currentMoveIndex < maxMoves ? () => setState(() => currentMoveIndex++) : null, 
                            icon: const Icon(Icons.arrow_forward_ios)
                          ),
                          IconButton(
                            onPressed: currentMoveIndex < maxMoves ? () => setState(() => currentMoveIndex = maxMoves) : null, 
                            icon: const Icon(Icons.fast_forward)
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error parsing PGN: $err')),
      ),
    );
  }
}
