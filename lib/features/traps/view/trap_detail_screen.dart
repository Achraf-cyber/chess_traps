import 'dart:async';
import 'package:chess_traps/providers/user_favorites_provider.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_traps/services/interstitial_ad_manager.dart';

import '../../../utils.dart';
import '../../../providers/trap_game_provider.dart';
import '../../../providers/engine_analysis_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/ad_banner_widget.dart';
import '../../../widgets/evaluation_bar.dart';

class TrapDetailScreen extends ConsumerStatefulWidget {
  const TrapDetailScreen({super.key, required this.trapIndex});
  final int trapIndex;

  @override
  ConsumerState<TrapDetailScreen> createState() => _TrapDetailScreenState();
}

class _TrapDetailScreenState extends ConsumerState<TrapDetailScreen> {
  int currentMoveIndex = 0;
  Side orientation = Side.white;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoPlayTimer;
  bool isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InterstitialAdManager().onTrapViewed();
    });
  }

  void _scrollToCurrentMove() {
    if (!_scrollController.hasClients) return;

    final int rowIndex = (currentMoveIndex - 1) ~/ 2;
    final double targetOffset = (rowIndex > 0) ? rowIndex * 44.0 : 0.0;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateMoveIndex(int newIndex, int maxMoves) {
    if (newIndex < 0 || newIndex > maxMoves) {
      if (isAutoPlaying) _toggleAutoPlay(maxMoves);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      currentMoveIndex = newIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentMove());
  }

  void _toggleAutoPlay(int maxMoves) {
    if (isAutoPlaying) {
      _autoPlayTimer?.cancel();
      setState(() => isAutoPlaying = false);
    } else {
      setState(() => isAutoPlaying = true);
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (currentMoveIndex >= maxMoves) {
          _toggleAutoPlay(maxMoves);
        } else {
          _updateMoveIndex(currentMoveIndex + 1, maxMoves);
        }
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trap = ref.watch(trapGameProvider(widget.trapIndex));
    final maxMoves = trap.moves.length;
    final position = ref.watch(
      trapPositionProvider(widget.trapIndex, currentMoveIndex),
    );
    final favorite = ref.watch(userFavoritesProvider.notifier);
    final isFavorite = ref.watch(userFavoritesProvider).contains(trap.id);

    // Engine Analysis State
    final engineState = ref.watch(engineAnalysisProvider(position.fen));
    final ChessSettings settings = ref.watch(chessSettingsProvider);

    // Build Arrows from engine best moves
    final List<cg.Shape> arrowList = [];
    if (engineState.multiPv.isNotEmpty) {
      final colors = [
        Colors.blue.withValues(alpha: 0.65),
        Colors.deepOrange.withValues(alpha: 0.65),
        Colors.green.withValues(alpha: 0.65),
        Colors.purple.withValues(alpha: 0.65),
      ];

      int count = 0;
      final sortedEntries = engineState.multiPv.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      for (final entry in sortedEntries) {
        if (count >= settings.arrowCount) break;
        if (entry.value.isNotEmpty) {
          final uciMove = entry.value.first;
          final parsedMove = NormalMove.fromUci(uciMove);
          arrowList.add(
            cg.Arrow(
              color: colors[count % colors.length],
              orig: parsedMove.from,
              dest: parsedMove.to,
            ),
          );
          count++;
        }
      }
    }
    final ISet<cg.Shape> arrows = ISet(arrowList);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          trap.opening,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _toggleAutoPlay(maxMoves),
            icon: Icon(
              isAutoPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
              color: isAutoPlaying ? context.colors.primary : null,
            ),
            tooltip: isAutoPlaying ? "Stop Auto Play" : "Start Auto Play",
          ),
          IconButton(
            onPressed: () {
              setState(() {
                orientation = orientation == Side.white
                    ? Side.black
                    : Side.white;
              });
            },
            icon: const Icon(Icons.flip_camera_android_rounded),
          ),
          IconButton(
            onPressed: () {
              favorite.toggleFavorite(trap.id);
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          IconButton(
            onPressed: () => _showSettingsBottomSheet(context, ref),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 15,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const barHeight = 24.0;
                        const barSpacing = 12.0;
                        const overheadHeight =
                            90.0; // Bar + Spacing + Captures + Paddings

                        final availableHeight =
                            constraints.maxHeight - overheadHeight;
                        final availableWidth = constraints.maxWidth - 32;

                        final size = availableHeight < availableWidth
                            ? availableHeight
                            : availableWidth;

                        final captured = getCapturedPieces(position.board);
                        final whiteCaptured = captured[Side.white]!;
                        final blackCaptured = captured[Side.black]!;
                        final materialScore = calculateMaterialScore(
                          position.board,
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Horizontal Evaluation Bar
                            if (engineState.depth >= 0)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: SizedBox(
                                  width: size,
                                  height: barHeight,
                                  child: EvaluationBar(
                                    score: engineState.displayScore.toDouble(),
                                    isWhiteOrientation:
                                        orientation == Side.white,
                                    orientation: Axis.horizontal,
                                    label: engineState.mateIn != null
                                        ? "M${engineState.mateIn!.abs()}"
                                        : (engineState.scoreInCentipawns > 0
                                                  ? "+"
                                                  : "") +
                                              (engineState.scoreInCentipawns /
                                                      100.0)
                                                  .toStringAsFixed(1),
                                  ),
                                ),
                              ),
                            const SizedBox(height: barSpacing),
                            CapturedPiecesRow(
                              pieces: orientation == Side.white
                                  ? blackCaptured
                                  : whiteCaptured,
                              isWhite: orientation == Side.black,
                              advantage: orientation == Side.white
                                  ? (materialScore > 0
                                        ? "+$materialScore"
                                        : "")
                                  : (materialScore < 0
                                        ? "+${-materialScore}"
                                        : ""),
                              width: size,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: cg.Chessboard.fixed(
                                size: size,
                                orientation: orientation,
                                fen: position.fen,
                                settings: cg.ChessboardSettings(
                                  colorScheme: settings.boardTheme.colorScheme,
                                ),
                                shapes: arrows,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CapturedPiecesRow(
                              pieces: orientation == Side.white
                                  ? whiteCaptured
                                  : blackCaptured,
                              isWhite: orientation == Side.white,
                              advantage: orientation == Side.white
                                  ? (materialScore < 0
                                        ? "+${-materialScore}"
                                        : "")
                                  : (materialScore > 0
                                        ? "+$materialScore"
                                        : ""),
                              width: size,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMoveNavigation(maxMoves),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trap.trapName,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: context.colors.primary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.phrase.theory,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (engineState.depth > 0)
                              Text(
                                "Depth: ${engineState.depth}",
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.outline,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildVerticalMoveHistory(trap.moves, engineState),
                  ),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(chessSettingsProvider);
            final notifier = ref.read(chessSettingsProvider.notifier);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Settings',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Engine Best Moves (Arrows)',
                      style: context.textTheme.labelLarge,
                    ),
                    Slider(
                      value: settings.arrowCount.toDouble(),
                      max: 4,
                      divisions: 4,
                      label: settings.arrowCount.toString(),
                      onChanged: (double value) {
                        notifier.updateArrowCount(value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Board Theme', style: context.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<AppBoardTheme>(
                      initialValue: settings.boardTheme,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      items: AppBoardTheme.values.map((theme) {
                        return DropdownMenuItem(
                          value: theme,
                          child: Text(theme.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (AppBoardTheme? theme) {
                        if (theme != null) {
                          notifier.updateBoardTheme(theme);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMoveNavigation(int maxMoves) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(
            Icons.first_page_rounded,
            () => _updateMoveIndex(0, maxMoves),
            currentMoveIndex > 0,
          ),
          const SizedBox(width: 16),
          _buildNavButton(
            Icons.chevron_left_rounded,
            () => _updateMoveIndex(currentMoveIndex - 1, maxMoves),
            currentMoveIndex > 0,
          ),
          const SizedBox(width: 16),
          _buildNavButton(
            Icons.chevron_right_rounded,
            () => _updateMoveIndex(currentMoveIndex + 1, maxMoves),
            currentMoveIndex < maxMoves,
          ),
          const SizedBox(width: 16),
          _buildNavButton(
            Icons.last_page_rounded,
            () => _updateMoveIndex(maxMoves, maxMoves),
            currentMoveIndex < maxMoves,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return IconButton.filledTonal(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      iconSize: 28,
    );
  }

  Widget _buildVerticalMoveHistory(
    List<String> moves,
    EngineAnalysisState state,
  ) {
    final pairs = <List<String>>[];
    for (int i = 0; i < moves.length; i += 2) {
      if (i + 1 < moves.length) {
        pairs.add([moves[i], moves[i + 1]]);
      } else {
        pairs.add([moves[i]]);
      }
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      itemCount: pairs.length,
      itemBuilder: (context, index) {
        final moveNum = index + 1;
        final pair = pairs[index];
        final whiteMoveIndex = index * 2 + 1;
        final blackMoveIndex = index * 2 + 2;

        final isWhiteSelected = currentMoveIndex == whiteMoveIndex;
        final isBlackSelected = currentMoveIndex == blackMoveIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  "$moveNum.",
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.outline.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: _buildMoveCell(
                  pair[0],
                  isWhiteSelected,
                  () => _updateMoveIndex(whiteMoveIndex, moves.length),
                  isWhiteSelected ? state : null,
                  context,
                ),
              ),
              Expanded(
                child: pair.length > 1
                    ? _buildMoveCell(
                        pair[1],
                        isBlackSelected,
                        () => _updateMoveIndex(blackMoveIndex, moves.length),
                        isBlackSelected ? state : null,
                        context,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoveCell(
    String move,
    bool isSelected,
    VoidCallback onTap,
    EngineAnalysisState? state,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              move,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? context.colors.onPrimaryContainer
                    : context.colors.onSurface,
              ),
            ),
            if (state != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.mateIn != null
                      ? "M${state.mateIn!.abs()}"
                      : (state.scoreInCentipawns > 0 ? "+" : "") +
                            (state.scoreInCentipawns / 100.0).toStringAsFixed(
                              1,
                            ),
                  style: context.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CapturedPiecesRow extends StatelessWidget {
  const CapturedPiecesRow({
    super.key,
    required this.pieces,
    required this.isWhite,
    required this.advantage,
    required this.width,
  });
  final List<Role> pieces;
  final bool isWhite;
  final String advantage;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              children: pieces
                  .map((role) => _PieceIcon(role: role, isWhite: !isWhite))
                  .toList(),
            ),
          ),
          if (advantage.isNotEmpty)
            Text(
              advantage,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _PieceIcon extends StatelessWidget {
  const _PieceIcon({required this.role, required this.isWhite});
  final Role role;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    FaIconData icon;
    switch (role) {
      case Role.pawn:
        icon = FontAwesomeIcons.solidChessPawn;
      case Role.knight:
        icon = FontAwesomeIcons.solidChessKnight;
      case Role.bishop:
        icon = FontAwesomeIcons.solidChessBishop;
      case Role.rook:
        icon = FontAwesomeIcons.solidChessRook;
      case Role.queen:
        icon = FontAwesomeIcons.solidChessQueen;
      default:
        icon = FontAwesomeIcons.solidChessPawn;
    }

    return FaIcon(
      icon,
      size: 16,
      color: isWhite ? Colors.grey[500] : Colors.grey[900],
    );
  }
}
