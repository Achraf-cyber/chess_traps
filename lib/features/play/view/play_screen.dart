import 'dart:async';
import 'dart:math';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/services/audio_haptic_service.dart';
import 'package:chess_traps/widgets/evaluation_bar.dart';
import 'package:chess_traps/providers/engine_analysis_provider.dart';
import 'package:chess_traps/providers/play_history_provider.dart';

part 'play_screen.g.dart';

enum PlayerColor { white, black, random }

class PlayGameState {
  PlayGameState({
    required this.chess,
    required this.userColor,
    required this.elo,
    required this.isPlaying,
    required this.engineThinking,
    required this.evaluation,
    required this.avgEngineDelaySecs,
    this.gameResult,
  });

  final Position chess;
  final PlayerColor userColor;
  final int elo;
  final bool isPlaying;
  final bool engineThinking;
  final double evaluation; // Centipawns, positive for white
  final String? gameResult; // null = ongoing, 'win', 'loss', 'draw'
  /// Average engine response time in seconds (power-law distributed)
  final double avgEngineDelaySecs;

  PlayGameState copyWith({
    Position? chess,
    PlayerColor? userColor,
    int? elo,
    bool? isPlaying,
    bool? engineThinking,
    double? evaluation,
    String? gameResult,
    bool clearResult = false,
    double? avgEngineDelaySecs,
  }) {
    return PlayGameState(
      chess: chess ?? this.chess,
      userColor: userColor ?? this.userColor,
      elo: elo ?? this.elo,
      isPlaying: isPlaying ?? this.isPlaying,
      engineThinking: engineThinking ?? this.engineThinking,
      evaluation: evaluation ?? this.evaluation,
      gameResult: clearResult ? null : (gameResult ?? this.gameResult),
      avgEngineDelaySecs: avgEngineDelaySecs ?? this.avgEngineDelaySecs,
    );
  }
}

@riverpod
class PlayGameNotifier extends _$PlayGameNotifier {
  final _hapticService = AudioHapticService();
  StreamSubscription<String>? _sub;
  Timer? _throttleTimer;
  double? _pendingEval;

  @override
  PlayGameState build() {
    final engineService = ref.watch(chessEngineProvider);

    // Initial subscription
    _sub?.cancel();
    _sub = engineService.engineOutput.listen(_onEngineLine);

    ref.onDispose(() {
      _sub?.cancel();
      _throttleTimer?.cancel();
    });

    return PlayGameState(
      chess: Chess.initial,
      userColor: PlayerColor.white,
      elo: 1500,
      isPlaying: false,
      engineThinking: false,
      evaluation: 0,
      avgEngineDelaySecs: 1.0,
    );
  }

  void _onEngineLine(String line) {
    if (line.startsWith('bestmove')) {
      final parts = line.split(' ');
      if (parts.length > 1) {
        final moveStr = parts[1];
        if (moveStr != '(none)') {
          _onEngineMove(moveStr);
        }
      }
    } else if (line.contains('score cp')) {
      _parseEvaluation(line);
    } else if (line.contains('score mate')) {
      _parseMate(line);
    }
  }

  void _parseEvaluation(String line) {
    final parts = line.split(' ');
    final index = parts.indexOf('cp');
    if (index != -1 && index + 1 < parts.length) {
      final cp = double.tryParse(parts[index + 1]);
      if (cp != null) {
        // Adjust score for side to move
        final sign = state.chess.turn == Side.white ? 1.0 : -1.0;
        final eval = cp * sign;
        _throttleUpdate(eval);
      }
    }
  }

  void _parseMate(String line) {
    final parts = line.split(' ');
    final index = parts.indexOf('mate');
    if (index != -1 && index + 1 < parts.length) {
      final mate = int.tryParse(parts[index + 1]);
      if (mate != null) {
        final sign = state.chess.turn == Side.white ? 1.0 : -1.0;
        final eval = mate > 0 ? 999.0 * sign : -999.0 * sign;
        _throttleUpdate(eval);
      }
    }
  }

  void _throttleUpdate(double eval) {
    _pendingEval = eval;
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      _throttleTimer = Timer(const Duration(milliseconds: 200), () {
        if (_pendingEval != null) {
          state = state.copyWith(evaluation: _pendingEval!);
          _pendingEval = null;
        }
      });
    }
  }

  Duration _powerLawDelay(double avgSecs) {
    const alpha = 2.5;
    final xMin = avgSecs * (alpha - 1) / alpha;
    final u = Random().nextDouble().clamp(0.001, 1.0);
    final raw = xMin / pow(u, 1 / (alpha - 1));
    final capped = raw.clamp(0.1, avgSecs * 3);
    return Duration(milliseconds: (capped * 1000).round());
  }

  void startGame(PlayerColor color, int elo, {double avgDelaySecs = 1.0}) {
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
      evaluation: 0,
      clearResult: true,
      avgEngineDelaySecs: avgDelaySecs,
    );

    _hapticService.playMove();

    if (actualColor == PlayerColor.black) {
      state = state.copyWith(engineThinking: true);
      ref.read(chessEngineProvider).playMove(Chess.initial.fen, elo);
    }
  }

  void onUserMove(Move move) {
    if (!state.isPlaying || state.engineThinking) return;

    final newChess = state.chess.play(move);
    state = state.copyWith(chess: newChess);

    if (newChess.isCheck) {
      _hapticService.playCheck();
    } else {
      _hapticService.playMove();
    }

    if (newChess.isGameOver) {
      final result = _getResult(newChess, isEngineMove: false);
      _recordResult(result);
      state = state.copyWith(isPlaying: false, gameResult: result);
      return;
    }

    state = state.copyWith(engineThinking: true);
    ref.read(chessEngineProvider).playMove(newChess.fen, state.elo);
  }

  void _onEngineMove(String moveUci) {
    if (!state.isPlaying) return;

    final delay = _powerLawDelay(state.avgEngineDelaySecs);
    Future<void>.delayed(delay, () {
      if (!state.isPlaying) return;

      final move = NormalMove.fromUci(moveUci);
      final newChess = state.chess.play(move);

      state = state.copyWith(chess: newChess, engineThinking: false);

      if (newChess.isCheck) {
        _hapticService.playCheck();
      } else {
        _hapticService.playMove();
      }

      if (newChess.isGameOver) {
        final result = _getResult(newChess, isEngineMove: true);
        _recordResult(result);
        state = state.copyWith(isPlaying: false, gameResult: result);
      }
    });
  }

  String _getResult(Position pos, {required bool isEngineMove}) {
    if (pos.isCheckmate) {
      return isEngineMove ? 'loss' : 'win';
    }
    return 'draw'; // stalemate, 50-move, etc.
  }

  void _recordResult(String result) {
    switch (result) {
      case 'win':
        ref.read(playHistoryProvider.notifier).addWin();
      case 'loss':
        ref.read(playHistoryProvider.notifier).addLoss();
      case 'draw':
        ref.read(playHistoryProvider.notifier).addDraw();
    }
  }

  void stopGame() {
    if (state.gameResult == null) {
      _recordResult('loss');
    }
    state = state.copyWith(
      isPlaying: false,
      engineThinking: false,
      clearResult: true,
    );
    ref.read(chessEngineProvider).stopAnalysis();
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
  double _currentDelaySecs = 1.0;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch<PlayGameState>(playGameProvider);
    final notifier = ref.read<PlayGameNotifier>(playGameProvider.notifier);

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
      body: (gameState.isPlaying || gameState.gameResult != null)
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
              notifier.startGame(
                _currentColor,
                _currentElo,
                avgDelaySecs: _currentDelaySecs,
              );
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
    final history = ref.watch(playHistoryProvider);

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
          // History Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'Wins',
                  history.wins.toString(),
                  Colors.green,
                  Icons.emoji_events_rounded,
                  context,
                ),
                _buildStatColumn(
                  'Draws',
                  history.draws.toString(),
                  Colors.orange,
                  Icons.handshake_rounded,
                  context,
                ),
                _buildStatColumn(
                  'Losses',
                  history.losses.toString(),
                  Colors.red,
                  Icons.psychology_rounded,
                  context,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          Text(
            'Engine Response: ${_currentDelaySecs.toStringAsFixed(1)}s avg',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Slider(
            value: _currentDelaySecs,
            min: 0.2,
            max: 5.0,
            divisions: 24,
            label: '${_currentDelaySecs.toStringAsFixed(1)}s',
            onChanged: (val) => setState(
              () => _currentDelaySecs = double.parse(val.toStringAsFixed(1)),
            ),
          ),
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
            onPressed: () => notifier.startGame(
              _currentColor,
              _currentElo,
              avgDelaySecs: _currentDelaySecs,
            ),
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

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    PlayGameState state,
    PlayGameNotifier notifier,
  ) {
    final isWhite = state.userColor == PlayerColor.white;
    final mySide = isWhite ? Side.white : Side.black;
    final opponentSide = isWhite ? Side.black : Side.white;

    final boardOrientation = isWhite ? Side.white : Side.black;
    // Determine if it's the user's turn
    final isUserTurn =
        state.isPlaying &&
        !state.engineThinking &&
        ((state.chess.turn == Side.white && isWhite) ||
            (state.chess.turn == Side.black && !isWhite));

    final captured = getCapturedPieces(state.chess.board);
    final materialScore = calculateMaterialScore(state.chess.board);
    final userAdvantage = isWhite ? materialScore : -materialScore;

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
        // Chessboard and Evaluation Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AspectRatio(
            aspectRatio: 1.05, // Slightly wider to accommodate the bar
            child: Row(
              children: [
                EvaluationBar(
                  evaluation: state.evaluation,
                  isReversed: !isWhite,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      // Opponent Captured Pieces (My pieces that opponent captured)
                      _CapturedPiecesRow(
                        pieces: captured[opponentSide]!,
                        side: mySide,
                        advantage: userAdvantage < 0 ? -userAdvantage : null,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = constraints.maxWidth <
                                    constraints.maxHeight
                                ? constraints.maxWidth
                                : constraints.maxHeight;
                            return Center(
                              child: SizedBox(
                                width: size,
                                height: size,
                                child: isUserTurn
                                    ? cg.Chessboard(
                                        size: size,
                                        orientation: boardOrientation,
                                        fen: state.chess.fen,
                                        game: cg.GameData(
                                          playerSide: isWhite
                                              ? cg.PlayerSide.white
                                              : cg.PlayerSide.black,
                                          sideToMove: state.chess.turn,
                                          validMoves: state.chess.legalMoves
                                              .asIMapSquareISet,
                                          promotionMove: _promotionMove,
                                          onMove:
                                              (move, {bool? viaDragAndDrop}) =>
                                                  notifier.onUserMove(move),
                                          isCheck: state.chess.isCheck,
                                          onPromotionSelection: (role) {
                                            if (_promotionMove != null &&
                                                role != null) {
                                              final promoted = NormalMove(
                                                from: _promotionMove!.from,
                                                to: _promotionMove!.to,
                                                promotion: role,
                                              );
                                              notifier.onUserMove(promoted);
                                              setState(
                                                () => _promotionMove = null,
                                              );
                                            }
                                          },
                                        ),
                                      )
                                    : cg.Chessboard.fixed(
                                        size: size,
                                        orientation: boardOrientation,
                                        fen: state.chess.fen,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      // My Captured Pieces (Opponent pieces I captured)
                      _CapturedPiecesRow(
                        pieces: captured[mySide]!,
                        side: opponentSide,
                        advantage: userAdvantage > 0 ? userAdvantage : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            icon: Icon(
              state.gameResult != null
                  ? Icons.arrow_back_rounded
                  : Icons.flag_rounded,
            ),
            label: Text(state.gameResult != null ? 'Back to Setup' : 'Resign'),
            style: OutlinedButton.styleFrom(
              foregroundColor: state.gameResult != null
                  ? context.colors.onSurface
                  : context.colors.error,
              side: BorderSide(
                color: state.gameResult != null
                    ? context.colors.outline
                    : context.colors.error,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
class _CapturedPiecesRow extends StatelessWidget {
  const _CapturedPiecesRow({
    required this.pieces,
    required this.side,
    this.advantage,
  });

  final List<Role> pieces;
  final Side side;
  final int? advantage;

  String _getPieceIcon(Role role) {
    return switch (role) {
      Role.pawn => '♟',
      Role.knight => '♞',
      Role.bishop => '♝',
      Role.rook => '♜',
      Role.queen => '♛',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (pieces.isEmpty && advantage == null) {
      return const SizedBox(height: 20);
    }

    final pieceColor = side == Side.white ? Colors.white : Colors.black87;

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          ...pieces.map(
            (p) => Padding(
              padding: const EdgeInsets.only(right: 1),
              child: Text(
                _getPieceIcon(p),
                style: TextStyle(
                  color: pieceColor,
                  fontSize: 16,
                  shadows: [
                    if (side == Side.white)
                      const Shadow(color: Colors.black45, blurRadius: 1),
                  ],
                ),
              ),
            ),
          ),
          if (advantage != null && advantage! > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '+$advantage',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
