import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_provider.g.dart';

/// Board theme options (mapped from chessground color schemes).
enum AppBoardTheme {
  brown('Brown'),
  blue('Blue'),
  green('Green'),
  wood('Wood'),
  wood2('Wood II'),
  metal('Metal'),
  marble('Marble'),
  horsey('Horsey'),
  purple('Purple');

  const AppBoardTheme(this.label);
  final String label;

  cg.ChessboardColorScheme get colorScheme {
    switch (this) {
      case AppBoardTheme.brown:  return cg.ChessboardColorScheme.brown;
      case AppBoardTheme.blue:   return cg.ChessboardColorScheme.blue;
      case AppBoardTheme.green:  return cg.ChessboardColorScheme.green;
      case AppBoardTheme.wood:   return cg.ChessboardColorScheme.wood;
      case AppBoardTheme.wood2:  return cg.ChessboardColorScheme.wood2;
      case AppBoardTheme.metal:  return cg.ChessboardColorScheme.metal;
      case AppBoardTheme.marble: return cg.ChessboardColorScheme.marble;
      case AppBoardTheme.horsey: return cg.ChessboardColorScheme.horsey;
      case AppBoardTheme.purple: return cg.ChessboardColorScheme.purple;
    }
  }
}

class ChessSettings {
  const ChessSettings({
    this.arrowCount = 2,
    this.boardTheme = AppBoardTheme.brown,
    this.localeCode,
  });

  final int arrowCount;
  final AppBoardTheme boardTheme;
  final String? localeCode;

  ChessSettings copyWith({
    int? arrowCount,
    AppBoardTheme? boardTheme,
    String? localeCode,
  }) =>
      ChessSettings(
        arrowCount: arrowCount ?? this.arrowCount,
        boardTheme: boardTheme ?? this.boardTheme,
        localeCode: localeCode ?? this.localeCode,
      );
}

@Riverpod(keepAlive: true)
class ChessSettingsNotifier extends _$ChessSettingsNotifier {
  static const _arrowCountKey = 'arrowCount';
  static const _boardThemeKey = 'boardTheme';
  static const _localeKey = 'appLocale';

  @override
  ChessSettings build() {
    _loadPrefs();
    return const ChessSettings();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final arrowCount = prefs.getInt(_arrowCountKey) ?? 2;
    final localeCode = prefs.getString(_localeKey);
    final themeStr = prefs.getString(_boardThemeKey);
    final theme = themeStr != null
        ? AppBoardTheme.values.firstWhere(
            (t) => t.name == themeStr,
            orElse: () => AppBoardTheme.brown,
          )
        : AppBoardTheme.brown;

    state = ChessSettings(
      arrowCount: arrowCount,
      boardTheme: theme,
      localeCode: localeCode,
    );
  }

  Future<void> updateArrowCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_arrowCountKey, count);
    state = state.copyWith(arrowCount: count);
  }

  Future<void> updateBoardTheme(AppBoardTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_boardThemeKey, theme.name);
    state = state.copyWith(boardTheme: theme);
  }

  Future<void> updateLocale(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, code);
    }
    state = state.copyWith(localeCode: code);
  }
}
