import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'l10n/app_localizations.dart';

extension I10nfromContext on BuildContext {
  AppLocalizations get phrase => AppLocalizations.of(this)!;
}

extension ColorsAlias on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}

extension TextThemeAlias on BuildContext {
  TextTheme get textTheme {
    return Theme.of(this).textTheme;
  }
}

extension LightOrDark on BuildContext {
  bool get isLight {
    return Theme.of(this).brightness == Brightness.light;
  }
}

Position pgnToPosition(String pgn) {
  final game = PgnGame.parsePgn(pgn);
  var position = PgnGame.startingPosition(game.headers);

  for (final node in game.moves.mainline()) {
    final move = position.parseSan(node.san);
    if (move == null) break;
    position = position.play(move);
  }

  return position;
}

Position pgnToPositionIndex(String pgn, int index) {
  final game = PgnGame.parsePgn(pgn);
  var position = PgnGame.startingPosition(game.headers);

  final mainline = game.moves.mainline().toList();
  for (var i = 0; i < index && i < mainline.length; i++) {
    final node = mainline[i];
    final move = position.parseSan(node.san);
    if (move == null) break;
    position = position.play(move);
  }

  return position;
}

String pgnToFen(String pgn) {
  return pgnToPosition(pgn).fen;
}

extension LegalMovesToIMapType on IMap<Square, SquareSet> {
  IMap<Square, ISet<Square>> get asIMapSquareISet {
    return map((key, value) {
      return MapEntry(key, value.squares.toISet());
    });
  }
}

Map<Side, List<Role>> getCapturedPieces(Board board) {
  final Map<Role, int> standardCounts = {
    Role.pawn: 8,
    Role.knight: 2,
    Role.bishop: 2,
    Role.rook: 2,
    Role.queen: 1,
  };

  final Map<Side, Map<Role, int>> currentCounts = {
    Side.white: {
      Role.pawn: 0,
      Role.knight: 0,
      Role.bishop: 0,
      Role.rook: 0,
      Role.queen: 0,
    },
    Side.black: {
      Role.pawn: 0,
      Role.knight: 0,
      Role.bishop: 0,
      Role.rook: 0,
      Role.queen: 0,
    },
  };

  for (final piece in board.pieces.map((item) => item.$2)) {
    if (piece.role != Role.king) {
      final sideCounts = currentCounts[piece.color];
      if (sideCounts != null) {
        sideCounts[piece.role] = (sideCounts[piece.role] ?? 0) + 1;
      }
    }
  }
  List<Role> getMissing(Side opponentColor) {
    final missing = <Role>[];
    for (final role in [
      Role.queen,
      Role.rook,
      Role.bishop,
      Role.knight,
      Role.pawn,
    ]) {
      final sideCounts = currentCounts[opponentColor];
      final count = (sideCounts != null) ? (sideCounts[role] ?? 0) : 0;
      final diff = (standardCounts[role] ?? 0) - count;
      for (var i = 0; i < diff; i++) {
        missing.add(role);
      }
    }
    return missing;
  }

  return {
    Side.white: getMissing(Side.black), // Pieces captured by White
    Side.black: getMissing(Side.white), // Pieces captured by Black
  };
}

int calculateMaterialScore(Board board) {
  const values = {
    Role.pawn: 1,
    Role.knight: 3,
    Role.bishop: 3,
    Role.rook: 5,
    Role.queen: 9,
    Role.king: 0,
  };

  int score = 0;
  for (final piece in board.pieces.map((item) => item.$2)) {
    final value = values[piece.role] ?? 0;
    score += (piece.color == Side.white ? value : -value);
  }
  return score;
}
