import 'dart:async';
import 'dart:math';

import 'package:dartchess/dartchess.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:chess_traps/core/services/audio_haptic_service.dart';
import 'package:chess_traps/presentation/state/play/engine_analysis_provider.dart';
import 'package:chess_traps/presentation/state/play/play_history_provider.dart';

part 'play_game_provider.g.dart';

enum PlayerColor { white, black, random }

enum GameResult { win, loss, draw }

/// The live engine evaluation, kept in its own provider so the fast-ticking
/// eval stream (up to ~5×/s while Stockfish thinks) only repaints the
/// evaluation bar instead of rebuilding the entire play screen.
typedef PlayEval = ({double cp, int? mateIn});

class PlayEvalNotifier extends Notifier<PlayEval> {
  @override
  PlayEval build() => (cp: 0.0, mateIn: null);
  void set(double cp, int? mateIn) => state = (cp: cp, mateIn: mateIn);
  void reset() => state = (cp: 0.0, mateIn: null);
}

final playEvalProvider = NotifierProvider<PlayEvalNotifier, PlayEval>(
  PlayEvalNotifier.new,
);

/// Who the opponent is: the Stockfish engine, or a second human sharing the
/// device (local pass-and-play).
enum GameMode { engine, friend }

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
    this.mode = GameMode.engine,
    this.winnerSide,
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

  /// Which opponent this game is against.
  final GameMode mode;

  /// The side that won (checkmate). Null for a draw or an ongoing game. Used
  /// for friend-mode results, where there is no single "user" perspective.
  final Side? winnerSide;

  bool get isFriendMode => mode == GameMode.friend;

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
    GameMode? mode,
    Side? winnerSide,
    bool clearWinnerSide = false,
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
      mode: mode ?? this.mode,
      winnerSide: (clearResult || clearWinnerSide)
          ? null
          : (winnerSide ?? this.winnerSide),
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

  void _throttleUpdate(double eval, {int? mateIn}) {
    _pendingEval = eval;
    _pendingMateIn = mateIn;
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      _throttleTimer = Timer(const Duration(milliseconds: 200), () {
        if (_pendingEval != null) {
          // Live eval lives in its own provider: this update repaints only the
          // evaluation bar, not the whole play screen.
          ref
              .read(playEvalProvider.notifier)
              .set(_pendingEval!, _pendingMateIn);
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

  void setBrowseIndex(int? index) {
    if (index != null) {
      if (index < 0) index = 0;
      if (index >= state.fenHistory.length - 1) index = null;
    }
    state = state.copyWith(browseIndex: index, clearBrowseIndex: index == null);
  }

  void startGame(
    PlayerColor color,
    int elo, {
    double avgDelaySecs = 1.0,
    GameMode mode = GameMode.engine,
  }) {
    final actualColor = color == PlayerColor.random
        ? (DateTime.now().millisecondsSinceEpoch % 2 == 0
              ? PlayerColor.white
              : PlayerColor.black)
        : color;

    ref.read(playEvalProvider.notifier).reset();

    state = state.copyWith(
      chess: Chess.initial,
      userColor: actualColor,
      elo: elo,
      mode: mode,
      isPlaying: true,
      engineThinking: false,
      evaluation: 0,
      clearResult: true,
      clearLastMove: true,
      clearMateIn: true,
      clearWinnerSide: true,
      avgEngineDelaySecs: avgDelaySecs,
      moveHistory: [],
      fenHistory: [Chess.initial.fen],
    );

    _hapticService.playMove();

    // Only the engine plays automatically; in friend mode both sides are human.
    if (mode == GameMode.engine && actualColor == PlayerColor.black) {
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

    if (_maybeEndGame(nextPos)) return;

    // Friend mode: the turn simply passes to the other human — no engine. The
    // board stays put; chessground flips the pieces to face the new mover.
    if (state.isFriendMode) return;

    state = state.copyWith(engineThinking: true);
    ref.read(chessEngineProvider).playMove(nextPos.fen, state.elo);
  }

  /// Handles a terminal position for either mode: records the result and
  /// updates state. Returns true if the game is over. Assumes the moving
  /// move is already reflected in [state.moveHistory].
  bool _maybeEndGame(Position pos) {
    if (pos.isCheckmate) {
      final winner = pos.turn.opposite;
      if (state.isFriendMode) {
        ref
            .read(playHistoryProvider.notifier)
            .addFriendGame(
              winner == Side.white ? 'white' : 'black',
              state.moveHistory,
            );
        // gameResult is only a "game over" sentinel here; friend-mode UI
        // reads winnerSide for the actual result.
        state = state.copyWith(
          isPlaying: false,
          gameResult: GameResult.win,
          winnerSide: winner,
        );
      } else {
        final userSide = state.userColor == PlayerColor.white
            ? Side.white
            : Side.black;
        final result = winner == userSide ? GameResult.win : GameResult.loss;
        _recordResult(result);
        // A rare voice reward/commiseration on the game's outcome.
        if (result == GameResult.win) {
          _hapticService.playPraise();
        } else {
          _hapticService.playAww();
        }
        state = state.copyWith(
          isPlaying: false,
          gameResult: result,
          winnerSide: winner,
        );
      }
      return true;
    } else if (pos.outcome == Outcome.draw) {
      if (state.isFriendMode) {
        ref
            .read(playHistoryProvider.notifier)
            .addFriendGame('draw', state.moveHistory);
      } else {
        _recordResult(GameResult.draw);
      }
      state = state.copyWith(
        isPlaying: false,
        gameResult: GameResult.draw,
        clearWinnerSide: true,
      );
      return true;
    }
    return false;
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

      _maybeEndGame(nextPos);
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

  /// User gives up mid-game. In engine mode this is a user loss. In friend
  /// mode the side to move resigns, so the other side wins.
  void resign() {
    if (!state.isPlaying) return;

    if (state.isFriendMode) {
      final loser = state.chess.turn;
      final winner = loser.opposite;
      ref
          .read(playHistoryProvider.notifier)
          .addFriendGame(
            winner == Side.white ? 'white' : 'black',
            state.moveHistory,
          );
      state = state.copyWith(
        isPlaying: false,
        gameResult: GameResult.win, // sentinel; UI reads winnerSide
        winnerSide: winner,
        resigned: true,
      );
      return;
    }

    _recordResult(GameResult.loss);
    _hapticService.playAww();
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
    ref.read(playEvalProvider.notifier).reset();
    Position pos = Chess.initial;
    final fenHistory = <String>[pos.fen];
    for (final uci in game.pgnMoves) {
      final move = NormalMove.fromUci(uci);
      pos = pos.play(move);
      fenHistory.add(pos.fen);
    }

    if (game.isFriendGame) {
      final winner = switch (game.result) {
        'white' => Side.white,
        'black' => Side.black,
        _ => null,
      };
      state = state.copyWith(
        chess: pos,
        isPlaying: false,
        engineThinking: false,
        evaluation: 0,
        mode: GameMode.friend,
        gameResult: GameResult.win, // sentinel; UI reads winnerSide
        winnerSide: winner,
        clearWinnerSide: winner == null,
        clearLastMove: true,
        moveHistory: game.pgnMoves,
        fenHistory: fenHistory,
        clearBrowseIndex: true,
      );
      return;
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
      mode: GameMode.engine,
      gameResult: result,
      clearWinnerSide: true,
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

    // Friend mode: undo a single ply (both players share the device). Engine
    // mode: pop the pair (user move + engine reply) so it stays the user's turn.
    final plies = state.isFriendMode ? 1 : 2;
    if (state.fenHistory.length <= plies) return;

    final newFenHistory = List<String>.from(state.fenHistory);
    final newMoveHistory = List<String>.from(state.moveHistory);
    for (var i = 0; i < plies; i++) {
      newFenHistory.removeLast();
      newMoveHistory.removeLast();
    }

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
    if (!state.isFriendMode) ref.read(chessEngineProvider).stopAnalysis();
  }
}
