import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    
    // Services
    content = content.replaceAll('package:chess_traps/core/services/', 'package:chess_traps/core/services/');
    
    // Core Providers
    content = content.replaceAll('package:chess_traps/core/providers/ads_provider', 'package:chess_traps/core/providers/ads_provider');
    content = content.replaceAll('package:chess_traps/core/providers/app_theme_provider', 'package:chess_traps/core/providers/app_theme_provider');
    content = content.replaceAll('package:chess_traps/core/providers/settings_provider', 'package:chess_traps/core/providers/settings_provider');
    content = content.replaceAll('package:chess_traps/core/providers/daily_limit_provider', 'package:chess_traps/core/providers/daily_limit_provider');
    
    // Play Providers
    content = content.replaceAll('package:chess_traps/presentation/state/play/play_history_provider', 'package:chess_traps/presentation/state/play/play_history_provider');
    content = content.replaceAll('package:chess_traps/presentation/state/play/engine_analysis_provider', 'package:chess_traps/presentation/state/play/engine_analysis_provider');
    
    // Traps Providers
    content = content.replaceAll('package:chess_traps/presentation/state/traps/traps_provider', 'package:chess_traps/presentation/state/traps/traps_provider');
    content = content.replaceAll('package:chess_traps/presentation/state/traps/traps_group_provider', 'package:chess_traps/presentation/state/traps/traps_group_provider');
    content = content.replaceAll('package:chess_traps/presentation/state/traps/trap_game_provider', 'package:chess_traps/presentation/state/traps/trap_game_provider');
    content = content.replaceAll('package:chess_traps/presentation/state/traps/learned_traps_provider', 'package:chess_traps/presentation/state/traps/learned_traps_provider');
    
    // Favorites Providers
    content = content.replaceAll('package:chess_traps/presentation/state/favorites/user_favorites_provider', 'package:chess_traps/presentation/state/favorites/user_favorites_provider');
    
    // Play Data
    content = content.replaceAll('package:chess_traps/data/play/chess_move_node.dart', 'package:chess_traps/data/play/chess_move_node.dart');
    
    // Traps Data
    content = content.replaceAll('package:chess_traps/data/traps/chess_trap.dart', 'package:chess_traps/data/traps/chess_trap.dart');
    content = content.replaceAll('package:chess_traps/data/traps/openings.dart', 'package:chess_traps/data/traps/openings.dart');
    content = content.replaceAll('package:chess_traps/data/traps/traps_repository.dart', 'package:chess_traps/data/traps/traps_repository.dart');
    content = content.replaceAll('package:chess_traps/data/traps/static_traps_repository.dart', 'package:chess_traps/data/traps/static_traps_repository.dart');
    
    // Search Data
    content = content.replaceAll('package:chess_traps/data/search_by_moves/chess_search.dart', 'package:chess_traps/data/search_by_moves/chess_search.dart');
    content = content.replaceAll('package:chess_traps/data/search_by_moves/fens.dart', 'package:chess_traps/data/search_by_moves/fens.dart');
    
    file.writeAsStringSync(content);
  }
}
