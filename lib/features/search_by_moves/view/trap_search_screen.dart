import 'package:chess_traps/widgets/ad_banner_widget.dart';
import 'package:chess_traps/providers/ads_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/data/chess_move_node.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/generated/chess/prebuilt_move_trie.dart';
import 'package:chess_traps/widgets/search_result_tile.dart';
import 'package:chess_traps/utils.dart';
import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';

class TrapSearchScreen extends ConsumerStatefulWidget {
  const TrapSearchScreen({super.key});

  @override
  ConsumerState<TrapSearchScreen> createState() => _TrapSearchScreenState();
}

class _TrapSearchScreenState extends ConsumerState<TrapSearchScreen> {
  var position = Position.initialPosition(Rule.chess);
  var orientation = Side.white;
  NormalMove? promotionMove;
  Move? lastMove;
  List<Move> history = [];
  ChessMoveNode? _currentNode = moveTrie;
  List<int> _currentTrapIds = [];
  
  // Rewarded Ad logic
  RewardedAd? _rewardedAd;
  int _bonusMoves = 0;

  @override
  void initState() {
    super.initState();
    _updateTraps();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdsStateNotifier.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      setState(() {
        _bonusMoves += 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unlocked 5 extra moves!")),
      );
    });
    _rewardedAd = null;
  }

  void _updateTraps() {
    final ids = <int>{};
    if (_currentNode != null) {
      _collectSubtreeTraps(_currentNode!, ids);
    }
    setState(() {
      _currentTrapIds = ids.toList()..sort();
    });
  }

  void _collectSubtreeTraps(ChessMoveNode node, Set<int> result) {
    result.addAll(node.values);
    for (final child in node.children.values) {
      _collectSubtreeTraps(child, result);
    }
  }

  void onMove(Move move, {bool? viaDragAndDrop}) {
    final freeLimit = 6 + _bonusMoves;
    
    if (history.length >= freeLimit) {
      if (_rewardedAd != null) {
        _showAdOptionDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Move limit reached. Ad not ready yet, please wait or reset.")),
        );
      }
      return;
    }
    final (nextPos, san) = position.makeSan(move);
    setState(() {
      history.add(move);
      position = nextPos;
      lastMove = move;
      _currentNode = _currentNode?.children[san];
    });
    _updateTraps();
  }

  void _showAdOptionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limit Reached"),
        content: const Text(
          "You've reached the free move limit for this search. Watch a short video ad to unlock 5 more moves.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("CANCEL"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd();
            },
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text("WATCH AD"),
          ),
        ],
      ),
    );
  }

  void onPromotionSelection(Role? role) {
    if (promotionMove != null && role != null) {
      final move = NormalMove(
        from: promotionMove!.from,
        to: promotionMove!.to,
        promotion: role,
      );
      onMove(move);
      setState(() {
        promotionMove = null;
      });
    }
  }

  void _undo() {
    if (history.isEmpty) return;
    final newHistory = List<Move>.from(history)..removeLast();
    _resetTo(newHistory);
  }

  void _reset() {
    _resetTo([]);
    setState(() {
      _bonusMoves = 0;
    });
  }

  void _resetTo(List<Move> newHistory) {
    var newPosition = Position.initialPosition(Rule.chess);
    ChessMoveNode? newNode = moveTrie;
    Move? newLastMove;

    for (final m in newHistory) {
      final (nextPos, san) = newPosition.makeSan(m);
      newPosition = nextPos;
      newNode = newNode?.children[san];
      newLastMove = m;
    }

    setState(() {
      history = newHistory;
      position = newPosition;
      _currentNode = newNode;
      lastMove = newLastMove;
    });
    _updateTraps();
  }

  void _flip() {
    setState(() {
      orientation = orientation == Side.white ? Side.black : Side.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdBannerWidget(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFloatingHeader(),
            const SizedBox(height: 8),
            Expanded(flex: 7, child: _buildBoardLayer()),
            const SizedBox(height: 12),
            Expanded(
              flex: 4,
              child: _SearchResultsSection(
                trapCount: _currentTrapIds.length,
                phraseMatchingTraps: context.phrase.matchingTraps,
                child: _buildInlineResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardLayer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;
        final boardMaxHeight = totalHeight * 0.72;
        final boardSize = boardMaxHeight < totalWidth ? boardMaxHeight : totalWidth;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Center(
                child: Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Chessboard(
                    size: boardSize,
                    orientation: orientation,
                    fen: position.fen,
                    lastMove: lastMove,
                    game: GameData(
                      playerSide: position.turn == .white ? .white : .black,
                      sideToMove: position.turn,
                      validMoves: position.legalMoves.asIMapSquareISet,
                      promotionMove: promotionMove,
                      onMove: onMove,
                      isCheck: position.isCheck,
                      onPromotionSelection: onPromotionSelection,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SearchControlsRow(
                onUndo: _undo,
                onFlip: _flip,
                canUndo: history.isNotEmpty,
              ),
              const SizedBox(height: 12),
              _SearchMoveHistoryBar(history: history),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingHeader() {
    return _TrapSearchFloatingHeader(
      title: context.phrase.search,
      resetTooltip: context.phrase.resetBoard,
      onUndo: _undo,
      onFlip: _flip,
      onReset: _reset,
    );
  }

  Widget _buildInlineResults() {
    if (_currentTrapIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: context.colors.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              context.phrase.noTrapsFoundForSequence,
              style: context.textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _currentTrapIds.length,
      itemBuilder: (context, index) {
        final trap = chessTraps[_currentTrapIds[index]];
        return SearchResultTile(trap: trap, index: index);
      },
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}

class _TrapSearchFloatingHeader extends StatelessWidget {
  const _TrapSearchFloatingHeader({
    required this.title,
    required this.resetTooltip,
    required this.onUndo,
    required this.onFlip,
    required this.onReset,
  });

  final String title;
  final String resetTooltip;
  final VoidCallback onUndo;
  final VoidCallback onFlip;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.colors.primary,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onUndo,
              icon: const Icon(Icons.undo_rounded, size: 20),
              tooltip: 'Undo',
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: onFlip,
              icon: const Icon(Icons.flip_camera_android_rounded, size: 20),
              tooltip: 'Flip',
              visualDensity: VisualDensity.compact,
            ),
            IconButton.filledTonal(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: resetTooltip,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchControlsRow extends StatelessWidget {
  const _SearchControlsRow({
    required this.onUndo,
    required this.onFlip,
    required this.canUndo,
  });

  final VoidCallback onUndo;
  final VoidCallback onFlip;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SearchNavButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          onPressed: canUndo ? onUndo : null,
        ),
        const SizedBox(width: 16),
        _SearchNavButton(
          icon: Icons.flip_camera_android_rounded,
          label: 'Flip',
          onPressed: onFlip,
        ),
      ],
    );
  }
}

class _SearchNavButton extends StatelessWidget {
  const _SearchNavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          iconSize: 24,
          icon: Icon(icon),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: enabled ? context.colors.onSurface : context.colors.outline,
          ),
        ),
      ],
    );
  }
}

class _SearchMoveHistoryBar extends StatelessWidget {
  const _SearchMoveHistoryBar({required this.history});

  final List<Move> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox(height: 40);

    final sanMoves = <String>[];
    var pos = Position.initialPosition(Rule.chess);
    for (final m in history) {
      final (nextPos, san) = pos.makeSan(m);
      sanMoves.add(san);
      pos = nextPos;
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sanMoves.length,
        itemBuilder: (context, index) {
          final isWhite = index % 2 == 0;
          final moveNum = (index / 2).floor() + 1;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                "${isWhite ? '$moveNum. ' : ''}${sanMoves[index]}",
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.colors.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  const _SearchResultsSection({
    required this.trapCount,
    required this.phraseMatchingTraps,
    required this.child,
  });

  final int trapCount;
  final String phraseMatchingTraps;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: context.colors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  phraseMatchingTraps,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$trapCount',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
