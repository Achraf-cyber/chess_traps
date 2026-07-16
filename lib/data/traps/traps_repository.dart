import 'chess_trap.dart';

abstract class TrapsRepository {
  Future<List<ChessTrap>> loadTraps();
}
