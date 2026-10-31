/// One parsed UCI `info` line carrying a score.
class UciInfo {
  const UciInfo({
    required this.multiPv,
    required this.pv,
    this.depth,
    this.cp,
    this.mate,
  });

  final int? depth;

  /// 1 is the engine's best line; higher numbers are progressively worse
  /// alternatives. Only line 1 is the evaluation of the position.
  final int multiPv;

  /// Score relative to the side to move.
  final double? cp;

  /// Moves to mate, relative to the side to move: positive means the side to
  /// move mates, negative that it gets mated, 0 that it already is mated.
  final int? mate;

  final List<String> pv;

  /// Parses [line], or returns null if it isn't a usable score: not an `info`
  /// line, no score, or a `lowerbound`/`upperbound` score, which is only a
  /// fail-high/low limit from an aspiration window and not an evaluation.
  ///
  /// A mated position is the one case accepted without a `pv`: the engine
  /// reports it as `info depth 0 score mate 0`.
  static UciInfo? parse(String line) {
    final tokens = line.split(' ');
    if (tokens.first != 'info') return null;

    int? depth;
    int multiPv = 1;
    double? cp;
    int? mate;
    List<String> pv = const [];

    for (int i = 1; i < tokens.length; i++) {
      final hasValue = i + 1 < tokens.length;
      switch (tokens[i]) {
        case 'string':
          return null;
        case 'depth' when hasValue:
          depth = int.tryParse(tokens[i + 1]);
        case 'multipv' when hasValue:
          multiPv = int.tryParse(tokens[i + 1]) ?? 1;
        case 'cp' when hasValue:
          cp = double.tryParse(tokens[i + 1]);
        case 'mate' when hasValue:
          mate = int.tryParse(tokens[i + 1]);
        case 'lowerbound' || 'upperbound':
          return null;
        case 'pv':
          pv = tokens.sublist(i + 1);
          i = tokens.length;
      }
    }

    if (cp == null && mate == null) return null;
    if (pv.isEmpty && mate != 0) return null;
    return UciInfo(depth: depth, multiPv: multiPv, cp: cp, mate: mate, pv: pv);
  }
}

/// True if it is white's turn in [fen].
bool isWhiteToMove(String fen) {
  final parts = fen.split(' ');
  return parts.length < 2 || parts[1] == 'w';
}

/// Runs engine searches one at a time, so output always belongs to the search
/// it is attributed to.
///
/// UCI is a single stream with no request ids. After `stop`, the old search
/// still prints its last lines and a `bestmove`, and all of that arrives after
/// the app has moved on to another position; `setoption` is also only safe
/// between searches. So a new search is held back until the previous one has
/// answered with `bestmove`, and whatever an abandoned search prints is
/// dropped here rather than reaching anyone listening.
class UciSearchQueue {
  UciSearchQueue({required this.write, required this.emit});

  final void Function(String command) write;
  final void Function(String line) emit;

  bool _searching = false;
  bool _abandoning = false;
  ({String fen, List<String> commands})? _next;

  /// Position of the search whose output is currently being emitted.
  String? fen;

  /// Runs [commands], the last of which must be a `go`, as the search of [fen],
  /// replacing any search already running or queued.
  void start(String fen, List<String> commands) {
    if (!_searching) {
      _launch(fen, commands);
      return;
    }
    _next = (fen: fen, commands: commands);
    _abandon();
  }

  /// Abandons the current search. It will not produce a `bestmove`.
  void stop() {
    _next = null;
    if (_searching) _abandon();
  }

  void onLine(String line) {
    if (!line.startsWith('bestmove')) {
      if (_searching && !_abandoning) emit(line);
      return;
    }

    final abandoned = _abandoning;
    _searching = false;
    _abandoning = false;
    if (!abandoned) emit(line);

    final next = _next;
    if (next != null) {
      _next = null;
      _launch(next.fen, next.commands);
    }
  }

  /// Forgets everything; the engine these searches ran on is gone.
  void reset() {
    _searching = false;
    _abandoning = false;
    _next = null;
    fen = null;
  }

  void _launch(String fen, List<String> commands) {
    this.fen = fen;
    _searching = true;
    commands.forEach(write);
  }

  void _abandon() {
    if (_abandoning) return;
    _abandoning = true;
    write('stop');
  }
}
