class ChessTrap {
  final String opening;
  final String trapName;
  final String cleanMoves;
  final String commentedMoves;
  final String metadata;

  const ChessTrap({
    required this.opening,
    required this.trapName,
    required this.cleanMoves,
    required this.commentedMoves,
    required this.metadata,
  });

  factory ChessTrap.fromJson(Map<String, dynamic> json) {
    return ChessTrap(
      opening: json['opening'] as String,
      trapName: json['trap_name'] as String,
      cleanMoves: json['clean_moves'] as String,
      commentedMoves: json['commented_moves'] as String,
      metadata: json['metadata'] as String,
    );
  }
}
