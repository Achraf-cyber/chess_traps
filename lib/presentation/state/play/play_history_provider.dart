import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedGame {
  SavedGame({
    required this.date,
    required this.result,
    required this.pgnMoves,
    this.mode = 'engine',
  });

  factory SavedGame.fromJson(Map<String, dynamic> json) => SavedGame(
    date: json['date'] as String,
    result: json['result'] as String,
    pgnMoves: List<String>.from(json['pgnMoves'] as List),
    // Backward compatible: games saved before local 1v1 existed have no
    // mode field and were all played against the engine.
    mode: (json['mode'] as String?) ?? 'engine',
  );

  final String date;

  /// For engine games: 'win' | 'loss' | 'draw' (relative to the user).
  /// For friend games: 'white' | 'black' | 'draw' (the winning side).
  final String result;
  final List<String> pgnMoves;

  /// 'engine' (vs Stockfish) or 'friend' (local pass-and-play).
  final String mode;

  bool get isFriendGame => mode == 'friend';

  Map<String, dynamic> toJson() => {
    'date': date,
    'result': result,
    'pgnMoves': pgnMoves,
    'mode': mode,
  };
}

class PlayHistory {
  const PlayHistory({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.savedGames = const [],
  });

  final int wins;
  final int losses;
  final int draws;
  final List<SavedGame> savedGames;

  PlayHistory copyWith({int? wins, int? losses, int? draws, List<SavedGame>? savedGames}) => PlayHistory(
        wins: wins ?? this.wins,
        losses: losses ?? this.losses,
        draws: draws ?? this.draws,
        savedGames: savedGames ?? this.savedGames,
      );
}

class PlayHistoryNotifier extends Notifier<PlayHistory> {
  static const _winsKey = 'playWins';
  static const _lossesKey = 'playLosses';
  static const _drawsKey = 'playDraws';
  static const _gamesKey = 'playSavedGames';

  @override
  PlayHistory build() {
    _loadPrefs();
    return const PlayHistory();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final gamesJson = prefs.getStringList(_gamesKey) ?? [];
    final games = gamesJson.map((e) => SavedGame.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
    
    state = PlayHistory(
      wins: prefs.getInt(_winsKey) ?? 0,
      losses: prefs.getInt(_lossesKey) ?? 0,
      draws: prefs.getInt(_drawsKey) ?? 0,
      savedGames: games,
    );
  }

  Future<void> addWin(List<String> moveHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final newWins = state.wins + 1;
    await prefs.setInt(_winsKey, newWins);
    state = state.copyWith(wins: newWins);
    _saveGame('win', moveHistory);
  }

  Future<void> addLoss(List<String> moveHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final newLosses = state.losses + 1;
    await prefs.setInt(_lossesKey, newLosses);
    state = state.copyWith(losses: newLosses);
    _saveGame('loss', moveHistory);
  }

  Future<void> addDraw(List<String> moveHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final newDraws = state.draws + 1;
    await prefs.setInt(_drawsKey, newDraws);
    state = state.copyWith(draws: newDraws);
    _saveGame('draw', moveHistory);
  }
  
  /// Records a local pass-and-play game. These do NOT touch the vs-engine
  /// W/D/L counters (there's no single "user" to attribute the result to);
  /// they are only stored in the games list, tagged as friend games.
  /// [result] is the winning side: 'white' | 'black' | 'draw'.
  Future<void> addFriendGame(String result, List<String> moveHistory) async {
    await _saveGame(result, moveHistory, mode: 'friend');
  }

  Future<void> _saveGame(
    String result,
    List<String> moveHistory, {
    String mode = 'engine',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final game = SavedGame(
      date: DateTime.now().toIso8601String(),
      result: result,
      pgnMoves: moveHistory,
      mode: mode,
    );
    final newGames = [...state.savedGames, game];
    await prefs.setStringList(_gamesKey, newGames.map((g) => jsonEncode(g.toJson())).toList());
    state = state.copyWith(savedGames: newGames);
  }
}

final playHistoryProvider = NotifierProvider<PlayHistoryNotifier, PlayHistory>(() => PlayHistoryNotifier());
