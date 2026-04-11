import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:multistockfish/multistockfish.dart';

class ChessEngineService {
  Stockfish get _stockfish => Stockfish.instance;

  final _outputController = StreamController<String>.broadcast();
  Stream<String> get engineOutput => _outputController.stream;

  StreamSubscription<String>? _stdoutSubscription;
  bool _isInit = false;
  int _multiPv = 2;

  void init() {
    if (_isInit) return;
    try {
      _stdoutSubscription = _stockfish.stdout.listen((line) {
        _outputController.add(line);
      });

      // Start engine asynchronously and send UCI options once ready
      _stockfish.start().then((_) {
        _stockfish.stdin = 'setoption name MultiPV value $_multiPv';
        _isInit = true;
      }).catchError((Object e) {
        debugPrint('Stockfish start error: $e');
      });
    } catch (e) {
      debugPrint('Failed to initialize Stockfish: $e');
    }
  }

  void startAnalysis(String fen) {
    _sendWhenReady(() {
      _stockfish.stdin = 'stop';
      _stockfish.stdin = 'position fen $fen';
      _stockfish.stdin = 'go depth 20';
    });
  }

  void setMultiPv(int count) {
    _multiPv = count;
    _sendWhenReady(() {
      _stockfish.stdin = 'stop';
      _stockfish.stdin = 'setoption name MultiPV value $count';
    });
  }

  void Function()? _pendingCommand;

  /// Sends commands only if the engine is in the ready state.
  void _sendWhenReady(void Function() send) {
    if (_stockfish.state.value == StockfishState.ready) {
      _pendingCommand = null;
      send();
    } else {
      // Store only the latest command
      _pendingCommand = send;
      
      // Listen for state change and then send the latest pending command
      void listener() {
        if (_stockfish.state.value == StockfishState.ready) {
          _stockfish.state.removeListener(listener);
          if (_pendingCommand != null) {
            _pendingCommand!();
            _pendingCommand = null;
          }
        }
      }
      _stockfish.state.addListener(listener);
    }
  }

  void stopAnalysis() {
    if (_stockfish.state.value == StockfishState.ready) {
      _stockfish.stdin = 'stop';
    }
  }

  void dispose() {
    stopAnalysis();
    _stdoutSubscription?.cancel();
    _outputController.close();
    _isInit = false;
  }
}
