import 'dart:async';
import 'dart:math';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/core/services/audio_haptic_service.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/core/services/move_annotator.dart';
import 'package:chess_traps/presentation/widgets/evaluation_bar.dart';
import 'package:chess_traps/presentation/state/play/engine_analysis_provider.dart';
import 'package:chess_traps/presentation/state/play/play_history_provider.dart';

part 'play_screen.g.dart';

enum PlayerColor { white, black, random }
enum GameResult { win, loss, draw }

class PlayGameState {
  PlayGameState({
    required this.chess,
    required this.userColor,
    required this.elo,
    required this.isPlaying,
    required this.engineThinking,
    required this.evaluation,
    required this.avgEngineDelaySecs,
    required this.moveHistory,
    required this.fenHistory,
    this.browseIndex,
    this.gameResult,
    this.lastMove,
    this.hintMove,
    this.mateIn,
    this.resigned = false,
  });

  final Position chess;
  final PlayerColor userColor;
  final int elo;
  final bool isPlaying;
  final bool engineThinking;
  final double evaluation; // Centipawns, positive for white
  final GameResult? gameResult; // null = ongoing
  final NormalMove? lastMove;
  final NormalMove? hintMove;
  final List<String> moveHistory;
  final List<String> fenHistory;
  final int? browseIndex;

  /// Moves to mate; positive if white is delivering it, negative if black is.
  /// Null when the position isn't a forced mate.
  final int? mateIn;

  /// True when [gameResult] is a loss the user chose (resignation) rather
  /// than one forced by checkmate — lets the result dialog say so.
  final bool resigned;

  /// Average engine response time in seconds (power-law distributed)
  final double avgEngineDelaySecs;

  PlayGameState copyWith({
    Position? chess,
    PlayerColor? userColor,
    int? elo,
    bool? isPlaying,
    bool? engineThinking,
    double? evaluation,
    GameResult? gameResult,
    bool clearResult = false,
    double? avgEngineDelaySecs,
    NormalMove? lastMove,
    bool clearLastMove = false,
    NormalMove? hintMove,
    bool clearHintMove = false,
    List<String>? moveHistory,
    List<String>? fenHistory,
    int? browseIndex,
    bool clearBrowseIndex = false,
    int? mateIn,
    bool clearMateIn = false,
    bool? resigned,
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
      lastMove: clearLastMove ? null : (lastMove ?? this.lastMove),
      hintMove: clearHintMove ? null : (hintMove ?? this.hintMove),
      moveHistory: moveHistory ?? this.moveHistory,
      fenHistory: fenHistory ?? this.fenHistory,
      browseIndex: clearBrowseIndex ? null : (browseIndex ?? this.browseIndex),
      mateIn: clearMateIn ? null : (mateIn ?? this.mateIn),
      resigned: clearResult ? false : (resigned ?? this.resigned),
    );
  }
}

@riverpod
class PlayGameNotifier extends _$PlayGameNotifier {
  final _hapticService = AudioHapticService();
  StreamSubscription<String>? _sub;
  Timer? _throttleTimer;
  Timer? _hintClearTimer;
  double? _pendingEval;

  /// True while a `bestmove` response should be treated as a hint for the
  /// user rather than the opponent's actual move. Requesting a hint reuses
  /// the same engine session as gameplay (multistockfish only supports one
  /// running engine), so the two purposes are distinguished by this flag
  /// instead of sending overlapping/competing engine commands.
  bool _hintPending = false;

  @override
  PlayGameState build() {
    final engineService = ref.watch(chessEngineProvider);

    // Initial subscription
    _sub?.cancel();
    _sub = engineService.engineOutput.listen(_onEngineLine);

    ref.onDispose(() {
      _sub?.cancel();
      _throttleTimer?.cancel();
      _hintClearTimer?.cancel();
    });

    return PlayGameState(
      chess: Chess.initial,
      userColor: PlayerColor.white,
      elo: 1500,
      isPlaying: false,
      engineThinking: false,
      evaluation: 0,
      avgEngineDelaySecs: 1.0,
      moveHistory: const [],
      fenHistory: [Chess.initial.fen],
    );
  }

  void _onEngineLine(String line) {
    if (line.startsWith('bestmove')) {
      final parts = line.split(' ');
      if (parts.length > 1) {
        final moveStr = parts[1];
        if (moveStr != '(none)') {
          if (_hintPending) {
            _hintPending = false;
            state = state.copyWith(hintMove: NormalMove.fromUci(moveStr));
            _hintClearTimer?.cancel();
            _hintClearTimer = Timer(const Duration(seconds: 3), () {
              state = state.copyWith(clearHintMove: true);
            });
            return;
          }
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
      if (mate != null && mate != 0) {
        final sign = state.chess.turn == Side.white ? 1.0 : -1.0;
        final eval = mate > 0 ? 999.0 * sign : -999.0 * sign;
        // Mate count reported by the engine is relative to the side to
        // move; re-sign it so positive always means "white delivers mate".
        final mateIn = mate.abs() * (eval > 0 ? 1 : -1);
        _throttleUpdate(eval, mateIn: mateIn);
      }
    }
  }

  int? _pendingMateIn;
  bool _pendingMateSet = false;

  void _throttleUpdate(double eval, {int? mateIn}) {
    _pendingEval = eval;
    _pendingMateIn = mateIn;
    _pendingMateSet = true;
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      _throttleTimer = Timer(const Duration(milliseconds: 200), () {
        if (_pendingEval != null) {
          state = state.copyWith(
            evaluation: _pendingEval!,
            mateIn: _pendingMateIn,
            clearMateIn: _pendingMateSet && _pendingMateIn == null,
          );
          _pendingEval = null;
          _pendingMateSet = false;
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

  void setBrowseIndex(int? index) {
    if (index != null) {
      if (index < 0) index = 0;
      if (index >= state.fenHistory.length - 1) index = null;
    }
    state = state.copyWith(browseIndex: index, clearBrowseIndex: index == null);
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
      clearLastMove: true,
      clearMateIn: true,
      avgEngineDelaySecs: avgDelaySecs,
      moveHistory: [],
      fenHistory: [Chess.initial.fen],
    );

    _hapticService.playMove();

    if (actualColor == PlayerColor.black) {
      state = state.copyWith(engineThinking: true);
      ref.read(chessEngineProvider).playMove(Chess.initial.fen, elo);
    }
  }

  void onUserMove(Move move) {
    if (!state.isPlaying || state.engineThinking) return;

    final pos = state.chess;

    // Safety net: if a pawn reaches the last rank without a promotion role
    // (e.g. the promotion picker was bypassed), default to a queen instead of
    // letting pos.play reject the move and silently do nothing.
    if (move is NormalMove && move.promotion == null) {
      final piece = pos.board.pieceAt(move.from);
      final rank = move.to.rank;
      if (piece?.role == Role.pawn && (rank == 0 || rank == 7)) {
        move = move.withPromotion(Role.queen);
      }
    }

    final isCapture = move is NormalMove && pos.board.pieceAt(move.to) != null;

    Position nextPos;
    try {
      nextPos = pos.play(move);
    } catch (_) {
      return;
    }
    state = state.copyWith(
      chess: nextPos,
      lastMove: move as NormalMove?,
      moveHistory: [...state.moveHistory, move.uci],
      fenHistory: [...state.fenHistory, nextPos.fen],
      clearBrowseIndex: true,
      clearHintMove: true,
    );

    if (nextPos.isCheck) {
      _hapticService.playCheck();
    } else if (isCapture) {
      _hapticService.playCapture();
    } else {
      _hapticService.playMove();
    }

    if (nextPos.isCheckmate) {
      final winnerSide = nextPos.turn.opposite;
      final userSide = state.userColor == PlayerColor.white ? Side.white : Side.black;
      final result = (winnerSide == userSide) ? GameResult.win : GameResult.loss;
      _recordResult(result);
      state = state.copyWith(isPlaying: false, gameResult: result);
      return;
    } else if (nextPos.outcome == Outcome.draw) {
      _recordResult(GameResult.draw);
      state = state.copyWith(isPlaying: false, gameResult: GameResult.draw);
      return;
    }

    state = state.copyWith(engineThinking: true);
    ref.read(chessEngineProvider).playMove(nextPos.fen, state.elo);
  }

  void _onEngineMove(String moveUci) {
    if (!state.isPlaying) return;

    final delay = _powerLawDelay(state.avgEngineDelaySecs);
    Future<void>.delayed(delay, () {
      if (!state.isPlaying) return;

      final move = NormalMove.fromUci(moveUci);
      final isCapture = state.chess.board.pieceAt(move.to) != null;
      // Guard against the engine's move no longer being legal for the current
      // position (e.g. the position changed under this delayed callback).
      // Playing an illegal move throws PlayException; drop it and clear the
      // thinking flag rather than crashing.
      final Position nextPos;
      try {
        nextPos = state.chess.play(move);
      } on PlayException {
        state = state.copyWith(engineThinking: false);
        return;
      }

      state = state.copyWith(
        chess: nextPos,
        engineThinking: false,
        lastMove: move,
        moveHistory: [...state.moveHistory, move.uci],
        fenHistory: [...state.fenHistory, nextPos.fen],
      clearBrowseIndex: true,
      );

      if (nextPos.isCheck) {
        _hapticService.playCheck();
      } else if (isCapture) {
        _hapticService.playCapture();
      } else {
        _hapticService.playMove();
      }

      if (nextPos.isCheckmate) {
        final winnerSide = nextPos.turn.opposite;
        final userSide = state.userColor == PlayerColor.white ? Side.white : Side.black;
        final result = (winnerSide == userSide) ? GameResult.win : GameResult.loss;
        _recordResult(result);
        state = state.copyWith(isPlaying: false, gameResult: result);
      } else if (nextPos.outcome == Outcome.draw) {
        _recordResult(GameResult.draw);
        state = state.copyWith(isPlaying: false, gameResult: GameResult.draw);
      }
    });
  }


  void _recordResult(GameResult result) {
    switch (result) {
      case GameResult.win:
        ref.read(playHistoryProvider.notifier).addWin(state.moveHistory);
      case GameResult.loss:
        ref.read(playHistoryProvider.notifier).addLoss(state.moveHistory);
      case GameResult.draw:
        ref.read(playHistoryProvider.notifier).addDraw(state.moveHistory);
    }
  }

  /// User gives up mid-game: counts as a loss and shows the result dialog,
  /// same as being checkmated, but flagged as [PlayGameState.resigned] so the
  /// dialog can say so.
  void resign() {
    if (!state.isPlaying) return;
    _recordResult(GameResult.loss);
    state = state.copyWith(
      isPlaying: false,
      engineThinking: false,
      gameResult: GameResult.loss,
      resigned: true,
    );
    ref.read(chessEngineProvider).stopAnalysis();
  }

  /// Leaves the finished/aborted game and returns to the setup screen without
  /// recording anything (the result was already recorded when the game
  /// ended, whether by checkmate, draw, or resignation).
  void backToSetup() {
    state = state.copyWith(
      isPlaying: false,
      engineThinking: false,
      clearResult: true,
      clearLastMove: true,
      clearHintMove: true,
      clearMateIn: true,
      clearBrowseIndex: true,
    );
    ref.read(chessEngineProvider).stopAnalysis();
  }

  /// Loads a previously saved game in read-only browse mode (no engine, no
  /// further moves) so the user can step through it.
  void viewSavedGame(SavedGame game) {
    Position pos = Chess.initial;
    final fenHistory = <String>[pos.fen];
    for (final uci in game.pgnMoves) {
      final move = NormalMove.fromUci(uci);
      pos = pos.play(move);
      fenHistory.add(pos.fen);
    }

    final result = switch (game.result) {
      'win' => GameResult.win,
      'loss' => GameResult.loss,
      _ => GameResult.draw,
    };

    state = state.copyWith(
      chess: pos,
      isPlaying: false,
      engineThinking: false,
      evaluation: 0,
      gameResult: result,
      clearLastMove: true,
      moveHistory: game.pgnMoves,
      fenHistory: fenHistory,
      clearBrowseIndex: true,
    );
  }

  /// Asks the engine for the best move in the current (user's turn) position
  /// and surfaces it as [PlayGameState.hintMove] rather than playing it.
  void requestHint() {
    if (!state.isPlaying || state.engineThinking || _hintPending) return;
    _hintPending = true;
    ref.read(chessEngineProvider).playMove(state.chess.fen, state.elo);
  }

  void takeback() {
    if (!state.isPlaying || state.engineThinking) return;
    if (state.fenHistory.length <= 2) return; // Need at least user's move + engine's move to pop

    final newFenHistory = List<String>.from(state.fenHistory)..removeLast()..removeLast();
    final newMoveHistory = List<String>.from(state.moveHistory)..removeLast()..removeLast();
    
    final previousFen = newFenHistory.last;
    final parsed = Setup.parseFen(previousFen);

    final newChess = Chess.fromSetup(parsed);
    
    state = state.copyWith(
      chess: newChess,
      fenHistory: newFenHistory,
      moveHistory: newMoveHistory,
      clearLastMove: true,
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
  bool _boardFlipped = false;

  @override
  void initState() {
    super.initState();
    // Preload so an interstitial is ready to show at the end-of-game break.
    InterstitialAdManager().loadAd();
  }

  /// Handles a move coming from the board. If it's a pawn reaching the last
  /// rank without a promotion role, ask the user which piece to promote to
  /// before committing the move.
  Future<void> _handleUserMove(
    Move move,
    PlayGameNotifier notifier,
    bool isWhite,
  ) async {
    if (move is NormalMove && move.promotion == null) {
      final piece = ref
          .read(playGameProvider)
          .chess
          .board
          .pieceAt(move.from);
      final rank = move.to.rank;
      if (piece?.role == Role.pawn && (rank == 0 || rank == 7)) {
        final role = await _showPromotionPicker(isWhite);
        if (role == null) return; // cancelled — leave the piece where it was
        notifier.onUserMove(move.withPromotion(role));
        return;
      }
    }
    notifier.onUserMove(move);
  }

  Future<Role?> _showPromotionPicker(bool isWhite) {
    const roles = [Role.queen, Role.rook, Role.bishop, Role.knight];
    return showDialog<Role>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.phrase.choose_promotion,
          textAlign: TextAlign.center,
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: roles.map((role) {
            return IconButton(
              iconSize: 44,
              onPressed: () => Navigator.pop(ctx, role),
              icon: Text(
                _promotionGlyph(role),
                style: TextStyle(
                  fontSize: 40,
                  color: isWhite ? Colors.white : Colors.black87,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _promotionGlyph(Role role) => switch (role) {
        Role.queen => '♛',
        Role.rook => '♜',
        Role.bishop => '♝',
        Role.knight => '♞',
        _ => '',
      };

  /// Converts a UCI move history into standard algebraic notation by replaying
  /// from the initial position.
  List<String> _sanMoves(List<String> uciMoves) {
    final sans = <String>[];
    Position pos = Chess.initial;
    for (final uci in uciMoves) {
      try {
        final (nextPos, san) = pos.makeSan(NormalMove.fromUci(uci));
        sans.add(san);
        pos = nextPos;
      } catch (_) {
        sans.add(uci); // fall back to raw UCI if replay fails
      }
    }
    return sans;
  }

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
        actions: [
          if (gameState.isPlaying && !gameState.engineThinking)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline_rounded),
              tooltip: context.phrase.hint,
              onPressed: notifier.requestHint,
            ),
          if (gameState.isPlaying || gameState.gameResult != null)
            IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded),
              tooltip: context.phrase.flip,
              onPressed: () => setState(() => _boardFlipped = !_boardFlipped),
            ),
        ],
      ),
      body: (gameState.isPlaying || gameState.gameResult != null)
          ? _buildGameArea(context, gameState, notifier)
          : _buildSetupArea(context, gameState, notifier),
    );
  }

  void _showResultDialog(
    BuildContext context,
    GameResult result,
    PlayGameNotifier notifier,
  ) {
    final resigned = ref.read(playGameProvider).resigned;
    final (title, subtitle, icon) = switch (result) {
      GameResult.win => (
        context.phrase.you_won,
        context.phrase.congratulations,
        Icons.emoji_events_rounded
      ),
      GameResult.loss => (
        context.phrase.stockfish_won,
        resigned ? context.phrase.you_resigned : context.phrase.better_luck_next_time,
        Icons.psychology_rounded,
      ),
      GameResult.draw => (
        context.phrase.draw,
        context.phrase.well_played,
        Icons.handshake_rounded
      ),
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
            onPressed: () {
              Navigator.pop(ctx);
              // Monetize the "I'm done" moment — not "play again", to keep
              // the replay loop friction-free. Capped by the shared cooldown.
              InterstitialAdManager().onGameFinished();
            },
            child: Text(context.phrase.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.startGame(_currentColor, _currentElo);
            },
            child: Text(context.phrase.play_again),
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
            context.phrase.opponent_strength,
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
                  context.phrase.wins,
                  history.wins.toString(),
                  Colors.green,
                  Icons.emoji_events_rounded,
                  context,
                ),
                _buildStatColumn(
                  context.phrase.draws,
                  history.draws.toString(),
                  Colors.orange,
                  Icons.handshake_rounded,
                  context,
                ),
                _buildStatColumn(
                  context.phrase.losses,
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
            context.phrase.eloLabel(_currentElo),
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

          Text(
            context.phrase.play_as,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SegmentedButton<PlayerColor>(
            segments: [
              ButtonSegment(
                value: PlayerColor.white,
                label: Text(context.phrase.white),
                icon: const Icon(Icons.circle_outlined),
              ),
              ButtonSegment(
                value: PlayerColor.random,
                label: Text(context.phrase.random),
                icon: const Icon(Icons.casino_outlined),
              ),
              ButtonSegment(
                value: PlayerColor.black,
                label: Text(context.phrase.black),
                icon: const Icon(Icons.circle),
              ),
            ],
            selected: {_currentColor},
            onSelectionChanged: (set) =>
                setState(() => _currentColor = set.first),
          ),
          const Spacer(),
          if (history.savedGames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () => _showSavedGames(context, history, notifier),
                icon: const Icon(Icons.history_rounded),
                label: Text(context.phrase.your_games),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              notifier.startGame(_currentColor, _currentElo);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.phrase.start_game,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSavedGames(
    BuildContext context,
    PlayHistory history,
    PlayGameNotifier notifier,
  ) {
    final games = history.savedGames.reversed.toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: games.length,
          itemBuilder: (ctx, index) {
            final game = games[index];
            final date = DateTime.tryParse(game.date);
            final (icon, color) = switch (game.result) {
              'win' => (Icons.emoji_events_rounded, Colors.green),
              'loss' => (Icons.psychology_rounded, Colors.red),
              _ => (Icons.handshake_rounded, Colors.orange),
            };
            return ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                date != null
                    ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                    : game.date,
              ),
              subtitle: Text('${game.pgnMoves.length} ${context.phrase.moves}'),
              onTap: () {
                Navigator.pop(ctx);
                notifier.viewSavedGame(game);
              },
            );
          },
        ),
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

    final currentFen = state.browseIndex != null 
        ? state.fenHistory[state.browseIndex!] 
        : state.chess.fen;
        
    final baseOrientation = isWhite ? Side.white : Side.black;
    final boardOrientation = _boardFlipped ? baseOrientation.opposite : baseOrientation;
    // Determine if it's the user's turn
    final isUserTurn =
        state.isPlaying &&
        !state.engineThinking &&
        state.browseIndex == null &&
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
                context.phrase.stockfishLabel(state.elo),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (state.engineThinking)
                Row(
                  children: [
                    Text(
                      context.phrase.thinking,
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
        // Opponent Captured Pieces (My pieces that opponent captured)
        Padding(
          padding: const EdgeInsets.only(left: 34.0, right: 16.0, top: 4.0, bottom: 8.0),
          child: _CapturedPiecesRow(
            pieces: captured[opponentSide]!,
            side: mySide,
            advantage: userAdvantage < 0 ? -userAdvantage : null,
          ),
        ),
        // Chessboard and Evaluation Bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxBoardWidth = constraints.maxWidth - 20 - 8;
                final size = min(maxBoardWidth, constraints.maxHeight);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size,
                      width: 20,
                      child: EvaluationBar(
                        evaluation: state.evaluation,
                        isReversed: !isWhite,
                        label: state.mateIn == null
                            ? null
                            : 'M${state.mateIn!.abs()}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: size,
                      height: size,
                      child: isUserTurn
                          ? cg.Chessboard(
                              size: size,
                              orientation: boardOrientation,
                              fen: currentFen,
                              lastMove: state.lastMove,
                              shapes: state.hintMove == null
                                  ? null
                                  : ISet({
                                      cg.Arrow(
                                        color: Colors.green.withValues(alpha: 0.8),
                                        orig: state.hintMove!.from,
                                        dest: state.hintMove!.to,
                                      ),
                                    }),
                              game: cg.GameData(
                                playerSide: isWhite ? cg.PlayerSide.white : cg.PlayerSide.black,
                                sideToMove: state.chess.turn,
                                validMoves: state.chess.legalMoves.asIMapSquareISet,
                                // Promotion is handled by our own dialog in
                                // _handleUserMove, so chessground's inline
                                // selector is disabled here.
                                promotionMove: null,
                                onMove: (move, {bool? viaDragAndDrop}) =>
                                    _handleUserMove(move, notifier, isWhite),
                                isCheck: state.chess.isCheck,
                                onPromotionSelection: (_) {},
                              ),
                            )
                          : cg.Chessboard.fixed(
                              size: size,
                              orientation: boardOrientation,
                              fen: currentFen,
                              lastMove: state.lastMove,
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // Player indicator
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
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
                context.phrase.you,
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
                      context.phrase.your_turn,
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
        // My Captured Pieces (Opponent pieces I captured)
        Padding(
          padding: const EdgeInsets.only(left: 34.0, right: 16.0, top: 4.0),
          child: _CapturedPiecesRow(
            pieces: captured[mySide]!,
            side: opponentSide,
            advantage: userAdvantage > 0 ? userAdvantage : null,
          ),
        ),
        const SizedBox(height: 16),
        // Move History (standard algebraic notation, tap to jump). Always
        // reserves the same fixed height whether or not there are moves yet,
        // so the board (in the Expanded above) doesn't resize the moment the
        // first move is played and this stops being a flexible Spacer.
        SizedBox(
          height: 32,
          child: state.moveHistory.isEmpty
              ? null
              : Builder(
                  builder: (context) {
                    final sans = _sanMoves(state.moveHistory);
                    final browseIdx = state.browseIndex ?? state.fenHistory.length - 1;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: (sans.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        final moveNum = index + 1;
                        final whiteIdx = index * 2;
                        final blackIdx = index * 2 + 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$moveNum. ', style: TextStyle(color: context.colors.outline, fontSize: 13)),
                              _MoveChip(
                                san: sans[whiteIdx],
                                highlighted: browseIdx == whiteIdx + 1,
                                onTap: () => notifier.setBrowseIndex(whiteIdx + 1),
                              ),
                              if (blackIdx < sans.length) ...[
                                const SizedBox(width: 8),
                                _MoveChip(
                                  san: sans[blackIdx],
                                  highlighted: browseIdx == blackIdx + 1,
                                  onTap: () => notifier.setBrowseIndex(blackIdx + 1),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        // Always rendered (buttons simply disabled with a single move) so the
        // board above doesn't resize the instant a nav row's fixed height
        // first appears in the Column.
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Builder(
              builder: (context) {
                final lastIndex = state.fenHistory.length - 1;
                final curr = state.browseIndex ?? lastIndex;
                final atStart = curr == 0;
                final atEnd = curr == lastIndex;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.first_page_rounded),
                      tooltip: context.phrase.first_move,
                      onPressed: atStart ? null : () => notifier.setBrowseIndex(0),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: context.phrase.previous_move,
                      onPressed: atStart ? null : () => notifier.setBrowseIndex(curr - 1),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${curr + 1} / ${lastIndex + 1}',
                        textAlign: TextAlign.center,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: context.phrase.next_move,
                      onPressed: atEnd ? null : () => notifier.setBrowseIndex(curr + 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.last_page_rounded),
                      tooltip: context.phrase.last_move,
                      onPressed: atEnd ? null : () => notifier.setBrowseIndex(lastIndex),
                    ),
                  ],
                );
              },
            ),
          ),
        if (state.gameResult != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _PostGameExplanationCaption(state: state),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (state.fenHistory.length > 2 && state.isPlaying && !state.engineThinking)
                      ? () {
                          notifier.takeback();
                        }
                      : null,
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(context.phrase.undo),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (state.gameResult != null) {
                      notifier.backToSetup();
                    } else {
                      notifier.resign();
                    }
                  },
                  icon: Icon(
                    state.gameResult != null
                        ? Icons.arrow_back_rounded
                        : Icons.flag_rounded,
                  ),
                  label: Text(
                    state.gameResult != null
                        ? context.phrase.back_to_setup
                        : context.phrase.resign,
                  ),
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
/// Post-game analysis caption: as the user browses a finished game, explains
/// why the move at the current browse position mattered — reusing the same
/// offline, engine-free annotator as the trap detail screen.
class _PostGameExplanationCaption extends StatelessWidget {
  const _PostGameExplanationCaption({required this.state});
  final PlayGameState state;

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = state.browseIndex ?? state.fenHistory.length - 1;
    if (effectiveIndex <= 0 || effectiveIndex > state.moveHistory.length) {
      return const SizedBox.shrink();
    }

    final beforeFen = state.fenHistory[effectiveIndex - 1];
    final afterFen = state.fenHistory[effectiveIndex];
    final uci = state.moveHistory[effectiveIndex - 1];

    Position before;
    Position after;
    Move move;
    String san;
    try {
      before = Chess.fromSetup(Setup.parseFen(beforeFen));
      after = Chess.fromSetup(Setup.parseFen(afterFen));
      move = NormalMove.fromUci(uci);
      final (_, sanResult) = before.makeSan(move);
      san = sanResult;
    } catch (_) {
      return const SizedBox.shrink();
    }

    final explanation = explainMove(
      context: context,
      before: before,
      move: move,
      after: after,
      san: san,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 16, color: context.colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.san,
    required this.highlighted,
    required this.onTap,
  });

  final String san;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: highlighted ? context.colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          san,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: highlighted
                ? context.colors.onPrimaryContainer
                : context.colors.onSurface,
          ),
        ),
      ),
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
