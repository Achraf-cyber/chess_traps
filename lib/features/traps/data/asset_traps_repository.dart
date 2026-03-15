import 'dart:convert';
import 'package:flutter/services.dart';

import 'chess_trap.dart';
import 'traps_repository.dart';

class AssetTrapsRepository implements TrapsRepository {
  @override
  Future<List<ChessTrap>> loadTraps() async {
    final String jsonString = await rootBundle.loadString('assets/chess/g700.json');
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    
    final List<ChessTrap> allTraps = [];
    for (final section in jsonList) {
      if (section is List) {
        for (var i = 0; i < section.length; i++) {
          final dynamic trapJson = section[i];
          allTraps.add(ChessTrap.fromJson(trapJson as Map<String, dynamic>));
        }
      }
    }
    return allTraps;
  }
}
