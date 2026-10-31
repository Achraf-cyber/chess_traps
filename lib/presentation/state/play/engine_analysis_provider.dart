import 'dart:async';
import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chess_traps/core/services/chess_engine_service.dart';
import 'package:chess_traps/core/services/uci.dart';

part 'engine_analysis_provider.g.dart';

class EngineAnalysisState {
  const EngineAnalysisState({
    required this.fen,
    this.scoreInCentipawns = 0,
    this.mateIn,
    this.multiPv = const {},
    this.depth = 0,
    this.engineAvailable = true,
  });

  final String fen;
  final double scoreInCentipawns;
  final int? mateIn;
  final Map<int, List<String>> multiPv;
  final int depth;
  final bool engineAvailable;

  EngineAnalysisState copyWith({
    String? fen,
    double? scoreCp,
    int? mateIn,
    bool clearMate = false,
    Map<int, List<String>>? multiPv,
    int? depth,
    bool? engineAvailable,
  }) {
    return EngineAnalysisState(
      fen: fen ?? this.fen,
      scoreInCentipawns: scoreCp ?? scoreInCentipawns,
      mateIn: clearMate ? null : (mateIn ?? this.mateIn),
      multiPv: multiPv ?? this.multiPv,
      depth: depth ?? this.depth,
      engineAvailable: engineAvailable ?? this.engineAvailable,
    );
  }

  /// The evaluation as shown to the user: `M3` for a forced mate, `#` once it's
  /// on the board, otherwise pawns like `+1.2`.
  String get displayLabel {
    final mate = mateIn;
    if (mate == 0) return '#';
    if (mate != null) return 'M${mate.abs()}';
    final pawns = (scoreInCentipawns / 100.0).toStringAsFixed(1);
    return scoreInCentipawns > 0 ? '+$pawns' : pawns;
  }

  double get displayScore {
    // Mate 0 has no sign of its own: the side to move is the one mated.
    if (mateIn == 0) return isWhiteToMove(fen) ? -10.0 : 10.0;
    if (mateIn != null) return mateIn! > 0 ? 10.0 : -10.0;
    return (scoreInCentipawns / 100.0).clamp(-10.0, 10.0);
  }
}

// Kept alive for the whole app run: the engine is expensive to start (it can
// take several seconds on low-end devices) and multistockfish only allows one
// live engine per flavor, so tearing it down and restarting on navigation
// causes start-timeouts and an engine that never stabilises.
@Riverpod(keepAlive: true)
ChessEngineService chessEngine(Ref ref) {
  final service = ChessEngineService();
  service.init().catchError((Object e) {
    debugPrint('Engine init failed: $e');
  });

  ref.onDispose(() {
    service.shutdown();
  });

  return service;
}

@riverpod
class EngineAnalysis extends _$EngineAnalysis {
  StreamSubscription<String>? _sub;
  Timer? _throttleTimer;
  EngineAnalysisState? _pendingState;
  Timer? _analysisDebounceTimer;

  @override
  EngineAnalysisState build(String fen) {
    final service = ref.watch(chessEngineProvider);
    final isReady = _watchValueListenable(service.engineAvailableNotifier);

    // Sync MultiPV with settings
    final settings = ref.watch(chessSettingsProvider);
    service.updateOptions(multiPv: settings.arrowCount);

    if (!isReady) {
      // Retries a start that failed; a no-op while one is in progress.
      service.init();
      return EngineAnalysisState(fen: fen, engineAvailable: false);
    }

    _sub?.cancel();
    _throttleTimer?.cancel();
    _analysisDebounceTimer?.cancel();
    _sub = service.engineOutput.listen(_onLine);

    ref.onDispose(() {
      _sub?.cancel();
      _throttleTimer?.cancel();
      _analysisDebounceTimer?.cancel();
    });

    _analysisDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      service.startAnalysis(fen);
    });

    return EngineAnalysisState(fen: fen);
  }

  T _watchValueListenable<T>(ValueListenable<T> listenable) {
    void listener() => ref.invalidateSelf();
    listenable.addListener(listener);
    ref.onDispose(() => listenable.removeListener(listener));
    return listenable.value;
  }

  void _onLine(String line) {
    try {
      // A search still winding down from the previous position, or one that
      // isn't this provider's at all.
      if (ref.read(chessEngineProvider).searchFen != state.fen) return;

      final info = UciInfo.parse(line);
      if (info == null) return;

      // Scores are relative to the side to move; this state is white-relative.
      final sign = isWhiteToMove(state.fen) ? 1 : -1;
      final targetState = _pendingState ?? state;

      // Every MultiPV line carries its own score, but only line 1 evaluates
      // the position. Taking them all let a weaker alternative's rating
      // overwrite the mate found by the best line.
      final isBestLine = info.multiPv == 1;
      final mate = info.mate;
      final cp = info.cp;

      _pendingState = targetState.copyWith(
        scoreCp: isBestLine && cp != null ? cp * sign : null,
        mateIn: isBestLine && mate != null ? mate * sign : null,
        clearMate: isBestLine && mate == null,
        multiPv: info.pv.isEmpty
            ? null
            : (Map<int, List<String>>.from(targetState.multiPv)
                ..[info.multiPv] = info.pv),
        depth: info.depth,
      );

      if (_throttleTimer == null || !_throttleTimer!.isActive) {
        _throttleTimer = Timer(const Duration(milliseconds: 150), () {
          if (_pendingState != null) {
            state = _pendingState!;
            _pendingState = null;
          }
        });
      }
    } catch (e, stack) {
      debugPrint('Error parsing engine output: $e\n$stack');
    }
  }
}
