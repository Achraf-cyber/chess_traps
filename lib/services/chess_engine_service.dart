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

      // Listen for the "ready" state centrally to process pending commands
      _stockfish.state.addListener(_onStateChanged);

      // Start engine asynchronously and send UCI options once ready
      _stockfish.start().then((_) {
        _safeWrite('setoption name MultiPV value $_multiPv');
        _isInit = true;
      }).catchError((Object e) {
        debugPrint('Stockfish start error: $e');
      });
    } catch (e) {
      debugPrint('Failed to initialize Stockfish: $e');
    }
  }

  void _onStateChanged() {
    if (_stockfish.state.value == StockfishState.ready && _pendingCommand != null) {
      final command = _pendingCommand!;
      _pendingCommand = null;
      try {
        command();
      } catch (e) {
        debugPrint('Error executing pending command: $e');
      }
    }
  }

  void _safeWrite(String command) {
    try {
      _stockfish.stdin = command;
    } catch (e) {
      debugPrint('Error writing to engine stdin: $e');
    }
  }

  void startAnalysis(String fen) {
    _sendWhenReady(() {
      _safeWrite('stop');
      _safeWrite('position fen $fen');
      _safeWrite('go depth 20');
    });
  }

  void setMultiPv(int count) {
    _multiPv = count;
    _sendWhenReady(() {
      _safeWrite('stop');
      _safeWrite('setoption name MultiPV value $count');
    });
  }

  void Function()? _pendingCommand;

  /// Stores the command to be sent once the engine is ready.
  void _sendWhenReady(void Function() send) {
    if (_stockfish.state.value == StockfishState.ready) {
      _pendingCommand = null;
      try {
        send();
      } catch (e) {
        debugPrint('Error sending ready command: $e');
      }
    } else {
      // Store only the latest command
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
    _stdoutSubscription?.cancel();
    _outputController.close();
    _isInit = false;
  }
}
