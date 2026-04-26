import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:stockfish/stockfish.dart';

class ChessEngineService {
  final Stockfish _stockfish = Stockfish();
  final _outputController = StreamController<String>.broadcast();
  Stream<String> get engineOutput => _outputController.stream;
  StreamSubscription<String>? _stdoutSubscription;

  bool _isInit = false;
  // This notifier allows the UI to wait indefinitely for the slow extraction
  final ValueNotifier<bool> engineAvailableNotifier = ValueNotifier(false);

  bool get engineAvailable => engineAvailableNotifier.value;
  final int _multiPv = 2;
  void Function()? _pendingCommand;

  Future<void> init() async {
    if (_isInit) return;
    _isInit = true;

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
    } catch (e) {
      debugPrint('Stockfish init error: $e');
      _isInit = false; // Allow retry on fatal error
    }
  }

  void _setEngineReady() {
    if (!engineAvailableNotifier.value) {
      _safeWrite('setoption name MultiPV value $_multiPv');
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

  void startAnalysis(String fen) {
    _sendWhenReady(() {
      _safeWrite('stop');
      _safeWrite('position fen $fen');
      _safeWrite('go depth 20');
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
    stopAnalysis();
    _stockfish.state.removeListener(_onStateChanged);
    _stdoutSubscription?.cancel();
    _outputController.close();
    engineAvailableNotifier.dispose();
  }
}
