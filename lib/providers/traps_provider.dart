import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chess_trap.dart';

final trapsProvider = FutureProvider<List<ChessTrap>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/chess/g700.json');
  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  
  final List<ChessTrap> allTraps = [];
  for (var section in jsonList) {
    if (section is List) {
      for (var trapJson in section) {
        allTraps.add(ChessTrap.fromJson(trapJson as Map<String, dynamic>));
      }
    }
  }
  return allTraps;
});
