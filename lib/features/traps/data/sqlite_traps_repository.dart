import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'chess_trap.dart';
import 'traps_repository.dart';

class SqliteTrapsRepository implements TrapsRepository {
  Database? _db;

  Future<Database> _getDatabase() async {
    if (_db != null) {
      return _db!;
    }

    // Initialize FFI for desktop if needed
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String dbPath = await getDatabasesPath();
    final String path = join(dbPath, 'traps.db');

    // Check if the database exists
    final bool exists = await databaseExists(path);

    if (!exists) {
      // Copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      final ByteData data = await rootBundle.load(join('assets', 'chess', 'traps.db'));
      final Uint8List bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(path);
    return _db!;
  }

  @override
  Future<List<ChessTrap>> loadTraps() async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('chess_traps');

    return List.generate(maps.length, (i) {
      return ChessTrap.fromJson(maps[i]);
    });
  }
}
