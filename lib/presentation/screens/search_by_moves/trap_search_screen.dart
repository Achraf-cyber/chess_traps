import 'dart:math';

import 'package:chess_traps/core/services/analytics_service.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/presentation/widgets/game_board.dart';
import 'package:chess_traps/core/providers/ads_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chess_traps/data/play/chess_move_node.dart';
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/generated/chess/prebuilt_move_trie.dart';
import 'package:chess_traps/presentation/widgets/search_result_tile.dart';
import 'package:chess_traps/utils.dart';
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
  Move? lastMove;
  List<Move> history = [];
  ChessMoveNode? _currentNode = moveTrie;
  List<int> _currentTrapIds = [];

  // Free-text name search, applied on top of the move-narrowed set.
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _searchFocus = FocusNode();

  // The results sheet, resting at its minimum size below the board.
  final _sheetController = DraggableScrollableController();

  // Rewarded Ad logic
  RewardedAd? _rewardedAd;
  int _bonusMoves = 0;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(_onSearchFocusChanged);
    _updateTraps();
    _loadRewardedAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      InterstitialAdManager().onTrapViewed();
    });
  }

  /// Typing a name needs the results in view, not the board.
  void _onSearchFocusChanged() {
    if (_searchFocus.hasFocus && _sheetController.isAttached) {
      _sheetController.animateTo(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _loadRewardedAd() {
    if (!RemoteConfigService().adsEnabled) return;
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

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        AnalyticsService.instance.logRewardedAdEarned(
          placement: 'search_limit',
        );
        setState(() {
          _bonusMoves += 5;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.phrase.unlockedExtraMoves)),
        );
      },
    );
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
    final adsEnabled = RemoteConfigService().adsEnabled;
    final freeLimit = 6 + _bonusMoves;

    if (adsEnabled && history.length >= freeLimit) {
      if (_rewardedAd != null) {
        _showAdOptionDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.phrase.move_limit_reached)),
          );
        }
      }
      return;
    }
    // Guard against an out-of-sync move (queued pointer event / stale
    // promotion) reaching an illegal position, which would throw and crash.
    final Position nextPos;
    final String san;
    try {
      (nextPos, san) = position.makeSan(move);
    } on PlayException {
      return;
    }
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
        title: Text(context.phrase.daily_limit_reached),
        content: Text(context.phrase.search_limit_body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(context.phrase.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showRewardedAd();
            },
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: Text(context.phrase.watchAd),
          ),
        ],
      ),
    );
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
      // The board never sits in a scrollable: a drag that starts on it is
      // always a move. The results are a sheet of their own, resting below the
      // board and pulled up over it when there is a list to read.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const headerHeight = 56.0;
            const historyHeight = 44.0;
            const minimumSheetHeight = 150.0;

            final height = constraints.maxHeight;
            final boardSize = min(
              constraints.maxWidth - 24,
              height - headerHeight - historyHeight - minimumSheetHeight,
            ).clamp(120.0, double.infinity);
            final sheetSize =
                ((height - headerHeight - historyHeight - boardSize) / height)
                    .clamp(0.15, 1.0);

            return Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: headerHeight, child: _buildHeader()),
                    GameBoard(
                      size: boardSize,
                      orientation: orientation,
                      fen: position.fen,
                      lastMove: lastMove,
                      playerSide: position.turn == .white ? .white : .black,
                      onMove: onMove,
                    ),
                    SizedBox(
                      height: historyHeight,
                      child: _SearchMoveHistoryBar(history: history),
                    ),
                  ],
                ),
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: sheetSize,
                  minChildSize: sheetSize,
                  snap: true,
                  builder: (context, scrollController) =>
                      _buildResultsSheet(scrollController),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(context.phrase.search, style: context.textTheme.titleLarge),
          const Spacer(),
          IconButton(
            onPressed: history.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
            tooltip: context.phrase.undo,
          ),
          IconButton(
            onPressed: _flip,
            icon: const Icon(Icons.flip_camera_android_rounded),
            tooltip: context.phrase.flip,
          ),
          IconButton(
            onPressed: history.isEmpty ? null : _reset,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.phrase.resetBoard,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSheet(ScrollController scrollController) {
    final ids = _displayedTrapIds;
    return Material(
      color: context.colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          PinnedHeaderSliver(child: _buildSheetHeader(ids.length)),
          if (ids.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.phrase.noTrapsFoundForSequence,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverList.separated(
              itemCount: ids.length,
              separatorBuilder: (context, _) =>
                  const Divider(height: 1, indent: 102),
              itemBuilder: (context, index) => SearchResultTile(
                trap: chessTraps[ids[index]],
                ply: history.length,
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
          ),
        ],
      ),
    );
  }

  /// The grip, the count and the name field. Part of the scrollable, so that a
  /// drag anywhere on it moves the sheet.
  Widget _buildSheetHeader(int trapCount) {
    return ColoredBox(
      color: context.colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.phrase.matchingTraps,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '$trapCount',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildNameSearchField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      onChanged: (value) => setState(() => _searchQuery = value),
      onTapOutside: (_) => _searchFocus.unfocus(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: context.phrase.searchByName,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
        filled: true,
        fillColor: context.colors.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Move-narrowed ids further filtered by the free-text name query.
  List<int> get _displayedTrapIds {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _currentTrapIds;
    return _currentTrapIds.where((id) {
      final t = chessTraps[id];
      return t.trapName.toLowerCase().contains(q) ||
          t.trapNameFr.toLowerCase().contains(q) ||
          t.trapNameEs.toLowerCase().contains(q) ||
          t.trapNameAr.toLowerCase().contains(q) ||
          t.opening.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _sheetController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}

class _SearchMoveHistoryBar extends StatelessWidget {
  const _SearchMoveHistoryBar({required this.history});

  final List<Move> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final sanMoves = <String>[];
    var pos = Position.initialPosition(Rule.chess);
    for (final m in history) {
      final (nextPos, san) = pos.makeSan(m);
      sanMoves.add(san);
      pos = nextPos;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sanMoves.length,
        itemBuilder: (context, reversed) {
          // Reversed so that the latest move stays in view as the line grows.
          final index = sanMoves.length - 1 - reversed;
          final isWhite = index % 2 == 0;
          final moveNum = (index / 2).floor() + 1;
          return Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Center(
              child: Text(
                "${isWhite ? '$moveNum. ' : ''}${sanMoves[index]}",
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
