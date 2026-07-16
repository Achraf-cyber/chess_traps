import 'package:flutter/widgets.dart';
import 'package:dartchess/dartchess.dart';

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


