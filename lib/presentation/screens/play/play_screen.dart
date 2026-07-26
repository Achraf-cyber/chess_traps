import 'dart:math';

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chess_traps/core/providers/settings_provider.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/presentation/state/play/play_game_provider.dart';
import 'package:chess_traps/presentation/state/play/play_history_provider.dart';
import 'package:chess_traps/presentation/screens/play/widgets/move_chip.dart';
import 'package:chess_traps/presentation/screens/play/widgets/post_game_explanation_caption.dart';
import 'package:chess_traps/presentation/widgets/chess/captured_pieces_row.dart';
import 'package:chess_traps/presentation/widgets/evaluation_bar.dart';
import 'package:chess_traps/utils.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  int _currentElo = 1500;
  PlayerColor _currentColor = PlayerColor.white;
  GameMode _currentMode = GameMode.engine;
  bool _boardFlipped = false;

  @override
  void initState() {
    super.initState();
    // Preload so an interstitial is ready to show at the end-of-game break.
    InterstitialAdManager().loadAd();
  }

  /// Handles a move coming from the board. If it's a pawn reaching the last
  /// rank without a promotion role, ask the user which piece to promote to
  /// before committing the move.
  Future<void> _handleUserMove(
    Move move,
    PlayGameNotifier notifier,
    bool isWhite,
  ) async {
    if (move is NormalMove && move.promotion == null) {
      final piece = ref.read(playGameProvider).chess.board.pieceAt(move.from);
      final rank = move.to.rank;
      if (piece?.role == Role.pawn && (rank == 0 || rank == 7)) {
        final role = await _showPromotionPicker(isWhite);
        if (role == null) return; // cancelled — leave the piece where it was
        notifier.onUserMove(move.withPromotion(role));
        return;
      }
    }
    notifier.onUserMove(move);
  }

  Future<Role?> _showPromotionPicker(bool isWhite) {
    const roles = [Role.queen, Role.rook, Role.bishop, Role.knight];
    return showDialog<Role>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.phrase.choose_promotion,
          textAlign: TextAlign.center,
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: roles.map((role) {
            return IconButton(
              iconSize: 44,
              onPressed: () => Navigator.pop(ctx, role),
              icon: Text(
                _promotionGlyph(role),
                style: TextStyle(
                  fontSize: 40,
                  color: isWhite ? Colors.white : Colors.black87,
                  shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _promotionGlyph(Role role) => switch (role) {
    Role.queen => '♛',
    Role.rook => '♜',
    Role.bishop => '♝',
    Role.knight => '♞',
    _ => '',
  };

  /// Converts a UCI move history into standard algebraic notation by replaying
  /// from the initial position.
  List<String> _sanMoves(List<String> uciMoves) {
    final sans = <String>[];
    Position pos = Chess.initial;
    for (final uci in uciMoves) {
      try {
        final (nextPos, san) = pos.makeSan(NormalMove.fromUci(uci));
        sans.add(san);
        pos = nextPos;
      } catch (_) {
        sans.add(uci); // fall back to raw UCI if replay fails
      }
    }
    return sans;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch<PlayGameState>(playGameProvider);
    final notifier = ref.read<PlayGameNotifier>(playGameProvider.notifier);

    // Show result dialog when game ends
    ref.listen<PlayGameState>(playGameProvider, (prev, next) {
      if (prev?.gameResult == null && next.gameResult != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResultDialog(context, next.gameResult!, notifier);
        });
      }
    });

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(
          context.phrase.play,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Quick sound-effects mute toggle, always reachable during a game.
          Builder(
            builder: (context) {
              final soundOn = ref.watch(
                chessSettingsProvider.select((s) => s.soundEnabled),
              );
              return IconButton(
                icon: Icon(
                  soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                ),
                tooltip: context.phrase.soundEffects,
                onPressed: () => ref
                    .read(chessSettingsProvider.notifier)
                    .updateSoundEnabled(!soundOn),
              );
            },
          ),
          // Hints come from the engine — not available in local friend games.
          if (gameState.isPlaying &&
              !gameState.engineThinking &&
              !gameState.isFriendMode)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline_rounded),
              tooltip: context.phrase.hint,
              onPressed: notifier.requestHint,
            ),
          if (gameState.isPlaying || gameState.gameResult != null)
            IconButton(
              icon: const Icon(Icons.flip_camera_android_rounded),
              tooltip: context.phrase.flip,
              onPressed: () => setState(() => _boardFlipped = !_boardFlipped),
            ),
        ],
      ),
      body: (gameState.isPlaying || gameState.gameResult != null)
          ? _buildGameArea(context, gameState, notifier)
          : _buildSetupArea(context, gameState, notifier),
    );
  }

  void _showResultDialog(
    BuildContext context,
    GameResult result,
    PlayGameNotifier notifier,
  ) {
    final playState = ref.read(playGameProvider);
    final resigned = playState.resigned;

    final (
      String title,
      String subtitle,
      IconData icon,
    ) = playState.isFriendMode
        // Friend game: report which side won, not a user-relative result.
        ? (playState.winnerSide == null
              ? (
                  context.phrase.draw,
                  context.phrase.well_played,
                  Icons.handshake_rounded,
                )
              : (
                  playState.winnerSide == Side.white
                      ? context.phrase.whiteWins
                      : context.phrase.blackWins,
                  resigned
                      ? context.phrase.opponentResigned
                      : context.phrase.congratulations,
                  Icons.emoji_events_rounded,
                ))
        : switch (result) {
            GameResult.win => (
              context.phrase.you_won,
              context.phrase.congratulations,
              Icons.emoji_events_rounded,
            ),
            GameResult.loss => (
              context.phrase.stockfish_won,
              resigned
                  ? context.phrase.you_resigned
                  : context.phrase.better_luck_next_time,
              Icons.psychology_rounded,
            ),
            GameResult.draw => (
              context.phrase.draw,
              context.phrase.well_played,
              Icons.handshake_rounded,
            ),
          };

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, size: 48, color: context.colors.primary),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(subtitle, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Monetize the "I'm done" moment — not "play again", to keep
              // the replay loop friction-free. Capped by the shared cooldown.
              InterstitialAdManager().onGameFinished();
            },
            child: Text(context.phrase.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.startGame(
                _currentColor,
                _currentElo,
                mode: _currentMode,
              );
            },
            child: Text(context.phrase.play_again),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupArea(
    BuildContext context,
    PlayGameState state,
    PlayGameNotifier notifier,
  ) {
    final history = ref.watch(playHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Opponent mode: engine vs local friend
          SegmentedButton<GameMode>(
            segments: [
              ButtonSegment(
                value: GameMode.engine,
                label: Text(context.phrase.vsStockfish),
                icon: const Icon(Icons.smart_toy_outlined),
              ),
              ButtonSegment(
                value: GameMode.friend,
                label: Text(context.phrase.vsFriend),
                icon: const Icon(Icons.people_alt_outlined),
              ),
            ],
            selected: {_currentMode},
            onSelectionChanged: (set) =>
                setState(() => _currentMode = set.first),
          ),
          const SizedBox(height: 24),
          if (_currentMode == GameMode.engine)
            Text(
              context.phrase.opponent_strength,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          if (_currentMode == GameMode.engine) const SizedBox(height: 16),
          if (_currentMode == GameMode.friend) ...[
            Icon(
              Icons.people_alt_rounded,
              size: 40,
              color: context.colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              context.phrase.passAndPlayHint,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
          // History Display (vs-engine record)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  context.phrase.wins,
                  history.wins.toString(),
                  Colors.green,
                  Icons.emoji_events_rounded,
                  context,
                ),
                _buildStatColumn(
                  context.phrase.draws,
                  history.draws.toString(),
                  Colors.orange,
                  Icons.handshake_rounded,
                  context,
                ),
                _buildStatColumn(
                  context.phrase.losses,
                  history.losses.toString(),
                  Colors.red,
                  Icons.psychology_rounded,
                  context,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_currentMode == GameMode.engine) ...[
            Text(
              context.phrase.eloLabel(_currentElo),
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Slider(
              value: _currentElo.toDouble(),
              min: 800,
              max: 3200,
              divisions: 24,
              label: _currentElo.toString(),
              onChanged: (val) => setState(() => _currentElo = val.toInt()),
            ),
            Text(
              context.phrase.play_as,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SegmentedButton<PlayerColor>(
              segments: [
                ButtonSegment(
                  value: PlayerColor.white,
                  label: Text(context.phrase.white),
                  icon: const Icon(Icons.circle_outlined),
                ),
                ButtonSegment(
                  value: PlayerColor.random,
                  label: Text(context.phrase.random),
                  icon: const Icon(Icons.casino_outlined),
                ),
                ButtonSegment(
                  value: PlayerColor.black,
                  label: Text(context.phrase.black),
                  icon: const Icon(Icons.circle),
                ),
              ],
              selected: {_currentColor},
              onSelectionChanged: (set) =>
                  setState(() => _currentColor = set.first),
            ),
          ],
          const Spacer(),
          if (history.savedGames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () => _showSavedGames(context, history, notifier),
                icon: const Icon(Icons.history_rounded),
                label: Text(context.phrase.your_games),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              notifier.startGame(
                _currentColor,
                _currentElo,
                mode: _currentMode,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              context.phrase.start_game,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSavedGames(
    BuildContext context,
    PlayHistory history,
    PlayGameNotifier notifier,
  ) {
    final games = history.savedGames.reversed.toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: games.length,
          itemBuilder: (ctx, index) {
            final game = games[index];
            final date = DateTime.tryParse(game.date);
            final (icon, color) = game.isFriendGame
                ? switch (game.result) {
                    'white' => (Icons.emoji_events_rounded, Colors.blueGrey),
                    'black' => (Icons.emoji_events_rounded, Colors.blueGrey),
                    _ => (Icons.handshake_rounded, Colors.orange),
                  }
                : switch (game.result) {
                    'win' => (Icons.emoji_events_rounded, Colors.green),
                    'loss' => (Icons.psychology_rounded, Colors.red),
                    _ => (Icons.handshake_rounded, Colors.orange),
                  };
            // Result summary for friend games shows the winning side.
            final friendResult = switch (game.result) {
              'white' => context.phrase.whiteWins,
              'black' => context.phrase.blackWins,
              _ => context.phrase.draw,
            };
            return ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                date != null
                    ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
                    : game.date,
              ),
              subtitle: Text(
                '${game.pgnMoves.length} ${context.phrase.moves}'
                '${game.isFriendGame ? ' · $friendResult' : ''}',
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  game.isFriendGame
                      ? context.phrase.vsFriend
                      : context.phrase.vsStockfish,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                notifier.viewSavedGame(game);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    Color color,
    IconData icon,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: context.colors.onSurface,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGameArea(
    BuildContext context,
    PlayGameState state,
    PlayGameNotifier notifier,
  ) {
    final isFriend = state.isFriendMode;
    final isWhite = state.userColor == PlayerColor.white;
    final mySide = isWhite ? Side.white : Side.black;
    final opponentSide = isWhite ? Side.black : Side.white;

    final currentFen = state.browseIndex != null
        ? state.fenHistory[state.browseIndex!]
        : state.chess.fen;

    // Friend mode keeps the board fixed (white at the bottom, black at the
    // top — they never swap sides). Instead of rotating the whole board each
    // turn, only the *pieces* flip to face whoever is to move (via the board's
    // pieceOrientationBehavior below), which reads far more naturally across a
    // shared device. The manual flip button still works via [_boardFlipped].
    final baseOrientation = isFriend
        ? Side.white
        : (isWhite ? Side.white : Side.black);
    final boardOrientation = _boardFlipped
        ? baseOrientation.opposite
        : baseOrientation;
    final topSide = boardOrientation.opposite;
    final bottomSide = boardOrientation;

    // In friend mode both sides are human, so any non-browsed position is
    // playable; in engine mode only when it's the user's colour to move.
    final isUserTurn = isFriend
        ? (state.isPlaying && state.browseIndex == null)
        : (state.isPlaying &&
              !state.engineThinking &&
              state.browseIndex == null &&
              ((state.chess.turn == Side.white && isWhite) ||
                  (state.chess.turn == Side.black && !isWhite)));

    final captured = getCapturedPieces(state.chess.board);
    final materialScore = calculateMaterialScore(state.chess.board);
    // Which side sits at top/bottom of the board. Engine mode keeps the user
    // at the bottom (unchanged); friend mode follows the auto-flip.
    final bottomPlayerSide = isFriend ? bottomSide : mySide;
    final topPlayerSide = isFriend ? topSide : opponentSide;
    // Material advantage from the bottom player's perspective.
    final bottomAdvantage = bottomPlayerSide == Side.white
        ? materialScore
        : -materialScore;
    // Whichever side is moving owns any promotion (for picker glyph colour).
    final promotingIsWhite = isFriend
        ? state.chess.turn == Side.white
        : isWhite;
    String sideName(Side s) =>
        s == Side.white ? context.phrase.white : context.phrase.black;

    // With the fixed friend-mode board, the "to move" badge follows whichever
    // side is on the clock rather than always sitting at the bottom.
    final friendLive = isFriend && state.isPlaying && state.browseIndex == null;
    final showTopToMove = friendLive && state.chess.turn == topSide;
    final showBottomToMove = isFriend
        ? (friendLive && state.chess.turn == bottomSide)
        : isUserTurn;

    return Column(
      children: [
        const SizedBox(height: 16),
        // Top player indicator (opponent / top side)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                      (isFriend
                              ? topSide
                              : (isWhite ? Side.black : Side.white)) ==
                          Side.white
                      ? Colors.white
                      : Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.outline),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFriend
                    ? sideName(topSide)
                    : context.phrase.stockfishLabel(state.elo),
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showTopToMove)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.phrase.toMove,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              if (!isFriend && state.engineThinking)
                Row(
                  children: [
                    Text(
                      context.phrase.thinking,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Top player's captured pieces (pieces the top player has taken)
        Padding(
          padding: const EdgeInsets.only(
            left: 34.0,
            right: 16.0,
            top: 4.0,
            bottom: 8.0,
          ),
          child: CapturedPiecesRow(
            pieces: captured[topPlayerSide]!,
            side: bottomPlayerSide,
            advantage: bottomAdvantage < 0 ? -bottomAdvantage : null,
          ),
        ),
        // Chessboard and Evaluation Bar
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // No engine eval bar in friend mode, so the board gets the
                // full width there.
                final reserved = isFriend ? 0.0 : (20 + 8);
                final maxBoardWidth = constraints.maxWidth - reserved;
                final size = min(maxBoardWidth, constraints.maxHeight);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isFriend) ...[
                      SizedBox(
                        height: size,
                        width: 20,
                        // Scoped to playEvalProvider so the fast eval stream
                        // repaints only this bar, not the whole screen.
                        child: Consumer(
                          builder: (context, ref, _) {
                            final PlayEval ev = ref.watch(playEvalProvider);
                            return EvaluationBar(
                              evaluation: ev.cp,
                              isReversed: !isWhite,
                              label: ev.mateIn == null
                                  ? null
                                  : 'M${ev.mateIn!.abs()}',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    SizedBox(
                      width: size,
                      height: size,
                      child: isUserTurn
                          ? cg.Chessboard(
                              size: size,
                              orientation: boardOrientation,
                              fen: currentFen,
                              lastMove: state.lastMove,
                              settings: cg.ChessboardSettings(
                                // Friend mode: pieces flip to face whoever is
                                // to move; the board itself never rotates.
                                pieceOrientationBehavior: isFriend
                                    ? cg.PieceOrientationBehavior.sideToPlay
                                    : cg.PieceOrientationBehavior.facingUser,
                              ),
                              shapes: state.hintMove == null
                                  ? null
                                  : ISet({
                                      cg.Arrow(
                                        color: Colors.green.withValues(
                                          alpha: 0.8,
                                        ),
                                        orig: state.hintMove!.from,
                                        dest: state.hintMove!.to,
                                      ),
                                    }),
                              game: cg.GameData(
                                // Friend mode: whoever is to move controls the
                                // board, so both humans can play in turn.
                                playerSide: isFriend
                                    ? (state.chess.turn == Side.white
                                          ? cg.PlayerSide.white
                                          : cg.PlayerSide.black)
                                    : (isWhite
                                          ? cg.PlayerSide.white
                                          : cg.PlayerSide.black),
                                sideToMove: state.chess.turn,
                                validMoves:
                                    state.chess.legalMoves.asIMapSquareISet,
                                // Promotion is handled by our own dialog in
                                // _handleUserMove, so chessground's inline
                                // selector is disabled here.
                                promotionMove: null,
                                onMove: (move, {bool? viaDragAndDrop}) =>
                                    _handleUserMove(
                                      move,
                                      notifier,
                                      promotingIsWhite,
                                    ),
                                isCheck: state.chess.isCheck,
                                onPromotionSelection: (_) {},
                              ),
                            )
                          : cg.Chessboard.fixed(
                              size: size,
                              orientation: boardOrientation,
                              fen: currentFen,
                              lastMove: state.lastMove,
                              settings: cg.ChessboardSettings(
                                pieceOrientationBehavior: isFriend
                                    ? cg.PieceOrientationBehavior.sideToPlay
                                    : cg.PieceOrientationBehavior.facingUser,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        // Bottom player indicator (you / bottom side)
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: (isFriend ? bottomSide : mySide) == Side.white
                      ? Colors.white
                      : Colors.black87,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.outline),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFriend ? sideName(bottomSide) : context.phrase.you,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showBottomToMove)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFriend
                          ? context.phrase.toMove
                          : context.phrase.your_turn,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Bottom player's captured pieces (pieces the bottom player has taken)
        Padding(
          padding: const EdgeInsets.only(left: 34.0, right: 16.0, top: 4.0),
          child: CapturedPiecesRow(
            pieces: captured[bottomPlayerSide]!,
            side: topPlayerSide,
            advantage: bottomAdvantage > 0 ? bottomAdvantage : null,
          ),
        ),
        const SizedBox(height: 16),
        // Move History (standard algebraic notation, tap to jump). Always
        // reserves the same fixed height whether or not there are moves yet,
        // so the board (in the Expanded above) doesn't resize the moment the
        // first move is played and this stops being a flexible Spacer.
        SizedBox(
          height: 32,
          child: state.moveHistory.isEmpty
              ? null
              : Builder(
                  builder: (context) {
                    final sans = _sanMoves(state.moveHistory);
                    final browseIdx =
                        state.browseIndex ?? state.fenHistory.length - 1;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: (sans.length / 2).ceil(),
                      itemBuilder: (context, index) {
                        final moveNum = index + 1;
                        final whiteIdx = index * 2;
                        final blackIdx = index * 2 + 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$moveNum. ',
                                style: TextStyle(
                                  color: context.colors.outline,
                                  fontSize: 13,
                                ),
                              ),
                              MoveChip(
                                san: sans[whiteIdx],
                                highlighted: browseIdx == whiteIdx + 1,
                                onTap: () =>
                                    notifier.setBrowseIndex(whiteIdx + 1),
                              ),
                              if (blackIdx < sans.length) ...[
                                const SizedBox(width: 8),
                                MoveChip(
                                  san: sans[blackIdx],
                                  highlighted: browseIdx == blackIdx + 1,
                                  onTap: () =>
                                      notifier.setBrowseIndex(blackIdx + 1),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        // Always rendered (buttons simply disabled with a single move) so the
        // board above doesn't resize the instant a nav row's fixed height
        // first appears in the Column.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Builder(
            builder: (context) {
              final lastIndex = state.fenHistory.length - 1;
              final curr = state.browseIndex ?? lastIndex;
              final atStart = curr == 0;
              final atEnd = curr == lastIndex;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page_rounded),
                    tooltip: context.phrase.first_move,
                    onPressed: atStart
                        ? null
                        : () => notifier.setBrowseIndex(0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: context.phrase.previous_move,
                    onPressed: atStart
                        ? null
                        : () => notifier.setBrowseIndex(curr - 1),
                  ),
                  SizedBox(
                    width: 56,
                    child: Text(
                      '${curr + 1} / ${lastIndex + 1}',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: context.phrase.next_move,
                    onPressed: atEnd
                        ? null
                        : () => notifier.setBrowseIndex(curr + 1),
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page_rounded),
                    tooltip: context.phrase.last_move,
                    onPressed: atEnd
                        ? null
                        : () => notifier.setBrowseIndex(lastIndex),
                  ),
                ],
              );
            },
          ),
        ),
        if (state.gameResult != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: PostGameExplanationCaption(state: state),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      (state.fenHistory.length > (state.isFriendMode ? 1 : 2) &&
                          state.isPlaying &&
                          !state.engineThinking)
                      ? () {
                          notifier.takeback();
                        }
                      : null,
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(context.phrase.undo),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (state.gameResult != null) {
                      notifier.backToSetup();
                    } else {
                      notifier.resign();
                    }
                  },
                  icon: Icon(
                    state.gameResult != null
                        ? Icons.arrow_back_rounded
                        : Icons.flag_rounded,
                  ),
                  label: Text(
                    state.gameResult != null
                        ? context.phrase.back_to_setup
                        : context.phrase.resign,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: state.gameResult != null
                        ? context.colors.onSurface
                        : context.colors.error,
                    side: BorderSide(
                      color: state.gameResult != null
                          ? context.colors.outline
                          : context.colors.error,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
