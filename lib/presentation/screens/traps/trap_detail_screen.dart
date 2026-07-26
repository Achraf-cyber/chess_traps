import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chess_traps/presentation/state/traps/learned_traps_provider.dart';
import 'package:chess_traps/core/services/audio_haptic_service.dart';
import 'package:chess_traps/presentation/state/favorites/user_favorites_provider.dart';
import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:chess_traps/core/services/interstitial_ad_manager.dart';
import 'package:chess_traps/core/services/rewarded_ad_manager.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';
import 'package:chess_traps/core/providers/daily_limit_provider.dart';

import 'package:chess_traps/core/services/app_link_service.dart';
import 'package:chess_traps/utils.dart';
import 'package:chess_traps/presentation/state/traps/trap_game_provider.dart';
import 'package:chess_traps/presentation/state/play/engine_analysis_provider.dart';
import 'package:chess_traps/core/providers/settings_provider.dart';

import 'package:chess_traps/presentation/widgets/evaluation_bar.dart';
import 'package:chess_traps/data/traps/chess_trap.dart';
import 'package:chess_traps/core/services/move_annotator.dart';
import 'package:chess_traps/presentation/state/traps/traps_provider.dart';
import 'package:chess_traps/presentation/widgets/explore_trap_card.dart';


class TrapDetailScreen extends ConsumerStatefulWidget {
  const TrapDetailScreen({super.key, required this.trapIndex});
  final int trapIndex;

  @override
  ConsumerState<TrapDetailScreen> createState() => _TrapDetailScreenState();
}

class _TrapDetailScreenState extends ConsumerState<TrapDetailScreen> {
  int currentMoveIndex = 0;
  Side orientation = Side.white;
  bool _orientationInitialized = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _autoPlayTimer;
  bool isAutoPlaying = false;
  bool isPracticeMode = false;
  bool isAvoidMode = false;
  int? blunderIndex;
  NormalMove? promotionMove;
  bool? _isLastMoveCorrect;
  Timer? _feedbackTimer;
  NormalMove? _hintMove;
  int _wrongAttempts = 0;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _enforceDailyLimit();
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        InterstitialAdManager().onTrapViewed();
      });
    });
  }

  /// Rewarded-unlock gate: once the user has opened more than the (remote-
  /// tunable, generous) daily free allowance of traps, offer to watch a
  /// rewarded ad to unlock unlimited traps for the rest of the day. Declining
  /// closes this trap. Ads-disabled builds never gate.
  Future<void> _enforceDailyLimit() async {
    if (!RemoteConfigService().adsEnabled) return;
    final daily = ref.read(dailyLimitProvider.notifier);
    await daily.ready;
    if (!mounted) return;

    if (daily.canViewTrap()) {
      daily.incrementViewCount();
      return;
    }
    _showDailyUnlockSheet(daily);
  }

  void _showDailyUnlockSheet(DailyLimitNotifier daily) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock_rounded,
                    size: 48, color: context.colors.primary),
                const SizedBox(height: 16),
                Text(
                  context.phrase.daily_limit_reached,
                  style: context.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.phrase.limit_reached_body,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: Text(context.phrase.watchAd),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      RewardedAdManager().showAdIfAvailable(
                        onRewardEarned: () {
                          daily.unlockForToday();
                          if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        },
                        onFailed: () {
                          // No ad available: don't punish the user — grant the
                          // unlock anyway so a failed fill never hard-blocks.
                          daily.unlockForToday();
                          if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetCtx); // close sheet
                    if (mounted) Navigator.of(context).maybePop(); // leave trap
                  },
                  child: Text(context.phrase.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _calculateBlunderIndex(ChessTrap trap) {
    // Find the last move of the losing side
    int lastLosingMoveIndex = -1;
    for (int i = 0; i < trap.moves.length; i++) {
      final turn = (i % 2 == 0) ? Side.white : Side.black;
      if (turn != trap.targetSide) {
        lastLosingMoveIndex = i;
      }
    }
    blunderIndex = lastLosingMoveIndex;
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
    // Deliberately no auto-scroll: the whole page scrolls as one unit now, so
    // pulling the move row into view would drag the board off-screen — exactly
    // when the user most wants to watch it. The selected move stays
    // highlighted; scrolling is left to the user.
  }

  void _toggleAutoPlay(int maxMoves) {
    if (isPracticeMode) setState(() => isPracticeMode = false);
    if (isAvoidMode) setState(() => isAvoidMode = false);
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

  void _onPracticeMove(Move move, {bool? viaDragAndDrop}) {
    final trap = ref.read(trapGameProvider(widget.trapIndex));
    if (trap == null) return;

    if (isAvoidMode) {
      _handleAvoidMove(move);
      return;
    }

    if (currentMoveIndex >= trap.moves.length) return;

    final position = ref.read(
      trapPositionProvider(widget.trapIndex, currentMoveIndex),
    );
    // The board only offers legal moves, but a queued pointer event or a
    // stale promotion selection can arrive after the position has already
    // advanced. Making an illegal move throws PlayException, so guard it
    // and simply ignore the out-of-sync move instead of crashing.
    final String san;
    try {
      san = position.makeSan(move).$2;
    } on PlayException {
      return;
    }
    final expectedSan = trap.moves[currentMoveIndex];

    if (san == expectedSan) {
      _wrongAttempts = 0;
      HapticFeedback.heavyImpact();
      _showFeedback(true);
      _updateMoveIndex(currentMoveIndex + 1, trap.moves.length);

      if (currentMoveIndex < trap.moves.length) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted || !isPracticeMode) return;
          _updateMoveIndex(currentMoveIndex + 1, trap.moves.length);

          if (currentMoveIndex >= trap.moves.length) {
            AudioHapticService().playPraise();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.phrase.trapCompleted)),
            );
            setState(() => isPracticeMode = false);
          }
        });
      } else {
        AudioHapticService().playPraise();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.phrase.trapCompleted)),
        );
        setState(() => isPracticeMode = false);
      }
    } else {
      _wrongAttempts++;
      HapticFeedback.vibrate();
      _showFeedback(false);
      final showingHint = _wrongAttempts >= 2;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            showingHint
                ? context.phrase.incorrectMoveWithHint
                : context.phrase.incorrectMove,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      if (showingHint) {
        _wrongAttempts = 0;
        _showHint(ref.read(engineAnalysisProvider(position.fen)));
      }
    }
  }

  void _handleAvoidMove(Move move) {
    final position = ref.read(
      trapPositionProvider(widget.trapIndex, currentMoveIndex),
    );
    final engineState = ref.read(engineAnalysisProvider(position.fen));
    
    // Check if the move is among the best engine moves or at least not a blunder
    // For simplicity, we check if it's in multiPv or if evaluation is okay
    bool isCorrect = false;
    final uci = move.uci;
    
    for (final bestMoves in engineState.multiPv.values) {
      if (bestMoves.contains(uci)) {
        isCorrect = true;
        break;
      }
    }

    // If no engine data yet, we can't be sure, but let's assume if score > -100 (for black) or < 100 (for white)
    if (!isCorrect && engineState.depth > 10) {
      final score = engineState.scoreInCentipawns;
      final side = position.turn;
      if (side == Side.white && score > -50) isCorrect = true;
      if (side == Side.black && score < 50) isCorrect = true;
    }

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _showFeedback(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.phrase.blunderPrevented)),
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => isAvoidMode = false);
      });
    } else {
      HapticFeedback.vibrate();
      _showFeedback(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.phrase.incorrectMove)),
      );
    }
  }

  void _showFeedback(bool correct) {
    _feedbackTimer?.cancel();
    setState(() {
      _isLastMoveCorrect = correct;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLastMoveCorrect = null;
        });
      }
    });
  }

  void _showHint(EngineAnalysisState engineState) {
    if (!engineState.engineAvailable || engineState.multiPv.isEmpty) return;

    final sortedEntries = engineState.multiPv.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    if (sortedEntries.first.value.isNotEmpty) {
      final uci = sortedEntries.first.value.first;
      setState(() {
        _hintMove = NormalMove.fromUci(uci);
      });
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _hintMove = null);
      });
    }
  }

  void _onPromotionSelection(Role? role) {
    if (promotionMove != null && role != null) {
      final move = NormalMove(
        from: promotionMove!.from,
        to: promotionMove!.to,
        promotion: role,
      );
      _onPracticeMove(move);
      setState(() {
        promotionMove = null;
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _feedbackTimer?.cancel();
    _hintTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trap = ref.watch(trapGameProvider(widget.trapIndex));

    if (trap == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                context.phrase.trapNotFound,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(context.phrase.goBack),
              ),
            ],
          ),
        ),
      );
    }

    if (!_orientationInitialized) {
      orientation = trap.targetSide;
      _orientationInitialized = true;
    }

    final maxMoves = trap.moves.length;
    final position = ref.watch(
      trapPositionProvider(widget.trapIndex, currentMoveIndex),
    );
    final favorite = ref.watch(userFavoritesProvider.notifier);
    final isFavorite = ref.watch(userFavoritesProvider).contains(trap.id);
    final learnedTraps = ref.watch(learnedTrapsProvider);
    final isLearned = learnedTraps.contains(trap.id);

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
    
    if (_hintMove != null) {
      arrowList.add(
        cg.Arrow(
          color: Colors.green.withValues(alpha: 0.8),
          orig: _hintMove!.from,
          dest: _hintMove!.to,
        ),
      );
    }

    final ISet<cg.Shape> arrows = ISet(arrowList);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
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
              favorite.toggleFavorite(trap.id);
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : null,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              switch (value) {
                case 'practice':
                  final maxMoves = trap.moves.length;
                  setState(() {
                    isPracticeMode = !isPracticeMode;
                    isAvoidMode = false;
                    _wrongAttempts = 0;
                    if (isPracticeMode) {
                      currentMoveIndex = 0; // Reset to start
                      if (isAutoPlaying) {
                        _toggleAutoPlay(maxMoves);
                      }

                      // If it's the computer's turn to move first, trigger it
                      final firstPosition = ref.read(
                        trapPositionProvider(widget.trapIndex, 0),
                      );
                      if (firstPosition.turn != trap.targetSide) {
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (!mounted || !isPracticeMode) return;
                          _updateMoveIndex(1, maxMoves);
                        });
                      }
                    }
                  });
                  if (isPracticeMode) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.phrase.practiceModeActive,
                        ),
                      ),
                    );
                  }
                  break;
                case 'avoid':
                  setState(() {
                    isAvoidMode = !isAvoidMode;
                    if (isAvoidMode) {
                      isPracticeMode = false;
                      isAutoPlaying = false;
                      _calculateBlunderIndex(trap);
                      
                      // Auto play until blunder
                      currentMoveIndex = 0;
                      final maxMoves = trap.moves.length;
                      final targetIndex = blunderIndex ?? 0;
                      
                      _autoPlayTimer?.cancel();
                      _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
                        if (currentMoveIndex < targetIndex) {
                          _updateMoveIndex(currentMoveIndex + 1, maxMoves);
                        } else {
                          timer.cancel();
                          // Flip board to losing side
                          setState(() {
                            orientation = trap.targetSide == Side.white ? Side.black : Side.white;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.phrase.avoidModeActive)),
                          );
                        }
                      });
                    }
                  });
                  break;
                case 'autoplay':
                  _toggleAutoPlay(trap.moves.length);
                  break;
                case 'flip':
                  setState(() {
                    orientation = orientation == Side.white
                        ? Side.black
                        : Side.white;
                  });
                  break;
                case 'learned':
                  ref.read(learnedTrapsProvider.notifier).toggleLearned(trap.id);
                  if (!isLearned) {
                    AudioHapticService().playCapture();
                  }
                  break;
                case 'share':
                  await SharePlus.instance.share(
                    ShareParams(
                      text: context.phrase.canYouSurvive(
                        trap.getLocalizedName(context),
                        AppLinkService.buildTrapLink(trap.id),
                      ),
                    ),
                  );
                  break;
                case 'settings':
                  _showSettingsBottomSheet(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'practice',
                child: Row(
                  children: [
                    Icon(
                      isPracticeMode ? Icons.school_rounded : Icons.school_outlined,
                      color: isPracticeMode ? context.colors.primary : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(isPracticeMode ? context.phrase.exitPractice : context.phrase.practiceMode),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'avoid',
                child: Row(
                  children: [
                    Icon(
                      isAvoidMode ? Icons.shield_rounded : Icons.shield_outlined,
                      color: isAvoidMode ? Colors.orange : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(isAvoidMode ? context.phrase.exitAvoidMode : context.phrase.avoidTrapMode),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'autoplay',
                child: Row(
                  children: [
                    Icon(
                      isAutoPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_filled_rounded,
                      color: isAutoPlaying ? context.colors.primary : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(isAutoPlaying ? context.phrase.stopAutoPlay : context.phrase.autoPlay),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'flip',
                child: Row(
                  children: [
                    Icon(Icons.flip_camera_android_rounded, color: context.colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(context.phrase.flipBoard),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'learned',
                child: Row(
                  children: [
                    Icon(
                      isLearned ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                      color: isLearned ? Colors.green : context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(isLearned ? context.phrase.markedAsLearned : context.phrase.markAsLearned),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, color: context.colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(context.phrase.shareTrap),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, color: context.colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(context.phrase.settings),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, bodyConstraints) {
          // Make the whole screen scrollable. On short devices the board and
          // the info panel can't both fit; rather than squeezing the bottom
          // panel to nothing, everything is laid out at a comfortable size and
          // the page scrolls. The board takes the full width, capped so it
          // never eats more than ~58% of the viewport height.
          final boardSize = math
              .min(
                bodyConstraints.maxWidth - 32,
                bodyConstraints.maxHeight * 0.58,
              )
              .clamp(0.0, double.infinity);
          const boardOverhead = 106.0; // eval bar + captures + paddings
          final boardAreaHeight = boardSize + boardOverhead + 20;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(
                  height: boardAreaHeight,
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const barHeight = 24.0;
                        const barSpacing = 12.0;
                        const overheadHeight =
                            106.0; // Bar(24)+Spacing(12)+Captures(24)+paddings, with margin

                        final availableHeight =
                            constraints.maxHeight - overheadHeight;
                        final availableWidth = constraints.maxWidth - 32;

                        final size = (availableHeight < availableWidth
                            ? availableHeight
                            : availableWidth).clamp(0.0, double.infinity);

                        final captured = getCapturedPieces(position.board);
                        final whiteCaptured = captured[Side.white] ?? [];
                        final blackCaptured = captured[Side.black] ?? [];
                        final materialScore = calculateMaterialScore(
                          position.board,
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Horizontal Evaluation Bar
                            if (engineState.engineAvailable)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: SizedBox(
                                  width: size,
                                  height: barHeight,
                                  child: EvaluationBar(
                                    evaluation: engineState.displayScore * 100,
                                    isReversed: orientation == Side.black,
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
                            if (!engineState.engineAvailable)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: SizedBox(
                                  width: size,
                                  height: barHeight,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color:
                                          context.colors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Center(
                                      child: Text(
                                        context.phrase.engineStarting,
                                        style: context.textTheme.labelMedium
                                            ?.copyWith(
                                              color: context.colors.outline,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
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
                                  ? (materialScore > 0 ? "+$materialScore" : "")
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
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  (isPracticeMode && position.turn == trap.targetSide) || isAvoidMode
                                      ? cg.Chessboard(
                                          size: size,
                                          orientation: orientation,
                                          fen: position.fen,
                                          settings: cg.ChessboardSettings(
                                            colorScheme:
                                                settings.boardTheme.colorScheme,
                                          ),
                                          game: cg.GameData(
                                            playerSide:
                                                position.turn == Side.white
                                                ? cg.PlayerSide.white
                                                : cg.PlayerSide.black,
                                            sideToMove: position.turn,
                                            validMoves: position
                                                .legalMoves
                                                .asIMapSquareISet,
                                            promotionMove: promotionMove,
                                            onMove: _onPracticeMove,
                                            isCheck: position.isCheck,
                                            onPromotionSelection:
                                                _onPromotionSelection,
                                          ),
                                        )
                                      : cg.Chessboard.fixed(
                                          size: size,
                                          orientation: orientation,
                                          fen: position.fen,
                                          settings: cg.ChessboardSettings(
                                            colorScheme:
                                                settings.boardTheme.colorScheme,
                                          ),
                                          shapes: isPracticeMode || isAvoidMode
                                              ? ISet()
                                              : arrows,
                                        ),
                                  if (_isLastMoveCorrect != null)
                                    Positioned.fill(
                                      child:
                                          Container(
                                                color:
                                                    (_isLastMoveCorrect!
                                                            ? Colors.green
                                                            : Colors.red)
                                                        .withValues(
                                                          alpha: 0.15,
                                                        ),
                                                child: Center(
                                                  child: Icon(
                                                    _isLastMoveCorrect!
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : Icons.cancel_rounded,
                                                    color:
                                                        (_isLastMoveCorrect!
                                                                ? Colors.green
                                                                : Colors.red)
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
                                                    size: size * 0.6,
                                                  ),
                                                ),
                                              )
                                              .animate()
                                              .scale(
                                                duration: 300.ms,
                                                curve: Curves.easeOutBack,
                                              )
                                              .fadeIn()
                                              .then(delay: 600.ms)
                                              .fadeOut(duration: 300.ms),
                                    ),
                                ],
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
                const SizedBox(height: 4),
                if (!isPracticeMode) ...[
                  _buildMoveNavigation(maxMoves, engineState),
                  const SizedBox(height: 4),
                ],
                if (!isPracticeMode && !isAvoidMode)
                  Container(
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trap.getLocalizedName(context),
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
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: trap.targetSide == Side.white
                                        ? Colors.white
                                        : Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: context.colors.outline.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    trap.targetSide == Side.white ? context.phrase.whiteProfits : context.phrase.blackProfits,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: trap.targetSide == Side.white
                                          ? Colors.black87
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!engineState.engineAvailable)
                                Flexible(
                                  child: Text(
                                    context.phrase.engineUnavailable,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: context.textTheme.labelSmall?.copyWith(
                                      color: context.colors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else if (engineState.depth > 0)
                                Text(
                                  context.phrase.depthLabel(engineState.depth),
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: context.colors.outline,
                                  ),
                                ),
                            ],
                          ),
                          if (currentMoveIndex > 0) ...[
                            const SizedBox(height: 6),
                            _MoveExplanationCaption(
                              trapIndex: widget.trapIndex,
                              moveIndex: currentMoveIndex,
                              san: trap.moves[currentMoveIndex - 1],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _buildVerticalMoveHistory(trap.moves, engineState),
                    if (currentMoveIndex >= maxMoves && !isPracticeMode)
                      _RelatedTrapsStrip(trapId: trap.id),
                  ],
                ),
              ),
                if (isAvoidMode)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, size: 64, color: context.colors.primary),
                        const SizedBox(height: 16),
                        Text(
                          context.phrase.avoidTrap,
                          style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.phrase.findBetterMove,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => setState(() => isAvoidMode = false),
                          child: Text(context.phrase.cancel),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
            final settingsNotifier = ref.read(chessSettingsProvider.notifier);

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.phrase.analysisSettings,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.phrase.engineBestMoves,
                      style: context.textTheme.labelLarge,
                    ),
                    Slider(
                      value: settings.arrowCount.toDouble(),
                      max: 4,
                      divisions: 4,
                      label: settings.arrowCount.toString(),
                      onChanged: (double value) {
                        ref.read(chessSettingsProvider.notifier).updateArrowCount(value.toInt());
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(context.phrase.boardTheme, style: context.textTheme.labelLarge),
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
                          settingsNotifier.updateBoardTheme(theme);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        settings.soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: context.colors.onSurfaceVariant,
                      ),
                      title: Text(
                        context.phrase.soundEffects,
                        style: context.textTheme.labelLarge,
                      ),
                      value: settings.soundEnabled,
                      onChanged: settingsNotifier.updateSoundEnabled,
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

  Widget _buildMoveNavigation(int maxMoves, EngineAnalysisState engineState) {
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
          const SizedBox(width: 12),
          _buildNavButton(
            Icons.chevron_left_rounded,
            () => _updateMoveIndex(currentMoveIndex - 1, maxMoves),
            currentMoveIndex > 0,
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            Icons.lightbulb_outline_rounded,
            () => _showHint(engineState),
            engineState.engineAvailable && engineState.multiPv.isNotEmpty,
            color: Colors.amber,
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            Icons.chevron_right_rounded,
            () => _updateMoveIndex(currentMoveIndex + 1, maxMoves),
            currentMoveIndex < maxMoves,
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            Icons.last_page_rounded,
            () => _updateMoveIndex(maxMoves, maxMoves),
            currentMoveIndex < maxMoves,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, bool enabled, {Color? color}) {
    return IconButton.filledTonal(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon),
      iconSize: 28,
      style: color != null ? IconButton.styleFrom(
        foregroundColor: color,
        backgroundColor: color.withValues(alpha: 0.1),
      ) : null,
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? context.colors.onPrimaryContainer
                    : context.colors.onSurface,
              ) ?? const TextStyle(),
              child: Text(move),
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
              ).animate().scale(duration: 150.ms, curve: Curves.easeOutBack),
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

/// Horizontal strip of related traps (same opening) shown once the current
/// trap has been fully played through, so users have somewhere to go next.
class _RelatedTrapsStrip extends ConsumerWidget {
  const _RelatedTrapsStrip({required this.trapId});
  final int trapId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedTrapsProvider(trapId));
    if (related.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.phrase.relatedTraps,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => SizedBox(
                width: 130,
                child: ExploreTrapCard(trap: related[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One-line "why this move matters" caption under the board, computed
/// offline via [explainMove] — no authoring, no network.
class _MoveExplanationCaption extends ConsumerWidget {
  const _MoveExplanationCaption({
    required this.trapIndex,
    required this.moveIndex,
    required this.san,
  });

  final int trapIndex;
  final int moveIndex; // position AFTER the move to explain
  final String san;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final before = ref.watch(trapPositionProvider(trapIndex, moveIndex - 1));
    final after = ref.watch(trapPositionProvider(trapIndex, moveIndex));
    final move = before.parseSan(san);
    if (move == null) return const SizedBox.shrink();

    final explanation = explainMove(
      context: context,
      before: before,
      move: move,
      after: after,
      san: san,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 14, color: context.colors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              explanation,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
