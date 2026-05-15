import 'dart:async';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chess_traps/services/chess_engine_service.dart';
import 'package:chess_traps/utils.dart';

part 'play_screen.g.dart';

enum PlayerColor { white, black, random }

class PlayGameState {
  final Position chess;
  final PlayerColor userColor;
  final int elo;
  final bool isPlaying;
  final bool engineThinking;
  final String? gameResult; // null = ongoing, 'win', 'loss', 'draw'

  PlayGameState({
    required this.chess,
    required this.userColor,
    required this.elo,
    required this.isPlaying,
    required this.engineThinking,
    this.gameResult,
  });

  PlayGameState copyWith({
    Position? chess,
    PlayerColor? userColor,
    int? elo,
    bool? isPlaying,
    bool? engineThinking,
    String? gameResult,
    bool clearResult = false,
  }) {
    return PlayGameState(
      chess: chess ?? this.chess,
      userColor: userColor ?? this.userColor,
      elo: elo ?? this.elo,
      isPlaying: isPlaying ?? this.isPlaying,
      engineThinking: engineThinking ?? this.engineThinking,
      gameResult: clearResult ? null : (gameResult ?? this.gameResult),
    );
  }
}

@riverpod
class PlayGameNotifier extends _$PlayGameNotifier {
  final ChessEngineService _engineService = ChessEngineService();
  StreamSubscription<String>? _engineSubscription;

  @override
  PlayGameState build() {
    ref.onDispose(() {
      _engineSubscription?.cancel();
      _engineService.dispose();
    });

    _engineService.init().then((_) {
      _engineSubscription = _engineService.engineOutput.listen((line) {
        if (line.startsWith('bestmove')) {
          final parts = line.split(' ');
          if (parts.length > 1) {
            final moveStr = parts[1];
            if (moveStr != '(none)') {
              _onEngineMove(moveStr);
            }
          }
        }
      });
    });

    return PlayGameState(
      chess: Chess.initial,
      userColor: PlayerColor.white,
      elo: 1500,
      isPlaying: false,
      engineThinking: false,
    );
  }

  void startGame(PlayerColor color, int elo) {
    final actualColor = color == PlayerColor.random
        ? (DateTime.now().millisecondsSinceEpoch % 2 == 0
              ? PlayerColor.white
              : PlayerColor.black)
        : color;

    state = state.copyWith(
      chess: Chess.initial,
      userColor: actualColor,
      elo: elo,
      isPlaying: true,
      engineThinking: false,
      clearResult: true,
    );

    // If player chose black, engine moves first as white
    if (actualColor == PlayerColor.black) {
      state = state.copyWith(engineThinking: true);
      _engineService.playMove(Chess.initial.fen, elo);
    }
  }

  void onUserMove(Move move) {
    if (!state.isPlaying || state.engineThinking) return;

    final newChess = state.chess.play(move);
    state = state.copyWith(chess: newChess);

    if (newChess.isGameOver) {
      final result = _getResult(newChess, isEngineMove: false);
      state = state.copyWith(isPlaying: false, gameResult: result);
      return;
    }

    state = state.copyWith(engineThinking: true);
    _engineService.playMove(newChess.fen, state.elo);
  }

  void _onEngineMove(String moveUci) {
    if (!state.isPlaying) return;

    final move = NormalMove.fromUci(moveUci);
    final newChess = state.chess.play(move);

    state = state.copyWith(chess: newChess, engineThinking: false);

    if (newChess.isGameOver) {
      final result = _getResult(newChess, isEngineMove: true);
      state = state.copyWith(isPlaying: false, gameResult: result);
    }
  }

  String _getResult(Position pos, {required bool isEngineMove}) {
    if (pos.isCheckmate) {
      return isEngineMove ? 'loss' : 'win';
    }
    return 'draw'; // stalemate, 50-move, etc.
  }

  void stopGame() {
    state = state.copyWith(isPlaying: false, engineThinking: false);
    _engineService.stopAnalysis();
  }
}

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  int _currentElo = 1500;
  PlayerColor _currentColor = PlayerColor.white;
  NormalMove? _promotionMove;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(playGameProvider);
    final notifier = ref.read(playGameProvider.notifier);

    // Show result dialog when game ends
    ref.listen<PlayGameState>(playGameProvider, (prev, next) {
      if (prev?.gameResult == null && next.gameResult != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResultDialog(context, next.gameResult!, notifier);
        });
      }
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          context.phrase.play,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: gameState.isPlaying
          ? _buildGameArea(context, gameState, notifier)
          : _buildSetupArea(context, gameState, notifier),
    );
  }

  void _showResultDialog(
    BuildContext context,
    String result,
    PlayGameNotifier notifier,
  ) {
    final (title, subtitle, icon) = switch (result) {
      'win' => ('You Won! 🎉', 'Congratulations!', Icons.emoji_events_rounded),
      'loss' => (
          'Stockfish Won',
          'Better luck next time!',
          Icons.psychology_rounded,
        ),
      _ => ('Draw', 'Well played!', Icons.handshake_rounded),
    };

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, size: 48, color: context.colors.primary),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(subtitle, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.startGame(_currentColor, _currentElo);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupArea(
    BuildContext context,
    PlayGameState state,
    PlayGameNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Opponent Strength',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Elo: $_currentElo',
            style: context.textTheme.headlineMedium?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _currentElo.toDouble(),
            min: 800,
            max: 3200,
            divisions: 24,
            label: _currentElo.toString(),
            onChanged: (val) => setState(() => _currentElo = val.toInt()),
          ),
          const SizedBox(height: 48),
          Text(
            'Play as',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SegmentedButton<PlayerColor>(
            segments: const [
              ButtonSegment(
                value: PlayerColor.white,
                label: Text('White'),
                icon: Icon(Icons.circle_outlined),
              ),
              ButtonSegment(
                value: PlayerColor.random,
                label: Text('Random'),
                icon: Icon(Icons.casino_outlined),
              ),
              ButtonSegment(
                value: PlayerColor.black,
                label: Text('Black'),
                icon: Icon(Icons.circle),
              ),
            ],
            selected: {_currentColor},
            onSelectionChanged: (set) =>
                setState(() => _currentColor = set.first),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => notifier.startGame(_currentColor, _currentElo),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Start Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    PlayGameState state,
    PlayGameNotifier notifier,
  ) {
    final isWhite = state.userColor == PlayerColor.white;
    final boardOrientation = isWhite ? Side.white : Side.black;
    final boardSize = MediaQuery.of(context).size.width;

    // Determine if it's the user's turn
    final isUserTurn = state.isPlaying &&
        !state.engineThinking &&
        ((state.chess.turn == Side.white && isWhite) ||
            (state.chess.turn == Side.black && !isWhite));

    return Column(
      children: [
        const SizedBox(height: 16),
        // Engine indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isWhite ? Colors.black87 : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.outline),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Stockfish (${state.elo})',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (state.engineThinking)
                Row(
                  children: [
                    Text(
                      'Thinking...',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Chessboard
        AspectRatio(
          aspectRatio: 1,
          child: isUserTurn
              ? cg.Chessboard(
                  size: boardSize,
                  orientation: boardOrientation,
                  fen: state.chess.fen,
                  game: cg.GameData(
                    playerSide: isWhite
                        ? cg.PlayerSide.white
                        : cg.PlayerSide.black,
                    sideToMove: state.chess.turn,
                    validMoves: state.chess.legalMoves.asIMapSquareISet,
                    promotionMove: _promotionMove,
                    onMove: (move, {bool? viaDragAndDrop}) =>
                        notifier.onUserMove(move),
                    isCheck: state.chess.isCheck,
                    onPromotionSelection: (role) {
                      if (_promotionMove != null && role != null) {
                        final promoted = NormalMove(
                          from: _promotionMove!.from,
                          to: _promotionMove!.to,
                          promotion: role,
                        );
                        notifier.onUserMove(promoted);
                        setState(() => _promotionMove = null);
                      }
                    },
                  ),
                )
              : cg.Chessboard.fixed(
                  size: boardSize,
                  orientation: boardOrientation,
                  fen: state.chess.fen,
                  lastMove: null,
                ),
        ),
        const SizedBox(height: 12),
        // Player indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isWhite ? Colors.white : Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.outline),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'You',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isUserTurn)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your turn',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: OutlinedButton.icon(
            onPressed: notifier.stopGame,
            icon: const Icon(Icons.flag_rounded),
            label: const Text('Resign'),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.error,
              side: BorderSide(color: context.colors.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
