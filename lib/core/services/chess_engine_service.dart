import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:multistockfish/multistockfish.dart';
import 'package:dartchess/dartchess.dart';

class ChessEngineService {
  factory ChessEngineService() => _instance;
  ChessEngineService._internal();

  static final ChessEngineService _instance = ChessEngineService._internal();

  final Stockfish _stockfish = Stockfish.instance;
  final _outputController = StreamController<String>.broadcast();
  Stream<String> get engineOutput => _outputController.stream;
  StreamSubscription<String>? _stdoutSubscription;

  bool _isInit = false;
  bool _isInitializing = false;
  // This notifier allows the UI to wait indefinitely for the slow extraction
  final ValueNotifier<bool> engineAvailableNotifier = ValueNotifier(false);

  bool get engineAvailable => engineAvailableNotifier.value;
  int _multiPv = 4;
  void Function()? _pendingCommand;

  Timer? _fallbackAnalysisTimer;
  Timer? _fallbackMoveTimer;

  bool get _isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (_isInit || _isInitializing) return;
    _isInitializing = true;

    if (!_isSupportedPlatform) {
      debugPrint('Stockfish: Using fallback chess engine on this platform');
      engineAvailableNotifier.value = true;
      _isInit = true;
      _isInitializing = false;
      return;
    }

    try {
      // (Re)wire stdout before starting so we never miss the engine's first
      // lines. Guard against closed controller during teardown races.
      await _stdoutSubscription?.cancel();
      _stdoutSubscription = _stockfish.stdout.listen((line) {
        if (!_outputController.isClosed) _outputController.add(line);
      });

      _stockfish.state.removeListener(_onStateChanged);
      _stockfish.state.addListener(_onStateChanged);

      final engineState = _stockfish.state.value;
      if (engineState == StockfishState.ready) {
        // Native engine already running — reuse it rather than spawning a
        // second one on top of it.
        _setEngineReady();
        _isInit = true;
      } else if (engineState == StockfishState.initial ||
          engineState == StockfishState.error) {
        // Start with one retry: on low-end devices a cold start can exceed
        // multistockfish's fixed 5s timeout, and a second attempt (with the
        // binary now warm) usually succeeds.
        var started = false;
        for (var attempt = 0; attempt < 2 && !started; attempt++) {
          try {
            await _stockfish.start();
            started = _stockfish.state.value == StockfishState.ready;
          } on TimeoutException catch (e) {
            debugPrint('Stockfish start timed out (attempt ${attempt + 1}): $e');
            try {
              await _stockfish.quit().timeout(const Duration(seconds: 2));
            } catch (_) {}
          }
        }
        if (started) _setEngineReady();
        _isInit = started;
      } else {
        // `starting`: _onStateChanged finishes wiring up when ready.
        _isInit = true;
      }
    } on StateError catch (e) {
      // start() throws if the engine is already running; treat as ready.
      debugPrint('Stockfish already running: $e');
      if (_stockfish.state.value == StockfishState.ready) {
        _setEngineReady();
      }
      _isInit = true;
    } catch (e) {
      debugPrint('Stockfish init error: $e');
      _isInit = false;
    } finally {
      _isInitializing = false;
    }
  }

  void _setEngineReady() {
    if (!_isSupportedPlatform) return;
    if (!engineAvailableNotifier.value) {
      _safeWrite('setoption name MultiPV value $_multiPv');
      _safeWrite('isready');
      engineAvailableNotifier.value = true;
      debugPrint('Stockfish: Native bridge is fully READY');
    }
  }

  void _onStateChanged() {
    if (!_isSupportedPlatform) return;
    final state = _stockfish.state.value;
    if (state == StockfishState.ready) {
      _setEngineReady();
      if (_pendingCommand != null) {
        final command = _pendingCommand!;
        _pendingCommand = null;
        command();
      }
    } else if (state == StockfishState.error) {
      engineAvailableNotifier.value = false;
    }
  }

  void _safeWrite(String command) {
    if (!_isSupportedPlatform) return;
    try {
      // Direct FFI access: only call if state is ready to avoid Release crash
      if (_stockfish.state.value == StockfishState.ready) {
        _stockfish.stdin = command;
      } else {
        debugPrint(
          'Stockfish: Blocked stdin write while state is ${_stockfish.state.value}',
        );
      }
    } catch (e) {
      debugPrint('Stockfish FFI Write Error: $e');
    }
  }

  void updateOptions({int? multiPv}) {
    if (multiPv != null && multiPv != _multiPv) {
      _multiPv = multiPv;
      if (_isSupportedPlatform) {
        _sendWhenReady(() {
          _safeWrite('setoption name MultiPV value $_multiPv');
          _safeWrite('isready');
        });
      }
    }
  }

  void startAnalysis(String fen) {
    if (!_isSupportedPlatform) {
      _fallbackAnalysisTimer?.cancel();
      _fallbackAnalysisTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) {
        _outputController.add('info depth 10 score cp 0 pv e2e4');
      });
      return;
    }
    _sendWhenReady(() {
      _safeWrite('stop');
      _safeWrite('position fen $fen');
      _safeWrite('go depth 20');
    });
  }

  void playMove(String fen, int elo) {
    if (!_isSupportedPlatform) {
      _fallbackMoveTimer?.cancel();
      _fallbackMoveTimer = Timer(const Duration(milliseconds: 500), () {
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
            final checks = moves
                .where((m) => position.play(m).isCheck)
                .toList();
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
      });
      return;
    }

    _sendWhenReady(() {
      // UCI_LimitStrength + UCI_Elo alone drive playing strength. Skill Level
      // is a separate (weaker) knob that fights UCI_Elo when both are set, so
      // it must stay unset while strength-limiting is active.
      final clampedElo = elo.clamp(1320, 3190);

      _safeWrite('stop');
      _safeWrite('setoption name UCI_LimitStrength value true');
      _safeWrite('setoption name UCI_Elo value $clampedElo');
      _safeWrite('position fen $fen');
      _safeWrite('go movetime 1000'); // Think for 1 second
    });
  }

  void _sendWhenReady(void Function() send) {
    if (_stockfish.state.value == StockfishState.ready) {
      send();
    } else {
      _pendingCommand = send;
    }
  }

  void stopAnalysis() {
    if (!_isSupportedPlatform) {
      _fallbackAnalysisTimer?.cancel();
      _fallbackAnalysisTimer = null;
      return;
    }
    if (_stockfish.state.value == StockfishState.ready) {
      _safeWrite('stop');
    }
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
    _pendingCommand = null;

    if (_isSupportedPlatform) {
      try {
        _stockfish.state.removeListener(_onStateChanged);
        await _stdoutSubscription?.cancel();
        _stdoutSubscription = null;
        // Sends `quit`, which lets both engine isolates exit their loops.
        await _stockfish.quit().timeout(const Duration(seconds: 2));
      } catch (e) {
        debugPrint('Stockfish shutdown error: $e');
      }
    }

    engineAvailableNotifier.value = false;
    _isInit = false;
    _isInitializing = false;
  }
}
