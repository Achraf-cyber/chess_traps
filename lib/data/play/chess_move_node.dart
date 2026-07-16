class ChessMoveNode {
  const ChessMoveNode({
    required this.move,
    required this.children,
    required this.values,
  });
  final String move;
  final Map<String, ChessMoveNode> children;
  final List<int> values;
}
