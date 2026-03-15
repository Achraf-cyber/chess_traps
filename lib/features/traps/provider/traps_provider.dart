import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/chess_trap.dart';
import '../data/sqlite_traps_repository.dart';
import '../data/traps_repository.dart';

part 'traps_provider.g.dart';

@riverpod
TrapsRepository trapsRepository(Ref ref) {
  // Switch to SqliteTrapsRepository() here to use the database backend
  return SqliteTrapsRepository();
}

@Riverpod(keepAlive: true)
Future<List<ChessTrap>> traps(Ref ref) async {
  final TrapsRepository repository = ref.watch(trapsRepositoryProvider);
  return repository.loadTraps();
}
