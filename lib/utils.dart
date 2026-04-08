import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:chess_traps/services/billing_service.dart';
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

extension PaywallShow on BuildContext {
  Future<void> showPaywall() async {
    await RevenueCatUI.presentPaywallIfNeeded(BillingService.entitlementId);
  }
}

class AdHelper {
  static const testId = 'ca-app-pub-3940256099942544/6300978111';
  static String get bannerAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-1073733523973638/9907406106'; // VOTRE ID RÉEL
    } else {
      // ID de Test Google (Toujours utiliser ceci en développement !)
      return testId;
    }
  }

  static String get intersticialAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-1073733523973638/3546740839'; // VOTRE ID RÉEL
    } else {
      // test ID
      return testId;
    }
  }

  static String get rewardedIntersticialAdUnitId {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'ca-app-pub-1073733523973638/2921323794'; // VOTRE ID RÉEL
    } else {
      // test ID
      return testId;
    }
  }
}
