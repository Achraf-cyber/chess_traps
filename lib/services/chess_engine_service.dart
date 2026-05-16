import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

class ChessEngineService {
  factory ChessEngineService() => _instance;
  ChessEngineService._internal();

  static final ChessEngineService _instance = ChessEngineService._internal();

  final Stockfish _stockfish = Stockfish();
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

  Future<void> init() async {
    if (_isInit || _isInitializing) return;
    _isInitializing = true;

    try {
      _stdoutSubscription = _stockfish.stdout.listen((line) {
        _outputController.add(line);
      });

      _stockfish.state.addListener(_onStateChanged);

      if (_stockfish.state.value == StockfishState.ready) {
        _setEngineReady();
      } else {
        debugPrint('Stockfish: waiting for ready state...');
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
    if (!engineAvailableNotifier.value) {
      _safeWrite('setoption name MultiPV value $_multiPv');
      _safeWrite('isready');
      engineAvailableNotifier.value = true;
      debugPrint('Stockfish: Native bridge is fully READY');
    }
  }

  void _onStateChanged() {
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
      _sendWhenReady(() {
        _safeWrite('setoption name MultiPV value $_multiPv');
        _safeWrite('isready');
      });
    }
  }

  void startAnalysis(String fen) {
    _sendWhenReady(() {
      _safeWrite('stop');
      _safeWrite('position fen $fen');
      _safeWrite('go depth 20');
    });
  }

  void playMove(String fen, int elo) {
    _sendWhenReady(() {
      // Map Elo (800-3200) to Skill Level (0-20)
      final skillLevel = ((elo - 800) / (3200 - 800) * 20).round().clamp(0, 20);

      _safeWrite('stop');
      _safeWrite('setoption name UCI_LimitStrength value true');
      _safeWrite('setoption name UCI_Elo value $elo');
      _safeWrite('setoption name Skill Level value $skillLevel');
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
    if (_stockfish.state.value == StockfishState.ready) {
      _safeWrite('stop');
    }
  }

  void dispose() {
    try {
      stopAnalysis();
      _stockfish.state.removeListener(_onStateChanged);
      _stdoutSubscription?.cancel();
      _stdoutSubscription = null;
      _outputController.close();
      engineAvailableNotifier.dispose();
      _stockfish.dispose();
    } catch (e) {
      debugPrint('Error disposing ChessEngineService: $e');
    }
  }
}
