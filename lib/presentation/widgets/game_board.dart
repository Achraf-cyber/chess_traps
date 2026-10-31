import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An interactive board described declaratively by [fen], on top of
/// chessground's imperative [ChessboardController].
///
/// One widget serves whether or not the user may move ([playerSide] is
/// [PlayerSide.none] when they can't), so a move made by the opponent or by
/// stepping through a line slides across the board instead of the piece
/// jumping because the board was rebuilt.
class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({
    super.key,
    required this.size,
    required this.orientation,
    required this.fen,
    required this.playerSide,
    this.lastMove,
    this.settings = const ChessboardSettings(),
    this.shapes = const {},
    this.onMove,
  });

  final double size;
  final Side orientation;
  final String fen;
  final PlayerSide playerSide;
  final Move? lastMove;
  final ChessboardSettings settings;
  final Set<Shape> shapes;

  /// Called with a fully resolved move: the board asks for the promotion piece
  /// itself before reporting a promotion.
  final void Function(Move, {bool? viaDragAndDrop})? onMove;

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  late final _controller = ChessboardController(game: _gameData());

  GameData _gameData() {
    final position = Chess.fromSetup(
      Setup.parseFen(widget.fen),
      ignoreImpossibleCheck: true,
    );
    return GameData(
      fen: widget.fen,
      lastMove: widget.lastMove,
      playerSide: widget.playerSide,
      sideToMove: position.turn,
      kingSquareInCheck: position.isCheck ? position.board.kingOf(position.turn) : null,
      validMoves: {
        for (final MapEntry(key: from, value: targets)
            in position.legalMoves.entries)
          from: targets.squares.toSet(),
      },
    );
  }

  @override
  void didUpdateWidget(GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fen != oldWidget.fen ||
        widget.lastMove != oldWidget.lastMove ||
        widget.playerSide != oldWidget.playerSide) {
      _controller.updatePosition(_gameData());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chessboard(
      controller: _controller,
      size: widget.size,
      orientation: widget.orientation,
      settings: widget.settings.copyWith(
        enablePremoves: false,
        colorScheme: ref.watch(chessSettingsProvider).boardTheme.colorScheme,
      ),
      shapes: widget.shapes,
      onMove: widget.onMove,
    );
  }
}
