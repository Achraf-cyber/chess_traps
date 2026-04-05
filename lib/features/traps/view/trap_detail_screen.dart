import 'package:chess_traps/providers/favorites_provider.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils.dart';
import '../../../providers/trap_game_provider.dart';

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

  void _scrollToCurrentMove() {
    if (!_scrollController.hasClients) return;

    // Approximate width of a move item (move number + white move + black move + spacings)
    // Each move item in the list is roughly 60-80 pixels wide
    final double targetOffset = (currentMoveIndex > 0)
        ? (currentMoveIndex - 1) * 70.0
        : 0.0;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _updateMoveIndex(int newIndex, int maxMoves) {
    if (newIndex < 0 || newIndex > maxMoves) return;
    setState(() {
      currentMoveIndex = newIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentMove());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trap = ref.watch(trapGameProvider(widget.trapIndex));
    final maxMoves = trap.moves.length;
    final position = pgnToPositionIndex(trap.cleanMoves, currentMoveIndex);
    final favorite = ref.watch(favoritesProvider.notifier);
    final isFavorite = ref.watch(favoritesProvider).contains(trap.id);

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
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            (constraints.maxHeight < constraints.maxWidth
                                ? constraints.maxHeight
                                : constraints.maxWidth) *
                            0.95;
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
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
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildMoveNavigation(maxMoves),
              ],
            ),
          ),
          Expanded(
            flex: 8,
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
                                "Theory",
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: context.colors.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Text(
                            "Sequence History",
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.outline,
                            ),
                          ),
                        ),
                        Expanded(child: _buildMoveHistory(trap.moves)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildMoveHistory(List<String> moves) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final moveNum = (index / 2).floor() + 1;
        final isWhite = index % 2 == 0;
        final isSelected = currentMoveIndex == index + 1;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWhite) ...[
              Text(
                "$moveNum.",
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.outline.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
            ],
            GestureDetector(
              onTap: () => _updateMoveIndex(index + 1, moves.length),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  moves[index],
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
