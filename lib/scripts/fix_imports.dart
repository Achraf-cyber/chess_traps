import 'dart:io';

void main() {
  final dirs = [Directory('lib'), Directory('scripts')];
  for (final dir in dirs) {
    if (!dir.existsSync()) continue;
    final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    
    for (final file in files) {
      String content = file.readAsStringSync();
      bool modified = false;

      // Fix specific relative imports that were broken
      if (content.contains("import 'package:chess_traps/data/play/chess_move_node.dart';")) {
        content = content.replaceAll("import 'package:chess_traps/data/play/chess_move_node.dart';", "import 'package:chess_traps/data/play/chess_move_node.dart';");
        modified = true;
      }
      if (content.contains("import 'package:chess_traps/data/traps/chess_trap.dart';")) {
        content = content.replaceAll("import 'package:chess_traps/data/traps/chess_trap.dart';", "import 'package:chess_traps/data/traps/chess_trap.dart';");
        modified = true;
      }
      if (content.contains("import 'package:chess_traps/core/services/interstitial_ad_manager.dart';")) {
        content = content.replaceAll("import 'package:chess_traps/core/services/interstitial_ad_manager.dart';", "import 'package:chess_traps/core/services/interstitial_ad_manager.dart';");
        modified = true;
      }
      
      // Fix imports in scripts folder
      if (file.path.startsWith('scripts')) {
        content = content.replaceAll('package:chess_traps/data/openings.dart', 'package:chess_traps/data/traps/openings.dart');
        content = content.replaceAll('package:chess_traps/data/chess_move_node.dart', 'package:chess_traps/data/play/chess_move_node.dart');
        modified = true;
      }
      
      if (modified) {
        file.writeAsStringSync(content);
      }
    }
  }
}
