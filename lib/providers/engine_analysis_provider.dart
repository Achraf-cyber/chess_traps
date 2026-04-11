import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/chess_engine_service.dart';

part 'engine_analysis_provider.g.dart';

class EngineAnalysisState {
  const EngineAnalysisState({
    required this.fen,
    this.scoreInCentipawns = 0,
    this.mateIn,
    this.multiPv = const {},
    this.depth = 0,
  });
  final String fen;
  final double scoreInCentipawns;
  final int? mateIn;
  final Map<int, List<String>> multiPv;
  final int depth;

  EngineAnalysisState copyWith({
    String? fen,
    double? scoreCp,
    int? mateIn,
    bool clearMate = false,
    Map<int, List<String>>? multiPv,
    int? depth,
  }) {
    return EngineAnalysisState(
      fen: fen ?? this.fen,
      scoreInCentipawns: scoreCp ?? scoreInCentipawns,
      mateIn: clearMate ? null : (mateIn ?? this.mateIn),
      multiPv: multiPv ?? this.multiPv,
      depth: depth ?? this.depth,
    );
  }

  double get displayScore {
    if (mateIn != null) {
      return mateIn! > 0 ? 10.0 : -10.0;
    }
    return (scoreInCentipawns / 100.0).clamp(-10.0, 10.0);
  }
}

@Riverpod(keepAlive: true)
ChessEngineService chessEngineService(Ref ref) {
  final service = ChessEngineService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
}

@riverpod
class EngineAnalysis extends _$EngineAnalysis {
  StreamSubscription<String>? _sub;
  Timer? _throttleTimer;
  EngineAnalysisState? _pendingState;

  @override
  EngineAnalysisState build(String fen) {
    final service = ref.watch(chessEngineServiceProvider);
    _sub?.cancel();
    _throttleTimer?.cancel();
    _sub = service.engineOutput.listen(_onLine);

    ref.onDispose(() {
      _sub?.cancel();
      _throttleTimer?.cancel();
    });

    Future.microtask(() => service.startAnalysis(fen));

    return EngineAnalysisState(fen: fen);
  }

  void _onLine(String line) {
    try {
      if (!line.startsWith('info') ||
          !line.contains('score') ||
          !line.contains(' pv ')) {
        return;
      }

      int? depth;
      int multipv = 1;
      double? cp;
      int? mate;
      List<String> pv = [];

      final parts = line.split(' ');
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];
        if (i + 1 >= parts.length) continue; // Safety check

        switch (part) {
          case 'depth':
            depth = int.tryParse(parts[i + 1]);
          case 'multipv':
            multipv = int.tryParse(parts[i + 1]) ?? 1;
          case 'score':
            if (i + 2 < parts.length) {
              if (parts[i + 1] == 'cp') {
                cp = double.tryParse(parts[i + 2]);
              } else if (parts[i + 1] == 'mate') {
                mate = int.tryParse(parts[i + 2]);
              }
            }
          case 'pv':
            pv = parts.sublist(i + 1);
        }
      }

      if (pv.isEmpty) return;

      final currentFenParts = state.fen.split(' ');
      final isWhiteToMove =
          currentFenParts.length > 1 && currentFenParts[1] == 'w';
      final sign = isWhiteToMove ? 1.0 : -1.0;

      final targetState = _pendingState ?? state;
      final pvMap = Map<int, List<String>>.from(targetState.multiPv)
        ..[multipv] = pv;

      _pendingState = targetState.copyWith(
        scoreCp: cp != null ? cp * sign : targetState.scoreInCentipawns,
        mateIn: mate != null ? (mate * sign).round() : null,
        clearMate: mate == null && cp != null,
        multiPv: pvMap,
        depth: depth ?? targetState.depth,
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
