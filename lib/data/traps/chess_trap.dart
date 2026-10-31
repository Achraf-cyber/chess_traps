import 'package:flutter/widgets.dart';
import 'package:dartchess/dartchess.dart';
import 'package:chess_traps/generated/chess/opening_names.dart';

class ChessTrap {
  const ChessTrap({
    required this.id,
    required this.opening,
    required this.openingId,
    required this.trapName,
    this.trapNameFr = '',
    this.trapNameEs = '',
    this.trapNameAr = '',
    required this.cleanMoves,
    required this.commentedMoves,
    required this.metadata,
    required this.moves,
    required this.fen,
    required this.targetSide,
  });

  final int id;
  final String opening;
  final String openingId;

  final String trapName;
  final String trapNameFr;
  final String trapNameEs;
  final String trapNameAr;

  final String cleanMoves;
  final List<String> moves;

  final String commentedMoves;

  final String metadata;
  final String fen;
  final Side targetSide;

  String getLocalizedOpening(BuildContext context) =>
      localizedOpening(context, opening);

  String getLocalizedName(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    switch (languageCode) {
      case 'fr':
        return trapNameFr.isNotEmpty ? trapNameFr : trapName;
      case 'es':
        return trapNameEs.isNotEmpty ? trapNameEs : trapName;
      case 'ar':
        return trapNameAr.isNotEmpty ? trapNameAr : trapName;
      default:
        return trapName;
    }
  }
}

/// [opening] in the app's language, or as is if it has no translation.
String localizedOpening(BuildContext context, String opening) {
  final index = switch (Localizations.localeOf(context).languageCode) {
    'fr' => 0,
    'es' => 1,
    'ar' => 2,
    _ => null,
  };
  if (index == null) return opening;
  return openingNames[opening]?[index] ?? opening;
}
