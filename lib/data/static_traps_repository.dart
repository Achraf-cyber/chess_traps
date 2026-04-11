import 'package:chess_traps/generated/chess/base_chess_traps.dart';

import 'chess_trap.dart';
import 'traps_repository.dart';

class StaticTrapsRepository implements TrapsRepository {
  @override
  Future<List<ChessTrap>> loadTraps() async => chessTraps;
}
