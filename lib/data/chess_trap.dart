class ChessTrap {
  const ChessTrap({
    required this.id,
    required this.openingId,
    required this.opening,
    required this.trapName,
    required this.cleanMoves,
    required this.commentedMoves,
    required this.metadata,
    required this.moves,
    required this.fen,
  });

  final int id;
  final String openingId;
  final String opening;

  final String trapName;

  final String cleanMoves;
  final List<String> moves;

  final String commentedMoves;

  final String metadata;
  final String fen;
}
