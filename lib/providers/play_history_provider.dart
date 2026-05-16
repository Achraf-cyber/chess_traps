import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'play_history_provider.g.dart';

class PlayHistory {
  const PlayHistory({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
  });

  final int wins;
  final int losses;
  final int draws;

  PlayHistory copyWith({int? wins, int? losses, int? draws}) => PlayHistory(
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        draws: draws ?? this.draws,
      );
}

@Riverpod(keepAlive: true)
class PlayHistoryNotifier extends _$PlayHistoryNotifier {
  static const _winsKey = 'playWins';
  static const _lossesKey = 'playLosses';
  static const _drawsKey = 'playDraws';

  @override
  PlayHistory build() {
    _loadPrefs();
    return const PlayHistory();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = PlayHistory(
      wins: prefs.getInt(_winsKey) ?? 0,
      losses: prefs.getInt(_lossesKey) ?? 0,
      draws: prefs.getInt(_drawsKey) ?? 0,
    );
  }

  Future<void> addWin() async {
    final prefs = await SharedPreferences.getInstance();
    final newWins = state.wins + 1;
    await prefs.setInt(_winsKey, newWins);
    state = state.copyWith(wins: newWins);
  }

  Future<void> addLoss() async {
    final prefs = await SharedPreferences.getInstance();
    final newLosses = state.losses + 1;
    await prefs.setInt(_lossesKey, newLosses);
    state = state.copyWith(losses: newLosses);
  }

  Future<void> addDraw() async {
    final prefs = await SharedPreferences.getInstance();
    final newDraws = state.draws + 1;
    await prefs.setInt(_drawsKey, newDraws);
    state = state.copyWith(draws: newDraws);
  }

  Future<void> resetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_winsKey);
    await prefs.remove(_lossesKey);
    await prefs.remove(_drawsKey);
    state = const PlayHistory();
  }
}
