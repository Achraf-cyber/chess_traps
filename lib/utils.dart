import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

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

String pgnToFen(String pgn) {
  return pgnToPosition(pgn).fen;
}
