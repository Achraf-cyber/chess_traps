import 'package:chess_traps/core/services/uci.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UciInfo.parse', () {
    test('reads a centipawn score', () {
      final info = UciInfo.parse(
        'info depth 14 seldepth 20 multipv 2 score cp -35 nodes 1 nps 1 '
        'hashfull 0 time 1 pv e2e4 e7e5',
      )!;
      expect(info.depth, 14);
      expect(info.multiPv, 2);
      expect(info.cp, -35);
      expect(info.mate, isNull);
      expect(info.pv, ['e2e4', 'e7e5']);
    });

    test('reads a mate score', () {
      final info = UciInfo.parse('info depth 9 multipv 1 score mate -3 pv a2a3')!;
      expect(info.mate, -3);
      expect(info.cp, isNull);
    });

    test('accepts a mated position, which has no pv', () {
      expect(UciInfo.parse('info depth 0 score mate 0')!.mate, 0);
    });

    test('ignores bound scores', () {
      expect(UciInfo.parse('info depth 9 score cp 20 lowerbound pv a2a3'), isNull);
      expect(UciInfo.parse('info depth 9 score mate 2 upperbound pv a2a3'), isNull);
    });

    test('ignores lines that are not scores', () {
      expect(UciInfo.parse('bestmove e2e4'), isNull);
      expect(UciInfo.parse('info string NNUE evaluation enabled'), isNull);
      expect(UciInfo.parse('info depth 9 currmove e2e4 currmovenumber 1'), isNull);
      expect(UciInfo.parse('info depth 9 score cp 20'), isNull);
    });
  });

  group('UciSearchQueue', () {
    late List<String> written;
    late List<String> emitted;
    late UciSearchQueue queue;

    setUp(() {
      written = [];
      emitted = [];
      queue = UciSearchQueue(write: written.add, emit: emitted.add);
    });

    test('starts immediately when idle and forwards its output', () {
      queue.start('a', ['position a', 'go']);
      queue.onLine('info 1');
      queue.onLine('bestmove e2e4');
      expect(written, ['position a', 'go']);
      expect(emitted, ['info 1', 'bestmove e2e4']);
      expect(queue.fen, 'a');
    });

    test('holds a new search until the old one has finished', () {
      queue.start('a', ['go a']);
      queue.start('b', ['go b']);
      expect(written, ['go a', 'stop']);
      expect(queue.fen, 'a');

      queue.onLine('info stale');
      queue.onLine('bestmove stale');
      expect(emitted, isEmpty);
      expect(written, ['go a', 'stop', 'go b']);
      expect(queue.fen, 'b');

      queue.onLine('info fresh');
      expect(emitted, ['info fresh']);
    });

    test('only the latest of several queued searches runs', () {
      queue.start('a', ['go a']);
      queue.start('b', ['go b']);
      queue.start('c', ['go c']);
      queue.onLine('bestmove stale');
      expect(written, ['go a', 'stop', 'go c']);
    });

    test('stop swallows the bestmove and cancels what was queued', () {
      queue.start('a', ['go a']);
      queue.start('b', ['go b']);
      queue.stop();
      queue.onLine('bestmove stale');
      expect(written, ['go a', 'stop']);
      expect(emitted, isEmpty);
    });

    test('stop does nothing while idle', () {
      queue.stop();
      expect(written, isEmpty);
    });

    test('reset forgets a search that will never answer', () {
      queue.start('a', ['go a']);
      queue.reset();
      queue.start('b', ['go b']);
      expect(written, ['go a', 'go b']);
    });
  });
}
