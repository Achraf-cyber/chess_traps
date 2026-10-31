import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:multistockfish/multistockfish.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chess_traps/core/services/analytics_service.dart';
import 'package:chess_traps/core/services/uci.dart';

class ChessEngineService {
  factory ChessEngineService() => _instance;
  ChessEngineService._internal();

  static final ChessEngineService _instance = ChessEngineService._internal();

  /// How often a start is tried before giving up until the next request.
  static const _startAttempts = 3;

  /// How many times in a row a dead engine is restarted without a search
  /// completing in between, so a position that crashes it can't loop forever.
  static const _maxRestarts = 3;

  Stockfish? _stockfish;
  Future<void>? _starting;
  int _restarts = 0;

  final _outputController = StreamController<String>.broadcast();
  Stream<String> get engineOutput => _outputController.stream;

  late final _searches = UciSearchQueue(
    write: _safeWrite,
    emit: (line) {
      if (line.startsWith('bestmove')) _restarts = 0;
      if (!_outputController.isClosed) _outputController.add(line);
    },
  );

  // This notifier allows the UI to wait indefinitely for the slow extraction
  final ValueNotifier<bool> engineAvailableNotifier = ValueNotifier(false);

  bool get engineAvailable => engineAvailableNotifier.value;
  int _multiPv = 4;

  /// The latest search asked for, kept until an engine is there to run it.
  _Search? _pending;

  /// The search running on the engine, re-issued if the engine dies under it.
  _Search? _current;

  Timer? _fallbackAnalysisTimer;
  Timer? _fallbackMoveTimer;
  String? _fallbackFen;

  bool get _isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// The position [engineOutput] is currently reporting on. Scores are relative
  /// to the side to move, so this is what they must be read against, and
  /// output for any other position is not about what's on screen.
  String? get searchFen =>
      _isSupportedPlatform ? _searches.fen : _fallbackFen;

  /// Starts the engine if it isn't running. Safe to call at any time and from
  /// anywhere: a start that failed is simply tried again.
  Future<void> init() {
    if (!_isSupportedPlatform) {
      debugPrint('Stockfish: Using fallback chess engine on this platform');
      engineAvailableNotifier.value = true;
      return Future.value();
    }
    if (_stockfish != null) return Future.value();
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<void> _start() async {
    final analytics = AnalyticsService.instance;
    for (var attempt = 1; attempt <= _startAttempts; attempt++) {
      final stopwatch = Stopwatch()..start();
      try {
        // The light flavor's net is embedded and about 1 MB, so it loads well
        // inside multistockfish's fixed 5s start timeout even on low-end
        // devices, where the 38 MB net of the old default often did not.
        final engine = await Stockfish.create(onStdout: _searches.onLine);
        _stockfish = engine;
        engine.state.addListener(_onStateChanged);
        engineAvailableNotifier.value = true;
        debugPrint('Stockfish: Native bridge is fully READY');
        analytics.logEngineStarted(
          attempt: attempt,
          elapsed: stopwatch.elapsed,
        );

        final pending = _pending;
        _pending = null;
        if (pending != null) _run(pending);
        return;
      } catch (e) {
        debugPrint('Stockfish start failed (attempt $attempt): $e');
        analytics.logEngineStartFailed(
          attempt: attempt,
          willRetry: attempt < _startAttempts,
          error: e,
        );
        if (attempt < _startAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    // No engine to answer with: a game mustn't sit waiting for a reply forever.
    final pending = _pending;
    _pending = null;
    pending?.onUnavailable?.call();
  }

  void _onStateChanged() {
    final engine = _stockfish;
    if (engine == null || engine.state.value == StockfishState.ready) return;

    debugPrint('Stockfish died: ${engine.state.value} ${engine.diagnostics}');
    AnalyticsService.instance.logEngineCrashed(
      state: engine.state.value.name,
      diagnostics: engine.diagnostics.toString(),
    );
    engine.state.removeListener(_onStateChanged);
    unawaited(engine.dispose());
    _stockfish = null;
    _searches.reset();
    engineAvailableNotifier.value = false;

    _pending ??= _current;
    _current = null;
    if (_restarts++ < _maxRestarts) unawaited(init());
  }

  void _safeWrite(String command) {
    final engine = _stockfish;
    if (engine == null) return;
    try {
      engine.stdin = command;
    } catch (e) {
      debugPrint('Stockfish FFI Write Error: $e');
    }
  }

  /// Applied by the next [startAnalysis]; the caller re-analyses after a change.
  void updateOptions({int? multiPv}) {
    if (multiPv != null) _multiPv = multiPv;
  }

  void startAnalysis(String fen) {
    if (!_isSupportedPlatform) {
      _fallbackFen = fen;
      _fallbackAnalysisTimer?.cancel();
      _fallbackAnalysisTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        _outputController.add('info depth 10 score cp 0 pv e2e4');
      });
      return;
    }
    _search(
      _Search(fen, [
        // Options outlive a search: a game played just before must not leave
        // the analysis weakened.
        'setoption name UCI_LimitStrength value false',
        'setoption name MultiPV value $_multiPv',
        'position fen $fen',
        'go depth 20',
      ]),
    );
  }

  /// Asks for the engine's move in [fen], answered with a `bestmove` line.
  ///
  /// If no engine can be started, [fallback] answers with [_playFallbackMove]
  /// so that a game carries on; otherwise the answer is `bestmove (none)`.
  void playMove(String fen, int elo, {bool fallback = true}) {
    if (!_isSupportedPlatform) {
      _fallbackFen = fen;
      _fallbackMoveTimer?.cancel();
      _fallbackMoveTimer = Timer(
        const Duration(milliseconds: 500),
        () => _playFallbackMove(fen),
      );
      return;
    }

    // UCI_LimitStrength + UCI_Elo alone drive playing strength. Skill Level
    // is a separate (weaker) knob that fights UCI_Elo when both are set, so
    // it must stay unset while strength-limiting is active.
    final clampedElo = elo.clamp(1320, 3190);

    _search(
      _Search(
        fen,
        [
          'setoption name MultiPV value 1',
          'setoption name UCI_LimitStrength value true',
          'setoption name UCI_Elo value $clampedElo',
          'position fen $fen',
          'go movetime 1000', // Think for 1 second
        ],
        onUnavailable: fallback
            ? () {
                AnalyticsService.instance.logEngineFallbackUsed();
                _playFallbackMove(fen);
              }
            : () => _outputController.add('bestmove (none)'),
      ),
    );
  }

  void _playFallbackMove(String fen) {
    try {
      final setup = Setup.parseFen(fen);
      final position = Chess.fromSetup(setup);
      final List<NormalMove> moves = [];
      for (final entry in position.legalMoves.entries) {
        final from = entry.key;
        final toSet = entry.value;
        final isPawn = position.board.pieceAt(from)?.role == Role.pawn;
        for (final to in toSet.squares) {
          // Pawn moves reaching the back rank require an explicit
          // promotion role: dartchess treats a NormalMove without one as
          // legal but leaves the piece as a pawn instead of promoting it.
          final isPromotion =
              isPawn && (to.rank == Rank.first || to.rank == Rank.eighth);
          moves.add(
            NormalMove(
              from: from,
              to: to,
              promotion: isPromotion ? Role.queen : null,
            ),
          );
        }
      }

      if (moves.isEmpty) {
        _outputController.add('bestmove (none)');
        return;
      }

      // Heuristic: Checkmate first
      NormalMove? selectedMove;
      for (final m in moves) {
        if (position.play(m).isCheckmate) {
          selectedMove = m;
          break;
        }
      }

      // Heuristic: Capture next
      if (selectedMove == null) {
        final captures = moves
            .where((m) => position.board.pieceAt(m.to) != null)
            .toList();
        if (captures.isNotEmpty) {
          selectedMove = captures[Random().nextInt(captures.length)];
        }
      }

      // Heuristic: Check next
      if (selectedMove == null) {
        final checks = moves.where((m) => position.play(m).isCheck).toList();
        if (checks.isNotEmpty) {
          selectedMove = checks[Random().nextInt(checks.length)];
        }
      }

      // Default: Random
      selectedMove ??= moves[Random().nextInt(moves.length)];

      _outputController.add('bestmove ${selectedMove.uci}');
    } catch (e) {
      debugPrint('Fallback playMove error: $e');
      _outputController.add('bestmove (none)');
    }
  }

  void _search(_Search search) {
    if (_stockfish != null) {
      _run(search);
    } else {
      _pending = search;
      unawaited(init());
    }
  }

  void _run(_Search search) {
    _current = search;
    _searches.start(search.fen, search.commands);
  }

  void stopAnalysis() {
    if (!_isSupportedPlatform) {
      _fallbackAnalysisTimer?.cancel();
      _fallbackAnalysisTimer = null;
      return;
    }
    _pending = null;
    _current = null;
    _searches.stop();
  }

  /// Stops the native engine and releases its two isolates, but keeps the
  /// broadcast controller and notifier alive so the service can be
  /// re-initialised later.
  ///
  /// Terminating the isolates here is what lets Flutter hot reload/restart
  /// cleanly: the engine runs in blocking native isolates that would otherwise
  /// orphan across a restart and force a full relaunch.
  Future<void> shutdown() async {
    _fallbackAnalysisTimer?.cancel();
    _fallbackAnalysisTimer = null;
    _fallbackMoveTimer?.cancel();
    _fallbackMoveTimer = null;
    _pending = null;
    _current = null;

    if (_isSupportedPlatform) {
      await _starting;
      final engine = _stockfish;
      _stockfish = null;
      _searches.reset();
      engine?.state.removeListener(_onStateChanged);
      try {
        // Sends `quit`, which lets both engine isolates exit their loops.
        await engine?.dispose();
      } catch (e) {
        debugPrint('Stockfish shutdown error: $e');
      }
    }

    engineAvailableNotifier.value = false;
  }
}

/// A search to run on the engine.
class _Search {
  _Search(this.fen, this.commands, {this.onUnavailable});

  final String fen;
  final List<String> commands;

  /// Called if no engine could be started to run this search.
  final void Function()? onUnavailable;
}
